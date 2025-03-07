class DeviceSetting {
  int id;
  int projectSettingId;
  String value;

  DeviceSetting({
    required this.id,
    required this.projectSettingId,
    required this.value,
  });

  factory DeviceSetting.fromJson(Map<String, dynamic> json) {
    return DeviceSetting(
      id: json['id'],
      projectSettingId: json['project_setting_id'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_setting_id': projectSettingId,
      'value': value,
    };
  }
}
