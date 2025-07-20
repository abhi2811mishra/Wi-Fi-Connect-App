import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_connect_app/wifi_model.dart';
import 'package:flutter/services.dart'; // Clipboard

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _wifiDatabaseRaw = [
    {
      "ssid": "Cafe_JavaHouse",
      "password_encrypted": "c2VjcmV0MTIz",
      "location": {"latitude": 19.076090, "longitude": 72.877426}
    },
    {
      "ssid": "ScrapGenie_Office",
      "password_encrypted": "c2NnQGRtaW4yMDI0",
      "location": {"latitude": 19.121611, "longitude": 72.882993}
    },
    {
      "ssid": "PromptCue_WiFi",
      "password_encrypted": "UFBDdWUtU3VwZXIxIQ==",
      "location": {"latitude": 19.133430, "longitude": 72.911204}
    },
    {
      "ssid": "InderHome_5G",
      "password_encrypted": "SW5kZXIxMjM0NQ==",
      "location": {"latitude": 19.105870, "longitude": 72.869210}
    }
  ];

  List<WiFiNetwork> _availableNetworks = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _statusMessage = 'Press "Scan & Connect" to find WiFi.';
  }

  Future<bool> _requestPermissions() async {
    var locationStatus = await Permission.locationWhenInUse.status;
    var wifiStatus = await Permission.nearbyWifiDevices.status;

    if (!locationStatus.isGranted) {
      locationStatus = await Permission.locationWhenInUse.request();
    }
    if (!wifiStatus.isGranted) {
      wifiStatus = await Permission.nearbyWifiDevices.request();
    }

    if (locationStatus.isGranted && wifiStatus.isGranted) {
      return true;
    } else {
      setState(() {
        _statusMessage =
            'Permissions denied. Please enable Location and Nearby Devices permissions.';
      });
      if (locationStatus.isPermanentlyDenied || wifiStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }

  Future<void> _scanAndConnect() async {
    setState(() {
      _isLoading = true;
      _availableNetworks = [];
      _statusMessage = 'Checking permissions...';
    });

    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    List<WiFiNetwork> knownNetworks =
        _wifiDatabaseRaw.map((json) => WiFiNetwork.fromJson(json)).toList();

    await _handleLocationBasedScan(knownNetworks);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleLocationBasedScan(List<WiFiNetwork> knownNetworks) async {
    setState(() {
      _statusMessage = 'Getting current location...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusMessage = 'Location services are disabled. Please enable GPS.';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<WiFiNetwork> nearbyNetworks = [];
      const double radiusInMeters = 50.0;

      for (var knownNet in knownNetworks) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          knownNet.latitude,
          knownNet.longitude,
        );
        if (distance <= radiusInMeters) {
          nearbyNetworks.add(knownNet);
        }
      }

      setState(() {
        _availableNetworks = nearbyNetworks;
        _statusMessage = nearbyNetworks.isNotEmpty
            ? 'Found ${nearbyNetworks.length} nearby networks.'
            : 'No nearby WiFi networks found.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _connectToWifi(WiFiNetwork network) async {
    setState(() {
      _statusMessage = 'Attempting to connect to ${network.ssid}...';
    });

    if (Theme.of(context).platform == TargetPlatform.android) {
      try {
        bool connected = await WiFiForIoTPlugin.connect(
          network.ssid,
          password: network.decryptedPassword,
          security: NetworkSecurity.WPA,
          joinOnce: true,
          withInternet: true,
        );
        setState(() {
          _statusMessage = connected
              ? 'Connected to ${network.ssid} successfully!'
              : 'Failed to connect to ${network.ssid}.';
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    } else {
      _showManualConnectDialog(network);
    }
  }

  void _showManualConnectDialog(WiFiNetwork network) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Manual WiFi Connection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SSID: ${network.ssid}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Password: ${network.decryptedPassword}'),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: network.decryptedPassword));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Go to WiFi settings to connect manually.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wifi, size: 26),
            const SizedBox(width: 8),
            const Text('WiFi Connect App'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _scanAndConnect,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanAndConnect,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Scanning...' : 'Scan & Connect to WiFi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _availableNetworks.isEmpty
                  ? const Center(
                      child: Text(
                        'No available networks nearby',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _availableNetworks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final net = _availableNetworks[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.wifi, color: Colors.green),
                            title: Text(
                              net.ssid,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Lat: ${net.latitude.toStringAsFixed(4)}, Long: ${net.longitude.toStringAsFixed(4)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.link_rounded),
                              onPressed: () => _connectToWifi(net),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
