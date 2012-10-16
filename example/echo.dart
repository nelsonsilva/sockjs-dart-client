#library("echo");

#import("dart:html");
#import("dart:json");
#import("package:sockjs_client/sockjs.dart", prefix:'SockJS');

DivElement div  = query('#first div');
InputElement inp  = query('#first input');
FormElement form = query('#first form');

print(m, [p = '']) {
  if(!p.isEmpty())
    p = JSON.stringify(p);
  div.elements
    ..add(new Element.html("<code/>")..text=("$m$p"))
    ..add(new Element.html("<br>"));
  
  div.scrollTop += 10000;
}

main() {
  print("Starting");
  var sockjs_url = 'http://127.0.0.1:8081/echo';
  var sockjs = new SockJS.Client(sockjs_url, protocolsWhitelist:['websocket', 'xhr-streaming'], debug: true);
  query('#first input').focus();

  sockjs.on.open.add( (_) => print('[*] open ${sockjs.protocol}') );
  sockjs.on.message.add( (e) => print('[.] message ${e.data}') );
  sockjs.on.close.add( (_) => print('[*] close') );

  inp.on.keyUp.add( (KeyboardEvent e) {
    if (e.keyCode == 13) {
      print('[ ] sending ${inp.value}');
      sockjs.send(inp.value);
      inp.value = '';
    }
  });

}