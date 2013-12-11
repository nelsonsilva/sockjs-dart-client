library sockjs_client;

import "dart:html";
import "dart:convert";
import "dart:async";
import "dart:js";

import "src/events.dart" as event;
import "src/utils.dart" as utils;

part "src/ajax.dart";
part "src/client.dart";
part "src/info.dart";
part "src/transport/polling.dart";
part "src/transport/sender.dart";
part "src/transport/receiver.dart";
part "src/transport/receiver-xhr.dart";
part "src/transport/websocket.dart";
part "src/transport/xhr.dart";

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

Map<String, Protocol> PROTOCOLS = {
  "websocket": new Protocol(create:WebSocketTransport.create, enabled: WebSocketTransport.enabled, roundTrips: WebSocketTransport.roundTrips),
  "xhr-streaming": new Protocol(create:XhrStreamingTransport.create, enabled: XhrStreamingTransport.enabled, roundTrips: XhrStreamingTransport.roundTrips)
};