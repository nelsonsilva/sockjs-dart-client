part of sockjs_client;

class BufferedSender {
  var sendBuffer;
  var sender;

  var sendStop = null;
  var _sendStop;

  var transUrl;

  sendConstructor(sender) {
    sendBuffer = [];
    this.sender = sender;
  }

  doSend(message) {
    sendBuffer.add(message);
    if (sendStop == null) {
        sendSchedule();
    }
  }

    /** For polling transports in a situation when in the message callback,
    // new message is being send. If the sending connection was started
    // before receiving one, it is possible to saturate the network and
    // timeout due to the lack of receiving socket. To avoid that we delay
    // sending messages by some small time, in order to let receiving
    // connection be started beforehand. This is only a halfmeasure and
    // does not fix the big problem, but it does make the tests go more
    // stable on slow networks. */
    sendScheduleWait() {
        var tref;
        sendStop = () {
            sendStop = null;
            tref.cancel();
        };
        tref = new Timer(new Duration(milliseconds:25), () {
            sendStop = null;
            sendSchedule();
        });
    }

  sendSchedule() {
    if (!sendBuffer.isEmpty) {
        var payload = '[${sendBuffer.join(',')}]';
        sendStop = sender(transUrl,
                           payload,
                           ([status, reason]) {
                               sendStop = null;
                               sendScheduleWait();
                           });
        sendBuffer = [];
    }
  }

  sendDestructor() {
    if (_sendStop != null) {
        _sendStop();
    }
    _sendStop = null;
  }
}

createAjaxSender(AjaxObjectFactory xhrFactory)
    => (url, payload, callback([status, reason])) {
        AbstractXHRObject xo = xhrFactory('POST', '$url/xhr_send', payload);
        xo.on.finish.add((e) {
            callback(e.status);
        });
        return (abort_reason) {
            callback(0, abort_reason);
        };
    };