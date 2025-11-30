import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ini untuk tema "keren" (dark mode)
    return MaterialApp(
      title: 'Kontrol Kipas',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor:
            const Color(0xFF1A1A1A), // Background lebih gelap
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.lightBlueAccent, // Warna aksen (biru)
          secondary: Colors.lightBlueAccent,
          // === Warna untuk Switch On/Off ===
          surfaceVariant: const Color(0xFF2C2C2C), // Warna background card
        ),
      ),
      home: const SliderPage(),
    );
  }
}

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  // Variabel UI
  String _connectionStatus = 'Disconnected';
  
  // === VARIABEL DIKEMBALIKAN SEPERTI SEMULA ===
  bool _isFanOn = false; // Default OFF
  double _sliderValue = 0.0; // Default speed 0

  // === PENGATURAN MQTT (SESUAI KODE ESP32-mu) ===
  late MqttServerClient _client;
  final String _broker = 'broker.hivemq.com';
  // === DIUBAH: Kita sekarang punya 2 Topik ===
  final String _speedTopic = 'proyek/kipas/kecepatan'; // Topik untuk kecepatan
  final String _powerTopic = 'proyek/kipas/power';   // Topik untuk On/Off
  final String _clientId =
      'flutter_kipas_controller_${DateTime.now().millisecondsSinceEpoch}';
  // ===============================================

  @override
  void initState() {
    super.initState();
    _connect(); // Langsung coba konek saat aplikasi dibuka
  }

  // --- UI (Widget Build) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFan by Kelompok 4'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Indikator Status Koneksi
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Center(
              child: Text(
                _connectionStatus,
                style: TextStyle(
                  color: _connectionStatus == 'Connected'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // Kartu (Card) untuk tampilan modern
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: const Color(0xFF2C2C2C), // Warna kartu
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === Tombol Geser On/Off ===
                  SwitchListTile(
                    title: Text(
                      _isFanOn ? 'KIPAS ON' : 'KIPAS OFF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _isFanOn ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    value: _isFanOn,
                    
                    // === LOGIKA INTI DIUBAH DI SINI ===
                    onChanged: (bool newValue) {
                      if (newValue) { // Kipas dinyalakan (ON)
                        setState(() {
                          _isFanOn = true;
                          _sliderValue = 25.0; // Set UI slider ke 25
                        });
                        // Kirim DUA pesan MQTT
                        _publish(_powerTopic, 'on');
                        _publish(_speedTopic, '25'); // Langsung kirim kecepatan 25
                        
                      } else { // Kipas dimatikan (OFF)
                        setState(() {
                          _isFanOn = false;
                          _sliderValue = 0.0; // Set UI slider ke 0
                        });
                        // Kirim DUA pesan MQTT
                        _publish(_powerTopic, 'off');
                        _publish(_speedTopic, '0'); // Langsung kirim kecepatan 0
                      }
                    },
                    // ===================================

                    // Ikon tambahan biar keren
                    secondary: Icon(
                      _isFanOn ? Icons.check_circle_outline : Icons.power_off_outlined,
                      color: _isFanOn ? Colors.greenAccent : Colors.redAccent,
                      size: 30,
                    ),
                    activeColor: Colors.greenAccent,
                    inactiveTrackColor: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  // Garis pemisah
                  Divider(color: Colors.grey[700]),
                  const SizedBox(height: 20),
                  // ======================================

                  // Judul
                  Text(
                    'KECEPATAN KIPAS',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isFanOn ? Colors.white : Colors.grey[600], // Redup saat mati
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Tampilan angka
                  Text(
                    _sliderValue.round().toString(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isFanOn ? Colors.lightBlueAccent : Colors.grey[700], // Redup saat mati
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Slider Utama
                  Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 100,
                    // Slider "mandek" di 0, 25, 50, 75, 100
                    divisions: 4, 
                    label: _sliderValue.round().toString(),
                    activeColor: Colors.lightBlueAccent,
                    inactiveColor: Colors.grey[700],
                    
                    // Slider nonaktif saat _isFanOn = false
                    onChanged: _isFanOn ? (double value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    } : null, // Set ke null untuk menonaktifkan
                    
                    // Kirim data MQTT saat slider dilepas
                    onChangeEnd: _isFanOn ? (double value) {
                      String formattedValue = value.round().toString();
                      // Kirim ke topik kecepatan
                      _publish(_speedTopic, formattedValue);
                    } : null, // Set ke null untuk menonaktifkan
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Fungsi Logika MQTT ---

  Future<void> _connect() async {
    _client = MqttServerClient(_broker, _clientId);
    _client.port = 1883; // Port default MQTT
    _client.logging(on: false);
    _client.keepAlivePeriod = 60;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;

    // Atur status UI
    setState(() {
      _connectionStatus = 'Connecting...';
    });

    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception - $e');
      _client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception - $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT Client connected');
    } else {
      print(
          'ERROR: MQTT client connection failed - ${_client.connectionStatus}');
      _onDisconnected();
    }
  }

  void _onConnected() {
    setState(() {
      _connectionStatus = 'Connected';
    });
    print('Connected to broker.');
  }

  void _onDisconnected() {
    setState(() {
      _connectionStatus = 'Disconnected';
    });
    print('Disconnected from broker.');
  }

  // Fungsi _publish menerima TOPIC & message
  void _publish(String topic, String message) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      // Kirim pesan ke topik yang benar
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published: $message to $topic');
    } else {
      print('Cannot publish, client not connected');
      _connect(); // Coba konek ulang jika terputus
    }
  }
}