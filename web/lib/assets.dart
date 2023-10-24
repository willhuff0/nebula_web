import 'dart:typed_data';

import 'engine.dart';

export 'assets/texture.dart';

typedef JsonValue = dynamic;

abstract interface class Serializable {
  JsonValue serialize();
}

abstract class Asset implements Serializable {
  final AssetDatabase database;
  final String uuid;

  Asset(this.database, this.uuid);

  Future<void> importLookupReferences();
  Future<void> importBuffer();
}

abstract interface class AssetDeserializer<TAsset extends Asset> {
  String get type;
  Future<TAsset> deserialize(AssetDatabase database, String uuid, Map<String, dynamic> header);
}

class DataReference implements Serializable {
  final int start;
  final int end;

  const DataReference(this.start, this.end);

  static DataReference parse(dynamic json) {
    final list = (json as List);
    return DataReference(int.parse(list[0]), int.parse(list[1]));
  }

  Uint8List get(AssetDatabase database) => database.getData(start, end);

  @override
  JsonValue serialize() => [start, end];
}
