class AppInfo {
  final String name;
  final String packageName;
  final List<String> permissions;
  final bool isSystemApp;
  bool isRunning;
  final bool hasOverlayPermission;
  final bool hasNotificationPermission;
  final bool hasBatteryOptPermission;
  int detectionCount;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.permissions,
    required this.isSystemApp,
    this.isRunning = false,
    required this.hasOverlayPermission,
    required this.hasNotificationPermission,
    required this.hasBatteryOptPermission,
    this.detectionCount = 0,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      name: map['name'] as String? ?? 'Inconnu',
      packageName: map['packageName'] as String? ?? '',
      permissions: (map['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      isRunning: map['isRunning'] as bool? ?? false,
      hasOverlayPermission: map['hasOverlayPermission'] as bool? ?? false,
      hasNotificationPermission: map['hasNotificationPermission'] as bool? ?? false,
      hasBatteryOptPermission: map['hasBatteryOptPermission'] as bool? ?? false,
    );
  }
}