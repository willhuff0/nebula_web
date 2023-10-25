import 'dart:convert';

import '../engine.dart';

final _shaderCache = <(int start, int end), Shader>{};

class ShaderAsset extends Asset {
  final DataReference vertexData;
  final DataReference fragmentData;

  ShaderAsset._(super.database, super.uuid, {required this.vertexData, required this.fragmentData});

  @override
  Future<void> importLookupReferences() async {}

  late final Program _program;

  late final Map<String, (int type, UniformLocation location)> _uniforms;

  @override
  Future<void> importBuffer() async {
    final vertexKey = (vertexData.start, vertexData.end);
    var vertexShader = _shaderCache[vertexKey];
    if (vertexShader == null) {
      final shaderSource = utf8.decode(vertexData.get(database));

      vertexShader = gl.createShader(WebGL.VERTEX_SHADER);
      gl.shaderSource(vertexShader, shaderSource);
      gl.compileShader(vertexShader);

      if (DEBUG) {
        if (gl.getShaderParameter(vertexShader, WebGL.COMPILE_STATUS) as bool == false) {
          final infoLog = gl.getShaderInfoLog(vertexShader);
          nerror('Vertex shader failed to compile ($uuid): $infoLog');
          return;
        }
      }

      _shaderCache[vertexKey] = vertexShader;
    }

    final fragmentKey = (fragmentData.start, fragmentData.end);
    var fragmentShader = _shaderCache[fragmentKey];
    if (fragmentShader == null) {
      final shaderSource = utf8.decode(fragmentData.get(database));

      fragmentShader = gl.createShader(WebGL.FRAGMENT_SHADER);
      gl.shaderSource(fragmentShader, shaderSource);
      gl.compileShader(fragmentShader);

      if (DEBUG) {
        if (gl.getShaderParameter(fragmentShader, WebGL.COMPILE_STATUS) as bool == false) {
          final infoLog = gl.getShaderInfoLog(fragmentShader);
          nerror('Fragment shader failed to compile ($uuid): $infoLog');
          return;
        }
      }

      _shaderCache[fragmentKey] = fragmentShader;
    }

    _program = gl.createProgram();
    gl.attachShader(_program, vertexShader);
    gl.attachShader(_program, fragmentShader);
    gl.linkProgram(_program);

    if (DEBUG) {
      if (gl.getProgramParameter(_program, WebGL.LINK_STATUS) as bool == false) {
        final infoLog = gl.getProgramInfoLog(_program);
        nerror('Program failed to link ($uuid): $infoLog');
        return;
      }
    }

    final numUniforms = gl.getProgramParameter(_program, WebGL.ACTIVE_UNIFORMS) as int;
    for (var i = 0; i < numUniforms; i++) {
      final info = gl.getActiveUniform(_program, i);
      final name = info.name;
      final type = info.type;
      final location = gl.getUniformLocation(_program, name);
      _uniforms[name] = (type, location);
    }
  }

  void bind() {
    gl.useProgram(_program);
  }

  void setParameters(Map<String, dynamic> parameters) {
    parameters.forEach((name, value) {
      final uniform = _uniforms[name];
      if (uniform == null) return;

      final type = uniform.$1;
      final location = uniform.$2;
      switch (type) {
        case WebGL.FLOAT:
          final v = value as double;
          gl.uniform1f(location, v);
          break;
        case WebGL.FLOAT_VEC2:
          final v = value as List<double>;
          gl.uniform2f(location, v[0], v[1]);
          break;
        case WebGL.FLOAT_VEC3:
          final v = value as List<double>;
          gl.uniform3f(location, v[0], v[1], v[2]);
          break;
        case WebGL.FLOAT_VEC4:
          final v = value as List<double>;
          gl.uniform4f(location, v[0], v[1], v[2], v[3]);
          break;

        case WebGL.INT:
          final v = value as int;
          gl.uniform1i(location, v);
          break;
        case WebGL.INT_VEC2:
          final v = value as List<int>;
          gl.uniform2i(location, v[0], v[1]);
          break;
        case WebGL.INT_VEC3:
          final v = value as List<int>;
          gl.uniform3i(location, v[0], v[1], v[2]);
          break;
        case WebGL.INT_VEC4:
          final v = value as List<int>;
          gl.uniform4i(location, v[0], v[1], v[2], v[3]);
          break;

        case WebGL.BOOL:
          final v = value as bool;
          gl.uniform1i(location, v ? 1 : 0);
          break;

        case WebGL.FLOAT_MAT2:
          final v = value as List<double>;
          gl.uniformMatrix2fv(location, false, v);
          break;
        case WebGL.FLOAT_MAT3:
          final v = value as List<double>;
          gl.uniformMatrix3fv(location, false, v);
          break;
        case WebGL.FLOAT_MAT4:
          final v = value as List<double>;
          gl.uniformMatrix4fv(location, false, v);
          break;

        case WebGL.SAMPLER_2D:
          final v = value as int;
          gl.uniform1i(location, v);
          break;
      }
    });
  }

  void setTextures(Map<String, int> textures) {
    textures.forEach((name, slot) {
      final uniform = _uniforms[name];
      if (uniform == null) return;

      final location = uniform.$2;
      gl.uniform1i(location, slot);
    });
  }

  void bindAndSetParametersAndSetTextures(Map<String, dynamic> parameters, Map<String, int> textures) {
    bind();
    setParameters(parameters);
    setTextures(textures);
  }

  @override
  serialize() => {
        'vertexData': vertexData.serialize(),
        'fragmentData': fragmentData.serialize(),
      };
}

class ShaderAssetDeserializer implements AssetDeserializer<Asset> {
  @override
  Future<Asset> deserialize(AssetDatabase database, String uuid, Map<String, dynamic> header) async {
    return ShaderAsset._(
      database,
      uuid,
      vertexData: DataReference.parse(header['vertexData']),
      fragmentData: DataReference.parse(header['fragmentData']),
    );
  }

  @override
  String get type => 'shader';
}
