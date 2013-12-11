library events;

import "dart:async";

class Event {
  String type;
  Event(this.type);
}

class Emitter {

  final _evtController = new StreamController<Event>.broadcast();

  Stream<Event> operator[] (type) => _evtController.stream.where((e) => e.type == type);

  dispatch(evtOrType) {
    var evt = (evtOrType is String) ? new Event(evtOrType) : evtOrType;
    _evtController.add(evt);
  }
}