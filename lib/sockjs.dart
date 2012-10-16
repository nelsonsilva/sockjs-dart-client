#library("sockjs-client");

#import("dart:html");
#import("dart:json");
#import("dart:isolate");

#import("src/events.dart", prefix:'event');
#import("src/utils.dart", prefix:'utils');

#source("src/ajax.dart");
#source("src/client.dart");
#source("src/info.dart");
#source("src/transport/polling.dart");
#source("src/transport/sender.dart");
#source("src/transport/receiver.dart");
#source("src/transport/receiver-xhr.dart");
#source("src/transport/websocket.dart");
#source("src/transport/xhr.dart");

const version  = "<!-- version -->";

const CONNECTING = 0;
const OPEN = 1;
const CLOSING = 2;
const CLOSED = 3;

typedef TransformFactory(Client client, String transUrl, [String baseUrl]);

class Protocol {
  TransformFactory create;
  bool enabled;
  num roundTrips;
  bool needBody;
  Protocol({this.create, this.enabled: true, this.roundTrips: 1, this.needBody: false});
}

// Keep dart2js happy ... no lazy initialization.
Map<String, Protocol> _protocols; 

get PROTOCOLS {
  if(_protocols == null) {
    _protocols = {
      "websocket": new Protocol(create:WebSocketTransport.create, enabled: WebSocketTransport.enabled, roundTrips: WebSocketTransport.roundTrips),
      "xhr-streaming": new Protocol(create:XhrStreamingTransport.create, enabled: XhrStreamingTransport.enabled, roundTrips: XhrStreamingTransport.roundTrips)
    };
  }
  return _protocols;
}