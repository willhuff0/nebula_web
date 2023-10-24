import '../engine.dart';

class TextureAsset extends Asset {
  TextureAsset._(super.database, super.uuid);

  @override
  Future<void> importLookupReferences() {
    // TODO: implement importLookupReferences
    throw UnimplementedError();
  }

  @override
  Future<void> importBuffer() {
    // TODO: implement importBuffer
    throw UnimplementedError();
  }
}

class TextureAssetDeserializer implements AssetDeserializer<TextureAsset> {
  const TextureAssetDeserializer();

  @override
  Future<TextureAsset> deserialize(AssetDatabase database, Map<String, dynamic> header) async {}

  @override
  String get type => 'texture';
}
