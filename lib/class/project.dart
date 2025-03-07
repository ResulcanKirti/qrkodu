import 'package:qrkodu/class/device.dart';
import 'package:qrkodu/class/projetsettings.dart';

class Project {
  int id;
  String name;
  String description;
  String status;
  DateTime deadline;
  List<ProjectSetting> settings;
  List<Device> devices;
  DateTime createdAt;
  DateTime? modifiedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.deadline,
    required this.settings,
    required this.devices,
    required this.createdAt,
    this.modifiedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      deadline: DateTime.parse(json['deadline']),
      settings: json['settings'] != null
          ? List<ProjectSetting>.from(
              json['settings'].map((x) => ProjectSetting.fromJson(x)))
          : [],
      devices: json['devices'] != null
          ? List<Device>.from(json['devices'].map((x) => Device.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'settings': settings.map((x) => x.toJson()).toList(),
      'devices': devices.map((x) => x.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt?.toIso8601String(),
    };
  }
}
