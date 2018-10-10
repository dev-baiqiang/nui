part of nui;

class TweenAnimation {
  Duration duration = new Duration(milliseconds: 300);
  Duration passed = new Duration();
  int loop = 1;
  bool animating = false;
  View view;
  DateTime startTime;

  void start() {
    animating = true;
    startTime = DateTime.now();
    WindowManager.getInstance().addFrameCallback(_tick);
    WindowManager.getInstance().scheduleFrame();
  }

  void _tick(Duration duration) {
    passed = DateTime.now().difference(startTime);
    WindowManager.getInstance().scheduleFrame();
  }

  void stop() {
    animating = false;
    WindowManager.getInstance().removeFrameCallback(_tick);
  }

  void restart() {
    stop();
    restart();
  }
}

class PositionAnimation extends TweenAnimation {
  double fromLeft;
  double toLeft;
  double fromTop;
  double toTop;
  VoidCallback _completeCallback;

  @override
  void start() {
    if (toLeft != null) {
      view.left = fromLeft ?? view.left;
      fromLeft = view.left;
    }
    if (toTop != null) {
      view.top = fromTop ?? view.top;
      fromTop = view.top;
    }

    super.start();
  }

  iteration(Duration duration) {
    if (loop-- == 0) {
      stop();
      if (_completeCallback != null) {
        _completeCallback();
      }
    } else {
      startTime = DateTime.now();
      passed = new Duration();
    }
  }

  @override
  void _tick(Duration d) {
    super._tick(d);
    double delta = passed.inMilliseconds.toDouble() / duration.inMilliseconds;
    if (fromLeft != null) {
      view.left = fromLeft + delta * (toLeft - fromLeft);
    }
    if (toTop != null) {
      view.top = fromTop + delta * (toLeft - fromLeft);
    }

    if (passed.compareTo(duration) >= 0) {
      iteration(duration);
    }
  }

  set onComplete(VoidCallback callback) {
    _completeCallback = callback;
  }
}
