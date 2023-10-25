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

class CachedDataReference implements Serializable {
  int? _start;
  int? _end;
  late Uint8List? _data;

  CachedDataReference(int start, int end)
      : _start = start,
        _end = end;

  static CachedDataReference parse(dynamic json) {
    final list = (json as List);
    return CachedDataReference(int.parse(list[0]), int.parse(list[1]));
  }

  Uint8List get(AssetDatabase database) {
    if (_data == null) {
      database.getData(_start!, _end!);
      if (!DEBUG) {
        _start = null;
        _end = null;
      }
    }
    return _data!;
  }

  void dispose() {
    _start = null;
    _end = null;
    _data = null;
  }

  @override
  serialize() => [_start!, _end!];
}

class CachedAssetReference<TAsset extends Asset> implements Serializable {
  String? _type;
  String? _uuid;
  late TAsset? _asset;

  CachedAssetReference(String type, String uuid)
      : _type = type,
        _uuid = uuid;

  TAsset get(AssetDatabase database) {
    if (_asset == null) {
      _asset = database.getAsset<TAsset>(_type!, _uuid!);
      if (!DEBUG) {
        _type = null;
        _uuid = null;
      }
    }
    return _asset!;
  }

  void dispose() {
    _type = null;
    _uuid = null;
    _asset = null;
  }

  @override
  serialize() => _uuid!;
}
