import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketClient {
  static const String _wsBaseUrl = 'ws://localhost:8000/ws';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  Stream<Map<String, dynamic>> get stream =>
      _controller?.stream ?? const Stream.empty();

  WebSocketStatus get status => _status;

  Future<void> connect() async {
    if (_status == WebSocketStatus.connected) return;

    _status = WebSocketStatus.connecting;
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsBaseUrl/notifications/?token=$token'),
      );

      _channel!.stream.listen(
            (data) {
          _reconnectAttempts = 0;
          final message = jsonDecode(data as String) as Map<String, dynamic>;
          _controller?.add(message);
        },
        onError: (error) {
          _status = WebSocketStatus.error;
          _scheduleReconnect();
        },
        onDone: () {
          _status = WebSocketStatus.disconnected;
          _scheduleReconnect();
        },
      );

      _status = WebSocketStatus.connected;
      _startHeartbeat();
    } catch (e) {
      _status = WebSocketStatus.error;
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_status == WebSocketStatus.connected) {
        send({'type': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= 5) return;
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer = Timer(delay, connect);
  }

  void send(Map<String, dynamic> data) {
    if (_status == WebSocketStatus.connected) {
      _channel?.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller?.close();
    _status = WebSocketStatus.disconnected;
  }
}