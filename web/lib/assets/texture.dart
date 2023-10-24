import '../engine.dart';

class TextureAsset extends Asset {
  final int width;
  final int height;
  final int format;
  final DataReference data;

  TextureAsset._(super.database, super.uuid, {required this.width, required this.height, required this.format, required this.data});

  @override
  Future<void> importLookupReferences() async {}

  late final Texture _texture;

  @override
  Future<void> importBuffer() async {
    final bytes = data.get(database);

    _texture = gl.createTexture();
    gl.compressedTexImage2D(WebGL.TEXTURE_2D, 0, format, width, height, 0, bytes);
  }

  @override
  JsonValue serialize() => {
        'width': width,
        'height': height,
        'format': format,
        'data': data.serialize(),
      };
}

class TextureAssetDeserializer implements AssetDeserializer<TextureAsset> {
  const TextureAssetDeserializer();

  @override
  Future<TextureAsset> deserialize(AssetDatabase database, String uuid, Map<String, dynamic> header) async {
    return TextureAsset._(
      database,
      uuid,
      width: int.parse(header['width']),
      height: int.parse(header['width']),
      format: int.parse(header['format']),
      data: DataReference.parse(header['data']),
    );
  }

  @override
  String get type => 'texture';
}
