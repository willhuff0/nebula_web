import 'dart:html';

import 'engine.dart';

export 'dart:web_gl';

late RenderingContext2 gl;

late int maxAnisotropy;

void initGraphics(CanvasElement canvas) {
  gl = canvas.getContext('webgl2', {
    "alpha": false,
    "depth": true,
    "stencil": false,
    "desynchronized": true,
    "antialias": true,
    "powerPreference": "high-performance",
    "preserveDrawingBuffer": true,
  }) as RenderingContext2;

  gl.enable(WebGL.DEPTH_TEST);

  if (gl.getExtension('EXT_texture_compression_bptc') == null) {
    nlog('Failed to load required WebGL2 extension (EXT_texture_compression_bptc)');
    return;
  }

  if (gl.getExtension('EXT_texture_filter_anisotropic') == null) {
    nlog('Failed to load required WebGL2 extension (EXT_texture_filter_anisotropic)');
    return;
  }
  maxAnisotropy = gl.getParameter(ExtTextureFilterAnisotropic.MAX_TEXTURE_MAX_ANISOTROPY_EXT) as int;
}
