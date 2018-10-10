part of nui;

class View extends ChangeNotifier {
  double top = 0.0;
  double left = 0.0;
  double width = 0.0;
  double height = 0.0;
  int _background = 0x00000000;
  int depth = 0;
  bool valid = false;
  String id;
  double radius = 0.0;
  VoidCallback _tapCallback;

  Size get size {
    return new Size(width, height);
  }

  Offset get offset {
    return new Offset(left, top);
  }

  set background(int value) {
    if (value != _background) {
      invalidate();
      _background = value;
    }
  }

  get background {
    return _background;
  }

  set right(value) {
    left = value - width;
  }

  get right {
    return left + width;
  }

  set bottom(value) {
    top = value - height;
  }

  get bottom {
    return top + height;
  }

  paint(Canvas canvas, Offset po) {
    if (radius != 0.0) {
      canvas.drawRRect(
          new RRect.fromRectAndRadius(
              (po + offset) & size, Radius.circular(radius)),
          new Paint()..color = new Color(background));
    } else {
      canvas.drawRect(
          (po + offset) & size, new Paint()..color = new Color(background));
    }
    valid = true;
  }

  void invalidate() {
    valid = false;
  }

  View findViewById(String id) {
    if (this.id == id) {
      return this;
    }
    return null;
  }

  set onTap(VoidCallback callback) {
    _tapCallback = callback;
  }

  bool containsPoint(double x, double y) {
    x -= left;
    y -= top;
    return (x <= width && y <= height && x >= 0 && y >= 0);
  }

  View findViewByOffset(double x, double y) {
    if (x <= width && y <= height && x >= 0 && y >= 0) {
      return this;
    } else {
      return null;
    }
  }

  void onTouch(TouchEvent event) {
    if (event.eventPhase == EventPhase.Bubble) {
      if (event.change == PointerChange.down) {
        SessionManager.getInstance().beginSession(this);
      }
      SessionManager.getInstance().addPoint(this, event);
      if (event.change == PointerChange.up ||
          event.change == PointerChange.cancel) {
        SessionManager.getInstance().endSession(this);
      }
    }
  }
}

class TextView extends View {
  String text;

  @override
  paint(ui.Canvas canvas, Offset po) {
    super.paint(canvas, po);
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(new ui.ParagraphStyle(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        fontSize: 20.0));
    builder.addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(paragraph, offset);
  }
}

class ImageView extends View {
  Image image;
  String _uri;
  static const String TAG = 'ImageView';

  get uri {
    return _uri;
  }

  set uri(String path) {
    _uri = path;
    _loadAsync(path).then<Image>((Image i) {
      image = i;
    });
  }

  Future<Image> _loadAsync(String uri) async {
    print('$TAG: _loadAsync: $uri');
    File f = new File(uri);
    List<int> data = await f.readAsBytes();
    Codec codec = await ui.instantiateImageCodec(data);

    final int frameCount = codec.frameCount;
    final List<ui.FrameInfo> frameInfos = new List<ui.FrameInfo>(frameCount);
    for (int i = 0; i < frameCount; i += 1) {
      frameInfos[i] = await codec.getNextFrame();
      return frameInfos[i].image;
    }
    return null;
  }

  @override
  paint(ui.Canvas canvas, Offset po) {
    super.paint(canvas, po);
    if (image != null) {
      canvas.drawImageRect(
          image,
          Offset.zero &
              new Size(image.width.toDouble(), image.height.toDouble()),
          (po + offset) & size,
          new Paint());
    }
  }
}

class ViewGroup extends View {
  List<View> children = new List<View>();
  Layout layout;

  @override
  paint(Canvas canvas, Offset po) {
    super.paint(canvas, po);

    for (int i = 0; i < children.length; i++) {
      View v = children[i];
      v.paint(canvas, po + offset);
    }
  }

  void performLayout() {
    if (layout != null) {
      layout.perform(this);
    }
    for (int i = 0; i < children.length; i++) {
      View v = children[i];
      if (v is ViewGroup) {
        v.performLayout();
      }
    }
  }

  void addChild(View v) {
    children.add(v);
    v.depth = depth++;
  }

  @override
  View findViewById(String id) {
    if (id == this.id) {
      return this;
    }
    for (int i = 0; i < children.length; i++) {
      View v = children[i].findViewById(id);
      if (v != null) {
        return v;
      }
    }
    return null;
  }

  View findDirectChildByOffset(double x, double y) {
    View result;
    for (int i = this.children.length - 1; i >= 0; i--) {
      View child = this.children[i];
      if (child.containsPoint(x, y)) {
        if (result == null) {
          result = child;
        }
      }
    }
    return result;
  }

  @override
  View findViewByOffset(double x, double y) {
    View foundThis = super.findViewByOffset(x, y);
    View foundChild;
    if (foundThis != null) {
      foundChild = findDirectChildByOffset(x, y);
      if (foundChild != null) {
        x -= foundChild.left;
        y -= foundChild.top;
        foundChild = foundChild.findViewByOffset(x, y);
      }
    }
    return foundChild != null ? foundChild : foundThis;
  }
}

class ScrollView extends ViewGroup {
  double contentY = 0.0;
  double _startScrollY;

  @override
  paint(ui.Canvas canvas, Offset po) {
    canvas.save();
    canvas.clipRect(
      (po + offset) & size,
    );
    super.paint(canvas, po);
    canvas.restore();
  }

  @override
  void performLayout() {
    super.performLayout();
    for (int i = 0; i < children.length; i++) {
      View v = children[i];
      v.left = 0.0;
      if (i == 0) {
        v.top = -contentY;
        continue;
      }
      View pv = children[i - 1];
      v.top = pv.bottom;
    }
  }

  @override
  void onTouch(TouchEvent event) {
    super.onTouch(event);
    if (event.change == PointerChange.down) {
      this._startScrollY = event.offset.dy;
    }
    if (event.change == PointerChange.move) {
      this.contentY -= event.offset.dy - this._startScrollY;
      this._startScrollY = event.offset.dy;
    }
  }
}

class Window extends ViewGroup {
  void dispatchTouchEvents(TouchData touch) {
    List<View> chain = new List<View>();
    View v = this;
    double x = touch.offset.dx;
    double y = touch.offset.dy;
    if (this.containsPoint(x, y)) {
      chain.add(this);
    } else {
      return;
    }
    while (v != null) {
      x -= v.left;
      y -= v.top;
      View child;
      if (v is ViewGroup) {
        child = v.findDirectChildByOffset(x, y);
      }
      if (child != null) {
        chain.add(child);
        v = child;
      } else {
        break;
      }
    }
    EventPhase phase = EventPhase.Capture;
    for (int i = 0; i < chain.length; i++) {
      TouchEvent event = new TouchEvent(touch);
      event.eventPhase = phase;
      View v = chain[i];
      event.target = v;
      v.onTouch(event);
    }
    phase = EventPhase.Bubble;

    for (int i = chain.length - 1; i >= 0; i--) {
      TouchEvent event = new TouchEvent(touch);
      event.eventPhase = phase;
      View v = chain[i];
      event.target = v;
      v.onTouch(event);
    }
  }
}
