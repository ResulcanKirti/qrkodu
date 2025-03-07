import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qrkodu/screen/database.dart';

class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  String scanResult = "Henüz bir QR kod taranmadı";
  bool isScanning = false;
  bool isLoadingLocation = false;

  Future<void> startQRScanner() async {
    if (isScanning || isLoadingLocation) return;

    setState(() {
      isScanning = true;
      scanResult = "Lütfen bekleyin, konumunuz doğrulanıyor...";
    });

    try {
      ScanResult result = await BarcodeScanner.scan();
      String qrData = result.rawContent;

      if (qrData.isNotEmpty) {
        if (qrData.startsWith("DevEUI")) {
          await _getLocationAndSave(qrData);
        } else {
          setState(() {
            scanResult = "Uygun QR kod taratılmadı!";
          });
        }
      } else {
        setState(() {
          scanResult = "Herhangi bir içerik bulunamadı!";
        });
      }
    } catch (e) {
      setState(() {
        scanResult = "Bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> _getLocationAndSave(String qrData) async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          scanResult = "Konum izni verilmedi! Lütfen ayarlardan izni verin.";
        });
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          scanResult = "Konum servisleri kapalı! Lütfen açın.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high);
      String locationData = " ${position.latitude}, ${position.longitude} ";
      DateTime now = DateTime.now();
      String timestamp =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      var box = await Hive.openBox<String>('qr_codes');
      if (box.containsKey(qrData)) {
        setState(() {
          scanResult = "Bu QR kod zaten kaydedilmiş!";
        });
      } else {
        await box.put(qrData, "$locationData \nTime:  $timestamp");
        setState(() {
          scanResult = "QR kod ve konum kaydedildi!";
        });
      }
    } catch (e) {
      setState(() {
        scanResult = "Konum alınırken bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData getIconBasedOnResult() {
      switch (scanResult) {
        case "Henüz bir QR kod taranmadı":
          return Icons.qr_code_2;
        case "Herhangi bir içerik bulunamadı!":
          return Icons.close;
        case "Bir hata oluştu:":
          return Icons.close;
        case "Konum izni verilmedi! Lütfen ayarlardan izni verin.":
          return Icons.warning;
        case "Konum servisleri kapalı! Lütfen açın.":
          return Icons.warning;
        case "Bu QR kod zaten kaydedilmiş!":
          return Icons.close;
        case "Konum alınırken bir hata oluştu:":
          return Icons.error;
        case "QR kod ve konum kaydedildi!":
          return Icons.check_circle_outline;
        default:
          return Icons.help_outline;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('UKB QR Kod Tarayıcı'),
        centerTitle: true,
        backgroundColor: const Color(0xFF004c97),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: isScanning || isLoadingLocation
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFF004c97)),
                              strokeWidth: 6,
                            ),
                            Icon(
                              Icons.access_time,
                              color: Color(0xFF004c97),
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Lütfen bekleyin, konumunuz doğrulanıyor...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(137, 255, 255, 255),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getIconBasedOnResult(),
                          color: const Color(0xFF004c97),
                          size: 60,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          scanResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: ElevatedButton(
              onPressed:
                  isScanning || isLoadingLocation ? null : startQRScanner,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                backgroundColor: const Color(0xFF004c97),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: const Color(0xFF004c97),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "QR Tarayıcıyı Başlat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SavedQRCodesPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                backgroundColor: const Color(0xFFC8102E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFC8102E),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Kayıtlı QR Kodlar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
