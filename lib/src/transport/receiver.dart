part of sockjs_client;

class Receiver extends Object with event.Emitter {
  Stream get message => this["message"];
  Stream get close => this["close"];
}

typedef Receiver ReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory);