import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/services/api_client.dart' as app_api;
import 'package:my_app/services/secure_storage_service.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

/// Realtime notifications/events socket. Fails silently when the backend has no
/// WS endpoint (common in local dev).
class WebSocketClient {
  static const bool _enabled =
      bool.fromEnvironment('ENABLE_WS', defaultValue: true);

  static String _wsBaseUrl() {
    // BASE_URL may be `https://host` or `https://host/api` — WS lives at `/ws`.
    var root = EventApiClient.baseUrl.replaceAll(RegExp(r'/+$'), '');
    root = root.replaceAll(RegExp(r'/api$'), '');
    final wsScheme = root.startsWith('https://') ? 'wss://' : 'ws://';
    final host = root.replaceFirst(RegExp(r'^https?://'), '');
    return '$wsScheme$host/ws';
  }

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamSubscription<dynamic>? _channelSub;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _disposed = false;

  Stream<Map<String, dynamic>> get stream =>
      _controller?.stream ?? const Stream.empty();

  WebSocketStatus get status => _status;

  Future<void> connect() async {
    if (!_enabled || _disposed) return;
    if (_status == WebSocketStatus.connected ||
        _status == WebSocketStatus.connecting) {
      return;
    }

    _status = WebSocketStatus.connecting;
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();

    try {
      final storage = SecureStorageService();
      var token = await storage.readToken() ?? '';
      if (token.isEmpty) {
        await app_api.ApiClient().refreshSession();
        token = await storage.readToken() ?? '';
      }
      if (token.isEmpty) {
        _status = WebSocketStatus.disconnected;
        return;
      }

      final uri = Uri.parse('${_wsBaseUrl()}/notifications/').replace(
        queryParameters: {'token': token},
      );

      final channel = WebSocketChannel.connect(uri);
      try {
        await channel.ready;
      } catch (e, st) {
        _logConnectFailure(e, st);
        await channel.sink.close(ws_status.goingAway);
        _status = WebSocketStatus.error;
        _scheduleReconnect();
        return;
      }

      _channel = channel;
      _channelSub = _channel!.stream.listen(
        (data) {
          _reconnectAttempts = 0;
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            if (!_controller!.isClosed) {
              _controller!.add(message);
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('WebSocket message parse error: $e');
            }
          }
        },
        onError: (error, stackTrace) {
          _logConnectFailure(error, stackTrace);
          _status = WebSocketStatus.error;
          _scheduleReconnect();
        },
        onDone: () {
          _status = WebSocketStatus.disconnected;
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _status = WebSocketStatus.connected;
      _reconnectAttempts = 0;
      _startHeartbeat();
    } catch (e, st) {
      _logConnectFailure(e, st);
      _status = WebSocketStatus.error;
      _scheduleReconnect();
    }
  }

  void _logConnectFailure(Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    debugPrint('WebSocket unavailable (realtime sync disabled): $error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
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
    if (_disposed || !_enabled) return;
    if (_reconnectAttempts >= 5) return;
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_disposed) unawaited(connect());
    });
  }

  void send(Map<String, dynamic> data) {
    if (_status == WebSocketStatus.connected) {
      try {
        _channel?.sink.add(jsonEncode(data));
      } catch (e) {
        if (kDebugMode) debugPrint('WebSocket send failed: $e');
      }
    }
  }

  void disconnect() {
    _disposed = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channelSub = null;
    try {
      _channel?.sink.close(ws_status.goingAway);
    } catch (_) {}
    _channel = null;
    _controller?.close();
    _controller = null;
    _status = WebSocketStatus.disconnected;
  }
}
