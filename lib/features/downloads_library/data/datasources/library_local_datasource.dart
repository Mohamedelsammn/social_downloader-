import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/download_item_model.dart';

abstract class LibraryLocalDataSource {
  Future<List<DownloadItemModel>> getAll();
  Future<void> add(DownloadItemModel item);
  Future<void> remove(String id);
  Future<Directory> getDownloadsDirectory();
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final SharedPreferences _prefs;
  LibraryLocalDataSourceImpl(this._prefs);

  @override
  Future<List<DownloadItemModel>> getAll() async {
    try {
      final raw = _prefs.getString(AppConstants.downloadsPrefsKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => DownloadItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to read library: $e');
    }
  }

  @override
  Future<void> add(DownloadItemModel item) async {
    final items = await getAll();
    final next = [item, ...items.where((e) => e.id != item.id)];
    await _persist(next);
  }

  @override
  Future<void> remove(String id) async {
    final items = await getAll();
    final next = items.where((e) => e.id != id).toList();
    await _persist(next);
  }

  Future<void> _persist(List<DownloadItemModel> items) async {
    try {
      final encoded =
          jsonEncode(items.map((e) => e.toJson()).toList(growable: false));
      await _prefs.setString(AppConstants.downloadsPrefsKey, encoded);
    } catch (e) {
      throw CacheException('Failed to persist library: $e');
    }
  }

  @override
  Future<Directory> getDownloadsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/${AppConstants.downloadsFolderName}');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
