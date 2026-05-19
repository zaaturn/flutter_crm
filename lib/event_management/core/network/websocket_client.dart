import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/services/secure_storage_service.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketClient {
  static String _wsBaseUrl() {
    // Keep WS host aligned with the HTTP API host (BASE_URL).
    final base = ApiClient.baseUrl;
    final wsScheme = base.startsWith('https://') ? 'wss://' : 'ws://';
    final host = base.replaceFirst(RegExp(r'^https?://'), '');
    return '$wsScheme$host/ws';
  }

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
      final token = await SecureStorageService().readToken() ?? '';

      _channel = WebSocketChannel.connect(
        Uri.parse('${_wsBaseUrl()}/notifications/?token=$token'),
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