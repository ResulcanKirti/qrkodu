import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SavedQRCodesPage extends StatelessWidget {
  const SavedQRCodesPage({super.key});

  Future<void> exportToJson(BuildContext context) async {
    var box = Hive.box<String>('qr_codes');
    List<Map<String, dynamic>> qrList = [];
    int counter = 1;

    box.toMap().forEach((key, value) {
      String devEUI = key.substring(8, 24);
      String appSKey = key.substring(34, 66);
      String nwSKey = key.substring(75, 107);
      String locationData = value.substring(0, 11);
      String locationDatalong = value.substring(12, 23);
      String timestamp = value.substring(32, 49);

      Map<String, dynamic> qrData = {
        'UKB Device': counter,
        'devEUI': devEUI,
        'appSKey': appSKey,
        'nwSKey': nwSKey,
        'latitude': locationData,
        'longitude': locationDatalong,
        'time': timestamp,
      };

      qrList.add(qrData);
      counter++;
    });
    String jsonString = const JsonEncoder.withIndent('  ').convert(qrList);
    PermissionStatus permission = await Permission.storage.request();
    if (permission.isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsDirectory = Directory('${directory.path}/Download');
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }
        final filePath = '${downloadsDirectory.path}/qr_codes.json';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dosya Kaydedildi'),
            content: Text('QR kodları JSON dosyasına kaydedildi: $filePath'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kapat'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('İzin Gerekli'),
          content: const Text('Depolama izni verilmedi. Lütfen izin verin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<String>('qr_codes');

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kayıtlı QR Kodlar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFC8102E),
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.file_download),
            onPressed: () {
              exportToJson(context);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<String> box, _) {
          if (!box.isOpen) {
            return const Center(child: CircularProgressIndicator());
          }

          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kayıtlı bir QR kod yok.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.keys.length,
            itemBuilder: (context, index) {
              final qrKey = box.keyAt(index);
              final location = box.get(qrKey) ?? "Konum bilgisi yok";

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    "$qrKey",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    "Konum: $location",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFC8102E)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('QR Kodu Sil'),
                          content: const Text(
                            'Bu QR kodu silmek istediğinizden emin misiniz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () {
                                box.delete(qrKey);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Evet'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
