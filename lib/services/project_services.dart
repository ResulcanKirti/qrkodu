import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qrkodu/class/device.dart';
import 'package:qrkodu/class/devicesettings.dart';
import 'package:qrkodu/class/project.dart';
import 'package:qrkodu/class/projetsettings.dart';
import 'package:qrkodu/services/constans.dart';

Future<List<Project>> fetchProjects() async {
  final response = await http.get(Uri.parse('$apiUrl/api/projects'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Projeler yüklenemedi: ${response.statusCode}');
  }
}

Future<List<ProjectSetting>> fetchProjectSettings(int projectId) async {
  final response =
      await http.get(Uri.parse('$apiUrl/api/projects/$projectId/settings'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => ProjectSetting.fromJson(json)).toList();
  } else {
    throw Exception('Proje ayarları yüklenemedi: ${response.statusCode}');
  }
}

Future<List<Device>> fetchDevices(int projectId) async {
  final response =
      await http.get(Uri.parse('$apiUrl/api/projects/$projectId/devices'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Device.fromJson(json)).toList();
  } else {
    throw Exception('Cihazlar yüklenemedi: ${response.statusCode}');
  }
}

Future<List<DeviceSetting>> fetchDeviceSettings(int deviceId) async {
  final response =
      await http.get(Uri.parse('$apiUrl/api/devices/$deviceId/settings'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => DeviceSetting.fromJson(json)).toList();
  } else {
    throw Exception('Cihaz ayarları yüklenemedi: ${response.statusCode}');
  }
}
