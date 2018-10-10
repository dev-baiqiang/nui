part of nui;

typedef FrameCallback = void Function(Duration duration);

class WindowManager {
  double devicePixelRatio;
  ui.Size physicalSize;
  ui.Size logicalSize;
  ui.Canvas canvas;

  List<Window> windows = new List<Window>();
  List<FrameCallback> callbacks = new List<FrameCallback>();
  List<TouchData> touches = new List<TouchData>();
  List<PictureLayer> layers = new List<PictureLayer>();

  WindowManager() {
    this.devicePixelRatio = ui.window.devicePixelRatio;
    this.physicalSize = ui.window.physicalSize;
    this.logicalSize = physicalSize / devicePixelRatio;

    // print("this.logicalSize, ${this.logicalSize}"); Size(360.0, 672.0)
    // print("this.physicalSize, ${this.physicalSize}"); Size(1080.0, 2016.0)

    ui.window.onBeginFrame = _handleBeginFrame;
    ui.window.onDrawFrame = _handleDrawFrame;
    ui.window.onPointerDataPacket = _handlePointerDataPacket;
  }

  static WindowManager instance;

  ui.Rect get physicalBounds {
    return ui.Offset.zero & physicalSize;
  }

  static WindowManager getInstance() {
    if (WindowManager.instance == null) {
      WindowManager.instance = new WindowManager();
    }
    return WindowManager.instance;
  }

  get mainWindow {
    return windows[0];
  }

  void _handleBeginFrame(Duration duration) {
    // print('begin frame: ${duration.toString()}');
    for (int i = 0; i < callbacks.length; i++) {
      callbacks[i](duration);
    }
  }

  void _handleDrawFrame() {
    // print('_handleDrawFrame');

    final ui.PictureRecorder recorder = new ui.PictureRecorder();
    canvas = new ui.Canvas(recorder, physicalBounds);
    canvas.scale(devicePixelRatio, devicePixelRatio);

    for (int i = 0; i < windows.length; i++) {
      windows[i].performLayout();
    }

    for (int i = 0; i < windows.length; i++) {
      windows[i].paint(canvas, ui.Offset.zero);
    }

    final ui.Picture picture = recorder.endRecording();

    final ui.SceneBuilder sceneBuilder = new ui.SceneBuilder()
      ..pushClipRect(physicalBounds)
      ..addPicture(ui.Offset.zero, picture)
      ..pop();
    ui.Scene scene = sceneBuilder.build();
    ui.window.render(scene);
    scene.dispose();
    // ui.window.scheduleFrame();
  }

  void addWindow(Window win) {
    windows.add(win);
  }

  void _handlePointerDataPacket(PointerDataPacket packet) {
    print("touch_debug: begin_handlePointerDataPacket");
    for (ui.PointerData datum in packet.data) {
      final Offset position =
          new Offset(datum.physicalX, datum.physicalY) / devicePixelRatio;
      final Duration timeStamp = datum.timeStamp;
      final PointerDeviceKind kind = datum.kind;
      final PointerChange change = datum.change;

      print(
          "touch_debug: pos:${position.toString()};kind:${kind.toString()}; time:${timeStamp.toString()};change:${change.toString()}");

      if (kind == PointerDeviceKind.touch) {
        dispatchTouchEvents(new TouchData(
            offset: position, timeStamp: timeStamp, change: change));
      }

      if (change == PointerChange.up || change == PointerChange.cancel) {
        touches.clear();
      }
    }
    print("touch_debug: end_handlePointerDataPacket");

    ui.window.scheduleFrame();
  }

  void addFrameCallback(FrameCallback callback) {
    callbacks.add(callback);
  }

  void scheduleFrame() {
    ui.window.scheduleFrame();
  }

  void removeFrameCallback(FrameCallback callback) {
    callbacks.remove(callback);
  }

  void dispatchTouchEvents(TouchData touch) {
    for (int i = 0; i < windows.length; i++) {
      windows[i].dispatchTouchEvents(touch);
    }
  }
}
