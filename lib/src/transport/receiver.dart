class ReceiverEvents extends event.Events {
  get message() => this["message"];
  get close() => this["close"];
}
        
class Receiver implements event.Emitter<ReceiverEvents> {
  ReceiverEvents on = new ReceiverEvents();
}
  
typedef Receiver ReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory);