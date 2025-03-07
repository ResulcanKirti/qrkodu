import 'package:qrkodu/class/devicesettings.dart';

class Device {
  int id;
  String name;
  DateTime createdAt;
  List<DeviceSetting> settings;

  Device({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      settings: json['settings'] != null
          ? List<DeviceSetting>.from(
              json['settings'].map((x) => DeviceSetting.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'settings': settings.map((x) => x.toJson()).toList(),
    };
  }
}
