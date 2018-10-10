part of nui;

abstract class Layout {
  void perform(ViewGroup vg);
}

class LinearLayout extends Layout {
  @override
  void perform(ViewGroup vg) {
    for (int i = 0; i < vg.children.length; i++) {}
  }
}
