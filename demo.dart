import 'nui.dart';

class ScrollItem extends View {
  ScrollItem(int i) : super() {
    String color = 'FF00$i$i$i$i';
    this.background = int.parse(color, radix: 16);
    this.width = 200.0;
    this.height = 50.0;
  }
}

void handleTap() {
  print("ImageView onClick");
}

void nuiMain() {
  WindowManager wm = WindowManager.getInstance();

  Window mainWindow = new Window();
  mainWindow.width = wm.logicalSize.width;
  mainWindow.height = wm.logicalSize.height;
  mainWindow.background = 0x000000;
  wm.addWindow(mainWindow);

  View v = new View();
  v.id = "v";
  v.width = 100.toDouble();
  v.height = 100.toDouble();
  v.top = 200.0;
  v.background = 0xFFFFFFFF;

  View v2 = new View();
  v2.width = 100.toDouble();
  v2.height = 100.toDouble();
  v2.background = 0x77FFFF77;
  v2.top = 100.0;
  v2.left = -100.0;
  v2.radius = 10.0;

  PositionAnimation pa = new PositionAnimation();
  pa.view = v2;
  pa.toLeft = 400.0;
  pa.duration = new Duration(milliseconds: 2000);
  pa.loop = -1;
  pa.start();

  TextView tv = new TextView();
  tv.width = 200.0;
  tv.height = 100.toDouble();
  tv.top = 400.0;
  tv.background = 0xFF00FF77;
  tv.text = "BaiQiang";

  ImageView iv = new ImageView();
  iv.uri = "/storage/emulated/0/wallpaper/wallpaper_3_0_default_02.jpg";
  iv.width = 108.0;
  iv.height = 192.0;
  iv.left = 200.0;
  iv.top = 500.0;
  iv.background = 0xFF000077;
  iv.onTap = handleTap;

  ScrollView sv = new ScrollView();
  sv.top = 100.0;
  sv.width = 200.0;
  sv.right = mainWindow.right;
  sv.height = 350.0;
  sv.background = 0xFFFFFFFF;
  sv.id = "sv";

  for (int i = 2; i < 10; i++) {
    sv.addChild(new ScrollItem(i));
  }

  mainWindow.addChild(sv);
  mainWindow.addChild(v);
  mainWindow.addChild(v2);
  mainWindow.addChild(tv);
  mainWindow.addChild(iv);
}
