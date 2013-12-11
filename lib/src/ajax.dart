part of sockjs_client;

class StatusEvent extends event.Event {
  int status;
  String text;
  StatusEvent(String type, [this.status = 0, this.text = ""]) : super(type);
}

typedef AbstractXHRObject AjaxObjectFactory(String method, String baseUrl, [payload]);

class AbstractXHRObject extends Object with event.Emitter {

  HttpRequest xhr;
  StreamSubscription changeSubscription;

  Stream get onChunk => this["chunk"];
  Stream get onFinish => this["finish"];
  Stream get onTimeout => this["timeout"];

  _start(method, url, payload, {noCredentials: false, headers}) {

    try {
        xhr = new HttpRequest();
    } catch(x) {};

    if ( xhr == null ) {
        try {
            // TODO(nelsonsilva) - xhr = new window['ActiveXObject']('Microsoft.XMLHTTP');
        } catch(x) {};
    }
    // TODO(nelsonsilva)
    //if ( window['ActiveXObject'] != null || window['XDomainRequest'] != null) {
        // IE8 caches even POSTs
    //    url += ((url.indexOf('?') === -1) ? '?' : '&') + 't='+(+new Date);
    //}

    // Explorer tends to keep connection open, even after the
    // tab gets closed: http://bugs.jquery.com/ticket/5280
    //that.unload_ref = utils.unload_add(function(){that._cleanup(true);});

    try {
        xhr.open(method, url);
    } catch(e) {
        // IE raises an exception on wrong port.
        dispatch(new StatusEvent("finish"));
        _cleanup();
        return;
    };

    if (!noCredentials) {
        // Mozilla docs says https://developer.mozilla.org/en/XMLHttpRequest :
        // "This never affects same-site requests."
        xhr.withCredentials = true;
    }
    if (headers != null) {
        headers.forEach((k, v) => xhr.setRequestHeader(k, v));
    }

    changeSubscription = xhr.onReadyStateChange.listen(_readyStateHandler);

    xhr.send(payload);
  }

  _readyStateHandler(Event evt) {
    switch (xhr.readyState) {
      case 3:
        var text, status;
        // IE doesn't like peeking into responseText or status
        // on Microsoft.XMLHTTP and readystate=3
        try {
          status = xhr.status;
          text = xhr.responseText;
        } catch (x) {};
        // IE does return readystate == 3 for 404 answers.
        if (text != null && !text.isEmpty) {
          dispatch(new StatusEvent("chunk", status, text));
        }
        break;
      case 4:
        dispatch(new StatusEvent("finish", xhr.status, xhr.responseText));
        _cleanup(false);
        break;
    }
  }

  _cleanup([abort = false]) {

    if (xhr == null) return;
    // utils.unload_del(that.unload_ref);

    // IE needs this field to be a function
    changeSubscription.cancel();

    if (abort) {
        try {
            xhr.abort();
        } catch(x) {};
    }
    //that.unload_ref = that.xhr = null;
}

  close() {
    // TODO(nelsonsilva) - nuke();
    _cleanup(true);
  }
}

class XHRCorsObject extends AbstractXHRObject {
   XHRCorsObject(method, url, payload, {noCredentials, headers} )  {
    Timer.run(() =>_start(method, url, payload, noCredentials: false));
   }
}



class XHRLocalObject extends AbstractXHRObject {
  XHRLocalObject (method, url, payload, {noCredentials, headers}) {
    Timer.run(() =>_start(method, url, payload, noCredentials: true));
    }
}

XHRLocalObjectFactory(method, baseUrl, [payload]) => new XHRLocalObject(method, baseUrl, payload);

XHRCorsObjectFactory(method, baseUrl, [payload]) => new XHRCorsObject(method, baseUrl, payload);

// 1. Is natively via XHR
// 2. Is natively via XDR
// 3. Nope, but postMessage is there so it should work via the Iframe.
// 4. Nope, sorry.
isXHRCorsCapable() {
    return 1;

    /*
    if (window["XMLHttpRequest"] != null && window["'withCredentials' in new XMLHttpRequest()) {
        return 1;
    }
    // XDomainRequest doesn't work if page is served from file://
    if (_window.XDomainRequest && _document.domain) {
        return 2;
    }
    if (IframeTransport.enabled()) {
        return 3;
    }
    return 4;*/
}
