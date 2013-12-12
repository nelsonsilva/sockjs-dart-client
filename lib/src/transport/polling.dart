part of sockjs_client;

class Polling {

  Client ri;
  var receiverFactory;
  String recvUrl;
  AjaxObjectFactory xhrFactory;
  XhrReceiver poll;
  bool pollIsClosing = false;

  Polling(this.ri, this.receiverFactory, this.recvUrl, this.xhrFactory) {
    _scheduleRecv();
  }

  _scheduleRecv() {
    poll =  receiverFactory(recvUrl, xhrFactory);
    var msg_counter = 0;
    var msgHandler = (e) {
      msg_counter += 1;
      ri._didMessage(e.data);
    };
    var messageSubscription, closeSubscription;

    var closeHandler = (e) {
        messageSubscription.cancel();
        closeSubscription.cancel();
        poll = null;
        if (!pollIsClosing) {
            if (e.reason == 'permanent') {
                ri._didClose(1006, 'Polling error (${e.reason})');
            } else {
                _scheduleRecv();
            }
        }
     };
     messageSubscription = poll.onMessage.listen(msgHandler);
     closeSubscription = poll.onClose.listen(closeHandler);
  }

  abort() {
      pollIsClosing = true;
      if (poll != null) {
          poll.abort();
      }
  }
}
