import 'package:flutter/material.dart';
import 'package:qrkodu/class/project.dart';
import 'package:qrkodu/class/device.dart';

class AddDevicePage extends StatefulWidget {
  final Project project;

  const AddDevicePage({super.key, required this.project});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController _deviceNameController = TextEditingController();

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  void _addDevice() {
    String deviceName = _deviceNameController.text.trim();
    if (deviceName.isNotEmpty) {
      Device newDevice = Device(
          id: DateTime.now().millisecondsSinceEpoch,
          name: deviceName,
          createdAt: DateTime(2000),
          settings: []);
      widget.project.devices.add(newDevice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deviceName cihazı eklendi!')),
      );

      Navigator.pop(context); // Sayfayı kapat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} - Cihaz Ekle'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(labelText: 'Cihaz Adı'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addDevice,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Cihazı Ekle',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
