part of sockjs_client;

 class XhrReceiver extends Receiver {

   AbstractXHRObject xo = null;

   XhrReceiver(url, AjaxObjectFactory xhrFactory) {
    var buf_pos = 0;

    xo = xhrFactory('POST', url);
    xo.onChunk.listen((e){
        if (e.status != 200) return;
        while (true) {
            var buf = e.text.substring(buf_pos);
            var p = buf.indexOf('\n');
            if (p == -1) break;
            buf_pos += p+1;
            var msg = buf.substring(0, p);
            dispatch(new MessageEvent(msg));
        }
    });
    xo.onFinish.listen((e) {
        dispatch(new StatusEvent("chunk", e.status, e.text));
        xo = null;
        var reason = (e.status == 200) ? 'network' : 'permanent';
        dispatch(new CloseEvent(reason: reason));
    });
  }

  abort() {
    if (xo != null) {
        xo.close();
        dispatch(new CloseEvent(reason: 'user'));
        xo = null;
    }
  }
}

XhrReceiverFactory(String recvUrl, AjaxObjectFactory xhrFactory) => new XhrReceiver(recvUrl, xhrFactory);
