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

/** TODO To be fixed since Dart 1.0 does not give access anymore to IFrame ReadyState and only authorize
// postMessage communication */
class JsonPGenericSender {

  FormElement _sendForm = null;
  TextAreaElement _sendArea = null;

  var completed;

  JsonPGenericSender(url, payload, callback) {
    FormElement form;
    TextAreaElement area;

    if (_sendForm == null) {
      form = _sendForm = new Element.tag('form');
      area = _sendArea = new Element.tag('textarea');
      area.name = 'd';
      form.style.display = 'none';
      form.style.position = 'absolute';
      form.method = 'POST';
      form.enctype = 'application/x-www-form-urlencoded';
      form.acceptCharset = "UTF-8";
      form.children.add(area);
      document.body.children.add(form);
    }
    form = _sendForm;
    area = _sendArea;
    var id = 'a${utils.random_string(8)}';
    form.target = id;
    form.action = '$url/jsonp_send?i=$id';

    IFrameElement iframe;
    try {
        // ie6 dynamic iframes with target="" support (thanks Chris Lambacher)
        iframe = new Element.html('<iframe name="$id">');
    } catch(x) {
        iframe = new Element.tag('iframe');
        iframe.name = id;
    }
    iframe.id = id;
    form.children.add(iframe);
    iframe.style.display = 'none';

    try {
        area.value = payload;
    } catch(e) {
        print('Your browser is seriously broken. Go home! ${e.message}');
    }
    form.submit();

    var readyStateChangeHandler = (e) {
      if (new JsObject.fromBrowserObject(iframe)["readyState"] == 'complete') completed(null);
    };

    var subscriptions;

    completed = (e) {
        if (subscriptions == null) return;
        subscriptions.forEach((s) => s.cancel());

        // Opera mini doesn't like if we GC iframe
        // immediately, thus this timeout.
        new Timer(new Duration(milliseconds: 500),() {
                       iframe.remove();
                       iframe = null;
                   });
        area.value = '';
        callback();
    };

    subscriptions = [
      iframe.onError.listen(completed),
      iframe.onLoad.listen(completed),
      iframe.on["readyStateChange"].listen(readyStateChangeHandler)
    ];

    //return completed;
  }
}

createAjaxSender(AjaxObjectFactory xhrFactory)
    => (url, payload, callback([status, reason])) {
        AbstractXHRObject xo = xhrFactory('POST', '$url/xhr_send', payload);
        xo.onFinish.listen((e) {
            callback(e.status);
        });
        return (abort_reason) {
            callback(0, abort_reason);
        };
    };