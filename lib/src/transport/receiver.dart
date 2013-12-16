part of sockjs_client;

class Receiver extends events.Emitter {
  Stream get onMessage => this.streamOf("message");
  Stream get onClose => this.streamOf("close");
}

typedef Receiver ReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory);