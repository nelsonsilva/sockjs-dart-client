class Polling {
  
  Client ri;
  var receiverFactory;
  String recvUrl;
  AjaxObjectFactory xhrFactory;
  
  var poll;
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
    poll.on.message.add(msgHandler);
    
    var closeHandler;
    closeHandler = (e) {
        poll.on.message.remove(msgHandler);
        poll.on.close.remove(closeHandler);
        poll = null;
        if (!pollIsClosing) {
            if (e.reason == 'permanent') {
                ri._didClose(1006, 'Polling error (${e.reason})');
            } else {
                _scheduleRecv();
            }
        }
     };
    poll.on.close.add(closeHandler);
  }

  abort() {
      pollIsClosing = true;
      if (poll != null) {
          poll.abort();
      }
  }
}
