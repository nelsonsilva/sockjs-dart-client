part of sockjs_client;

class Receiver extends Object with event.Emitter {
  Stream get onMessage => this["message"];
  Stream get onClose => this["close"];
}

typedef Receiver ReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory);