import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../../models/app_info.dart';
import '../../services/platform_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PlatformService _platformService = PlatformService();
  
  bool _isLoading = false;
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  late TabController _tabController;
  List<AppInfo> _apps = [];
  final List<Map<String, dynamic>> _adDetections = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeApp();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _checkPermissions();
    await _scanApps();
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.systemAlertWindow,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ];

    for (var permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    }
  }

  Future<void> _scanApps() async {
    setState(() => _isLoading = true);

    try {
      final apps = await _platformService.getInstalledApps();
      setState(() {
        _apps = apps;
      });
    } catch (e) {
      _showError('Impossible de scanner les applications');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateRunningApps() async {
    try {
      final runningPackages = await _platformService.getRunningApps();
      setState(() {
        for (var app in _apps) {
          final wasRunning = app.isRunning;
          app.isRunning = runningPackages.contains(app.packageName);
          if (app.isRunning && !wasRunning) {
            app.detectionCount++;
          }
        }
      });
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
    }
  }

  void _startMonitoring() {
    setState(() => _isMonitoring = true);
    
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateRunningApps(),
    );
  }

  void _stopMonitoring() {
    setState(() => _isMonitoring = false);
    _monitoringTimer?.cancel();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildAdDetectionsList() {
    if (_adDetections.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune publicité invasive détectée'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Publicités Invasives Détectées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...List.generate(
            _adDetections.length,
            (index) {
              final detection = _adDetections[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(detection['appName'] as String),
                subtitle: Text(
                  'Type: ${detection['type']}\n'
                  'Détecté le: ${DateTime.fromMillisecondsSinceEpoch(
                    detection['timestamp'] as int
                  ).toString()}'
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => openAppSettings(),
                ),
                isThreeLine: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final runningApps = _apps.where((app) => app.isRunning).length;
    final totalDetections = _apps.fold(0, (sum, app) => sum + app.detectionCount);
    final suspiciousApps = _apps.where((app) => 
      app.hasOverlayPermission || 
      app.hasNotificationPermission || 
      app.hasBatteryOptPermission
    ).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Applications en cours: $runningApps'),
                Text('Applications suspectes: $suspiciousApps'),
                Text('Total des détections: $totalDetections'),
                const SizedBox(height: 8),
                Text(
                  'Surveillance: ${_isMonitoring ? "Active" : "Inactive"}',
                  style: TextStyle(
                    color: _isMonitoring ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Applications fréquemment détectées',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._apps
            .where((app) => app.detectionCount > 0)
            .toList()
            .map((app) => ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(app.name),
                  subtitle: Text('${app.detectionCount} détections'),
                ))
            ,
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Surveillance automatique'),
                subtitle: const Text('Vérifie les apps toutes les 3 secondes'),
                value: _isMonitoring,
                onChanged: (value) {
                  if (value) {
                    _startMonitoring();
                  } else {
                    _stopMonitoring();
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Réinitialiser les statistiques'),
                subtitle: const Text('Efface toutes les détections'),
                trailing: const Icon(Icons.cleaning_services),
                onTap: () {
                  setState(() {
                    for (var app in _apps) {
                      app.detectionCount = 0;
                    }
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Actualiser la liste'),
                subtitle: const Text('Rescanne toutes les applications'),
                trailing: const Icon(Icons.refresh),
                onTap: _scanApps,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Système'),
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            onPressed: () {
              if (_isMonitoring) {
                _stopMonitoring();
              } else {
                _startMonitoring();
              }
            },
            tooltip: _isMonitoring ? 'Arrêter' : 'Démarrer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanApps,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.apps), text: 'Applications'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
            Tab(icon: Icon(Icons.settings), text: 'Paramètres'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAdDetectionsList(),
                      Column(
                        children: _apps.map((app) {
                          return ExpansionTile(
                            leading: Icon(
                              app.isRunning ? Icons.running_with_errors : Icons.apps,
                              color: app.isRunning ? Colors.red : Colors.grey,
                            ),
                            title: Text(app.name),
                            subtitle: Text(app.isSystemApp ? 'Application système' : 'Application utilisateur'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Package: ${app.packageName}'),
                                    Text('Détections: ${app.detectionCount}'),
                                    if (app.hasOverlayPermission)
                                      const ListTile(
                                        leading: Icon(Icons.layers, color: Colors.orange),
                                        title: Text('Permission Overlay'),
                                        dense: true,
                                      ),
                                    if (app.hasNotificationPermission)
                                      const ListTile(
                                        leading: Icon(Icons.notifications, color: Colors.orange),
                                        title: Text('Permission Notifications'),
                                        dense: true,
                                      ),
                                    if (app.hasBatteryOptPermission)
                                      const ListTile(
                                        leading: Icon(Icons.battery_alert, color: Colors.orange),
                                        title: Text('Optimisation batterie désactivée'),
                                        dense: true,
                                      ),
                                    ElevatedButton(
                                      onPressed: () => openAppSettings(),
                                      child: const Text('Gérer les permissions'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                _buildStatistics(),
                _buildSettings(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await openAppSettings();
        },
        label: const Text('Paramètres système'),
        icon: const Icon(Icons.settings),
      ),
    );
  }
}