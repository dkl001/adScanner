import 'package:flutter/services.dart';
import '../models/app_info.dart';

class PlatformService {
  static const platform = MethodChannel('app.scanner/apps');

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> apps = await platform.invokeMethod('getInstalledApps');
      return apps.map((app) => AppInfo.fromMap(app)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Erreur lors du scan: $e');
      rethrow;
    }
  }

  Future<List<String>> getRunningApps() async {
    try {
      final List<dynamic> runningApps = await platform.invokeMethod('getRunningApps');
      return runningApps
          .map((app) => (app['pkgList'] as List<dynamic>).cast<String>())
          .expand((x) => x)
          .toSet()
          .toList();
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      rethrow;
    }
  }
}