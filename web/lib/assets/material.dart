import '../engine.dart';
import 'shader.dart';

class MaterialAsset extends Asset {
  final CachedAssetReference<ShaderAsset> shader;
  final Map<String, CachedAssetReference<TextureAsset>> textures;
  final Map<String, dynamic> parameters;

  MaterialAsset._(super.database, super.uuid, {required this.shader, required this.textures, required this.parameters});

  @override
  Future<void> importLookupReferences() async {
    shader.get(database);
    textures.forEach((key, referencer) {
      referencer.get(database);
    });
  }

  @override
  Future<void> importBuffer() async {}

  void bind() {
    var i = 0;
    final samplers = <String, int>{};
    textures.forEach((name, texture) {
      texture.get(database).bind(i);
      samplers[name] = i;
      i++;
    });

    shader.get(database).bindAndSetParametersAndSetTextures(parameters, samplers);
  }

  @override
  serialize() => {
        'shader': shader.serialize(),
        'textures': textures.map((key, value) => MapEntry(key, value.serialize())),
        'parameters': parameters,
      };
}

class MaterialAssetDeserializer implements AssetDeserializer<MaterialAsset> {
  @override
  Future<MaterialAsset> deserialize(AssetDatabase database, String uuid, Map<String, dynamic> header) async {
    return MaterialAsset._(
      database,
      uuid,
      shader: CachedAssetReference<ShaderAsset>('shader', header['shader']),
      textures: (header['textures'] as Map<String, dynamic>).map((key, value) => MapEntry(key, CachedAssetReference<TextureAsset>('texture', value))),
      parameters: header['parameters'],
    );
  }

  @override
  String get type => 'material';
}
