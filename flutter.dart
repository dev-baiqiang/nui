import 'package:flutter/material.dart';

void flutterMain() {
  runApp(new FlutterView());
}

class FlutterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new TextState();
  }
}

class TextState extends State<StatefulWidget> {
  String text = '';

  void handleClick() {
    print('click!!!');
    debugDumpLayerTree();
    // ui.window.scheduleFrame();
    setState(() {
      text += 'click~';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 300.0,
      height: 200.0,
      decoration: new BoxDecoration(color: Colors.blue),
      padding: const EdgeInsets.all(100.0),
        child: GestureDetector(
          onTap: handleClick,
          child: new Directionality(
            textDirection: TextDirection.ltr,
            child: new Text(
              'TEXT: $text',
            ),
          ),
        )
    );
  }
}
