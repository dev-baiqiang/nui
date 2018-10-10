part of nui;

abstract class Layer {
  void addToScene(ui.SceneBuilder builder, ui.Offset layerOffset);
}

class PictureLayer extends Layer {
  ui.Picture picture;
  bool willChangeHint = false;
  bool isComplexHint = false;


  @override
  void addToScene(ui.SceneBuilder builder, ui.Offset layerOffset) {
    builder.addPicture(layerOffset, picture,
        isComplexHint: isComplexHint, willChangeHint: willChangeHint);
  }
}
