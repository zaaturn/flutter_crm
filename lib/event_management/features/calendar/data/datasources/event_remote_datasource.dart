import '../models/event_models.dart';


abstract class EventRemoteDatasource {

  Future<List<EventModel>> fetchEvents({String? start, String? end});

  Future<EventModel> createEvent(EventModel event);


  Future<EventModel> updateEvent(EventModel event);


  Future<bool> deleteEvent(int id);
}