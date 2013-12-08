library echo;

import "dart:html";
import "dart:convert";
import "package:sockjs_client/sockjs.dart" as SockJS;

DivElement div  = querySelector('#first div');
InputElement inp  = querySelector('#first input');
FormElement form = querySelector('#first form');

print(m, [p = '']) {
  if(!p.isEmpty) {
    p = JSON.encode(p);
  }
  div.children
    ..add(new Element.html("<code/>")..text=("$m$p"))
    ..add(new Element.html("<br>"));

  div.scrollTop += 10000;
}

main() {
  print("Starting");
  var sockjs_url = 'http://127.0.0.1:8081/echo';
  var sockjs = new SockJS.Client(sockjs_url, protocolsWhitelist:['websocket', 'xhr-streaming'], debug: true);
  querySelector('#first input').focus();

  sockjs.on.open.add( (_) => print('[*] open ${sockjs.protocol}') );
  sockjs.on.message.add( (e) => print('[.] message ${e.data}') );
  sockjs.on.close.add( (_) => print('[*] close') );

  inp.onKeyUp.listen( (KeyboardEvent e) {
    if (e.keyCode == 13) {
      print('[ ] sending ${inp.value}');
      sockjs.send(inp.value);
      inp.value = '';
    }
  });

}