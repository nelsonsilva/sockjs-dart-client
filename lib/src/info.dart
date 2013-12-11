part of sockjs_client;

class Info {
  bool websocket;
  List<String> origins;
  bool cookieNeeded;
  num entropy;
  bool nullOrigin;

  Info.fromJSON(Map json) {
    websocket = json["websocket"];
    origins = json["origins"];
    cookieNeeded = json["cookie_needed"];
    entropy = json["entropy"];
    nullOrigin = (document.domain == null);
  }
}

class InfoReceiverEvent extends event.Event {
  Info info;
  num rtt;
  InfoReceiverEvent(String type, [this.info = null, this.rtt]) : super(type);
}

abstract class InfoReceiver extends Object with event.Emitter {

  InfoReceiver._();

  Stream<event.Event> get onFinish => this["finish"];

  factory InfoReceiver.forURL(String baseUrl) {
    if (utils.isSameOriginUrl(baseUrl)) {
        // If, for some reason, we have SockJS locally - there's no
        // need to start up the complex machinery. Just use ajax.
        return new AjaxInfoReceiver(baseUrl, XHRLocalObjectFactory);
    }
    switch (isXHRCorsCapable()) {
      case 1:
          // XHRLocalObject -> no_credentials=true
          return new AjaxInfoReceiver(baseUrl, XHRLocalObjectFactory);
      case 2:
          //return new AjaxInfoReceiver(baseUrl, utils.XDRObject);
      case 3:
          // Opera
          return new InfoReceiverIframe(baseUrl);
      default:
          // IE 7
          return new InfoReceiverFake();
    }
  }
}

class AjaxInfoReceiver extends InfoReceiver {

  AjaxInfoReceiver(String baseUrl, AjaxObjectFactory xhrFactory) : super._() {
    Timer.run(() => doXhr(baseUrl, xhrFactory));
  }

  doXhr(String baseUrl, AjaxObjectFactory xhrFactory) {
    var t0 = new DateTime.now().millisecondsSinceEpoch;
    var xo = xhrFactory('GET', "$baseUrl/info");

    var tref = new Timer(new Duration(milliseconds:8000), () => dispatch("timeout"));

    xo.onFinish.listen( (StatusEvent evt) {
        tref.cancel();
        tref = null;
        if (evt.status == 200) {
            var rtt = new DateTime.now().millisecondsSinceEpoch - t0;
            var info = new Info.fromJSON(JSON.decode(evt.text));
            dispatch(new InfoReceiverEvent("finish", info, rtt));
        } else {
            dispatch(new InfoReceiverEvent("finish"));
        }
    });
    xo.onTimeout.listen( (_) {
        xo.close();
        dispatch(new InfoReceiverEvent("finish"));
    });
  }
}


class InfoReceiverIframe extends InfoReceiver {

  InfoReceiverIframe(base_url) : super._() {
    if(document.body == null) {
      document.onLoad.listen((_) => go());
    } else {
        go();
    }
  }

    go() {
      // TODO(nelsonsilva)
      /*
      var ifr = new IframeTransport();
      ifr.protocol = 'w-iframe-info-receiver';
      var fun = function(r) {
        if (typeof r === 'string' && r.substr(0,1) === 'm') {
          var d = JSON.parse(r.substr(1));
          var info = d[0], rtt = d[1];
          that.emit('finish', info, rtt);
        } else {
          that.emit('finish');
        }
        ifr.doCleanup();
        ifr = null;
      };
      var mock_ri = {
                     _options: {},
                     _didClose: fun,
                     _didMessage: fun
      };
      ifr.i_constructor(mock_ri, base_url, base_url);
      */
    }
}


class InfoReceiverFake extends InfoReceiver {

  InfoReceiverFake() : super._() {
    // It may not be possible to do cross domain AJAX to get the info
    // data, for example for IE7. But we want to run JSONP, so let's
    // fake the response, with rtt=2s (rto=6s).
    new Timer(new Duration(milliseconds:2000), () => dispatch("finish"));
  }
}


// FacadeJS['w-iframe-info-receiver']
class WInfoReceiverIframe {
  WInfoReceiverIframe(ri, _trans_url, baseUrl) {
    var ir = new AjaxInfoReceiver(baseUrl, XHRLocalObjectFactory);
    ir.onFinish.listen( (evt) {
        ri._didMessage('m${JSON.encode([evt.info, evt.rtt])}');
        ri._didClose();
    });
  }
  doCleanup() {}
}
