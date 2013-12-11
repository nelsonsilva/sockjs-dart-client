library echo;

import "dart:html";
import 'package:logging/logging.dart';
import "package:sockjs_client/sockjs.dart" as SockJS;

DivElement div  = querySelector('#first div');
InputElement inp  = querySelector('#first input');
FormElement form = querySelector('#first form');

_log(LogRecord l) {
  div
    ..append(new Element.html("<code/>")..text = "${l.message}")
    ..append(new Element.html("<br>"))
    ..scrollTop += 10000;
}

main() {
  // Setup Logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(_log);

  final LOG = new Logger("sockjs");

  LOG.info("Starting");
  var sockjs_url = 'http://127.0.0.1:8081/echo';
  var sockjs = new SockJS.Client(sockjs_url, protocolsWhitelist:['websocket', 'xhr-streaming'], debug: true);
  querySelector('#first input').focus();

  sockjs.onOpen.listen( (_) => LOG.info('[*] open ${sockjs.protocol}') );
  sockjs.onMessage.listen( (e) => LOG.info('[.] message ${e.data}') );
  sockjs.onClose.listen( (_) => LOG.info('[*] close') );

  inp.onKeyUp.listen( (KeyboardEvent e) {
    if (e.keyCode == 13) {
      LOG.info('[ ] sending ${inp.value}');
      sockjs.send(inp.value);
      inp.value = '';
    }
  });

}