import 'package:flutter_demo/canvas.dart';
import 'package:flutter_demo/flutter.dart';

import 'demo.dart';

void main() {
  bool nui = true;
  bool flutter = false;
  if (nui) {
    nuiMain();
  } else if (flutter) {
    flutterMain();
  } else {
    canvasMain();
  }
}
