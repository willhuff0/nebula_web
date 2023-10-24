import 'dart:html';

import 'engine.dart';

export 'dart:web_gl';

late RenderingContext2 gl;

void initGraphics(CanvasElement canvas) {
  gl = canvas.getContext('webgl2', {
    "alpha": false,
    "depth": false,
    "stencil": false,
    "desynchronized": true,
    "antialias": true,
    "powerPreference": "high-performance",
    "preserveDrawingBuffer": true,
  }) as RenderingContext2;

  //final compressedTextureAstc = gl.getExtension('WEBGL_compressed_texture_astc') as CompressedTextureAstc;
}
