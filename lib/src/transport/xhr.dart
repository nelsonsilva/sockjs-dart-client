part of sockjs_client;

class AjaxBasedTransport extends BufferedSender {

  Client ri;

  Polling poll = null;

  AjaxBasedTransport(Client ri, transUrl, urlSuffix, ReceiverFactory receiverFactory, AjaxObjectFactory xhrFactory) {
    this.ri = ri;
    this.transUrl = transUrl;
    sendConstructor(createAjaxSender(xhrFactory));
    this.poll = new Polling(ri, receiverFactory, "$transUrl$urlSuffix", xhrFactory);
  }

  doCleanup() {
    if (poll != null) {
        poll.abort();
        poll = null;
    }
  }
}

// xhr-streaming

class XhrStreamingTransport extends AjaxBasedTransport {

  XhrStreamingTransport(ri, transUrl) :
    super(ri, transUrl, '/xhr_streaming', XhrReceiverFactory, XHRCorsObjectFactory);

  static create(ri, transUrl, [baseUrl]) => new XhrStreamingTransport(ri, transUrl);

  static bool get enabled {
    return true;
    // Support for CORS Ajax aka Ajax2? Opera 12 claims CORS but
    // doesn't do streaming.
    //return (_window.XMLHttpRequest &&
    //        'withCredentials' in new XMLHttpRequest() &&
    //        (!/opera/i.test(navigator.userAgent)));
  }

  static const roundTrips = 2; // preflight, ajax

  // Safari gets confused when a streaming ajax request is started
  // before onload. This causes the load indicator to spin indefinetely.
  static const needBody = true;


}

// According to:
//   http://stackoverflow.com/questions/1641507/detect-browser-support-for-cross-domain-xmlhttprequests
//   http://hacks.mozilla.org/2009/07/cross-site-xmlhttprequest-with-cors/


/* xdr-streaming
var XdrStreamingTransport = SockJS['xdr-streaming'] = function(ri, trans_url) {
    this.run(ri, trans_url, '/xhr_streaming', XhrReceiver, utils.XDRObject);
};

XdrStreamingTransport.prototype = new AjaxBasedTransport();

XdrStreamingTransport.enabled = function() {
    return !!_window.XDomainRequest;
};
XdrStreamingTransport.roundTrips = 2; // preflight, ajax

*/

/* xhr-polling
var XhrPollingTransport = SockJS['xhr-polling'] = function(ri, trans_url) {
    this.run(ri, trans_url, '/xhr', XhrReceiver, utils.XHRCorsObject);
};

XhrPollingTransport.prototype = new AjaxBasedTransport();

XhrPollingTransport.enabled = XhrStreamingTransport.enabled;
XhrPollingTransport.roundTrips = 2; // preflight, ajax


// xdr-polling
var XdrPollingTransport = SockJS['xdr-polling'] = function(ri, trans_url) {
    this.run(ri, trans_url, '/xhr', XhrReceiver, utils.XDRObject);
};

XdrPollingTransport.prototype = new AjaxBasedTransport();

XdrPollingTransport.enabled = XdrStreamingTransport.enabled;
XdrPollingTransport.roundTrips = 2; // preflight, ajax*/
