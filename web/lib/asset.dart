import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'assets/texture.dart';
import 'engine.dart';

const _builtInDeserializers = {
  'texture': TextureAssetDeserializer(),
};

class AssetDatabase {
  final Map<String, AssetDeserializer> _deserializers;
  final Map<String, Map<String, Asset>> _assets;
  final Uint8List _pack;

  AssetDatabase._(this._deserializers, this._pack) : _assets = {};

  static Future<AssetDatabase> load(String manifestUrl, String packUrl, {Map<String, AssetDeserializer> deserializers = const {}}) async {
    nlog('Initializing asset database.');
    nlog('Downloading data pack.');
    final pack = await http.get(Uri.parse(packUrl)).then((value) => value.bodyBytes);
    final database = AssetDatabase._({..._builtInDeserializers, ...deserializers}, pack);
    nlog('Downloading asset manifest.');
    final manifest = await http.get(Uri.parse(manifestUrl)).then((value) => jsonDecode(value.body) as Map<String, dynamic>);
    nlog('Starting initial asset import.');
    await database._importAssets(manifest);
    nlog('Asset database initialized.');
    return database;
  }

  Future<void> _importAssets(Map<String, dynamic> manifest) async {
    nlog('Starting import.');
    final assets = <String, Map<String, Asset>>{};

    nlog('  Stage 1: Deserializing assets.');
    await Future.wait(manifest.entries.map<Future<void>>((manifestEntry) async {
      final type = manifestEntry.key;
      final entries = manifestEntry.value;

      final deserializer = _deserializers[type];
      if (deserializer == null) {
        nlog('    Error: No deserializer for $type');
        return;
      }

      nlog('    Entering $type collection');
      final collection = <String, Asset>{};
      await Future.wait((entries as Map<String, dynamic>).entries.map<Future<void>>((collectionEntry) async {
        final uuid = collectionEntry.key;
        final header = collectionEntry.value;

        final asset = await deserializer.deserialize(this, header);
        collection[uuid] = asset;
      }));
      assets[type] = collection;
      nlog('    Deserialized ${collection.length} $type assets');
    }));
    nlog('  Stage 1: Done.');

    nlog('  Stage 2: Looking up references.');
    await Future.wait(_assets.entries.fold(<Future<void>>[], (value, collection) {
      collection.value.forEach((uuid, asset) {
        value.add(asset.importLookupReferences());
      });
      return value;
    }));
    nlog('  Stage 2: Done.');

    nlog('  Stage 3: Buffering.');
    nlog('  Stage 3: Done.');

    _assets.addAll(assets);
    nlog('Import complete.');
  }

  Uint8List getData(int start, int end) => _pack.sublist(start, end);
}

abstract class Asset {
  final AssetDatabase database;
  final Uuid uuid;

  Asset(this.database, this.uuid);

  Future<void> importLookupReferences();
  Future<void> importBuffer();
}

abstract interface class AssetDeserializer<TAsset extends Asset> {
  String get type;
  Future<TAsset> deserialize(AssetDatabase database, Map<String, dynamic> header);
}
