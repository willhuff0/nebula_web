import 'dart:html';

import 'lib/engine.dart';

void main() {
  final canvas = querySelector('#nebula-canvas') as CanvasElement?;
  if (canvas == null) {
    nlog('Failed to find nebula canvas');
    return;
  }

  initGraphics(canvas);
}
