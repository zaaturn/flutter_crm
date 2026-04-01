import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';

abstract class EventLocalDataSource {
  Future<List<EventModel>> getCachedEvents();
  Future<void> cacheEvents(List<EventModel> events);
  Future<void> cacheEvent(EventModel event);
  Future<void> removeEvent(String id);
  Future<void> clearCache();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  static const String _boxName = 'events_cache';
  static const String _cacheKey = 'cached_events';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    final box = await _box;
    final jsonString = box.get(_cacheKey) as String?;
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final box = await _box;
    final jsonList = events.map((e) => e.toJson()).toList();
    await box.put(_cacheKey, jsonEncode(jsonList));
  }

  @override
  Future<void> cacheEvent(EventModel event) async {
    final existing = await getCachedEvents();
    final index = existing.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      existing[index] = event;
    } else {
      existing.add(event);
    }
    await cacheEvents(existing);
  }

  @override
  Future<void> removeEvent(String id) async {
    final existing = await getCachedEvents();
    existing.removeWhere((e) => e.id == id);
    await cacheEvents(existing);
  }

  @override
  Future<void> clearCache() async {
    final box = await _box;
    await box.clear();
  }
}