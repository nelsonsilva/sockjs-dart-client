part of sockjs_client;

class ReceiverEvents extends event.Events {
  event.ListenerList get message => this["message"];
  event.ListenerList get close => this["close"];
}

class Receiver implements event.Emitter<ReceiverEvents> {
  ReceiverEvents on = new ReceiverEvents();
}

typedef Receiver ReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory);