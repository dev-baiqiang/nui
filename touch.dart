part of nui;

class TouchData {
  TouchData({this.offset, this.timeStamp, this.change});

  Offset offset;
  Duration timeStamp;
  PointerChange change;
}

enum EventPhase { Capture, Bubble }

class TouchEvent extends TouchData {
  View target;
  EventPhase eventPhase;

  TouchEvent(TouchData touch)
      : super(
            offset: touch.offset,
            timeStamp: touch.timeStamp,
            change: touch.change);

  @override
  String toString() {
    return 'TouchEvent: $runtimeType; offset: $offset, change: $change, phase: $eventPhase, timeStamp: $timeStamp';
  }
}

class SessionManager {
  static SessionManager instance;
  static Map<View, List<TouchEvent>> _touches =
      new Map<View, List<TouchEvent>>();

  static SessionManager getInstance() {
    if (SessionManager.instance == null) {
      SessionManager.instance = new SessionManager();
    }
    return SessionManager.instance;
  }

  void beginSession(View v) {
    if (_touches[v] == null) {
      _touches[v] = new List<TouchEvent>();
    } else {
      _touches[v].clear();
    }
  }

  void addPoint(View v, TouchEvent e) {
    _touches[v].add(e);
  }

  void endSession(View v) {
    List<TouchEvent> list = _touches[v];
    int length = _touches[v].length;
    TouchEvent start = list[0];
    TouchEvent end = list[length - 1];
    double dx = end.offset.dx - start.offset.dx,
        dy = end.offset.dy - start.offset.dy;
    double distance = math.sqrt(dx * dx + dy * dy);
    if (end.timeStamp - start.timeStamp < new Duration(milliseconds: 150) &&
        distance < 25) {
      if (v._tapCallback != null) {
        v._tapCallback();
      }
    }
  }
}
