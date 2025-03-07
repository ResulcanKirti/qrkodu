class ProjectSetting {
  int id;
  String key;
  String? defaultValue;

  ProjectSetting({
    required this.id,
    required this.key,
    this.defaultValue,
  });

  factory ProjectSetting.fromJson(Map<String, dynamic> json) {
    return ProjectSetting(
      id: json['id'],
      key: json['key'],
      defaultValue: json['default_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'default_value': defaultValue,
    };
  }
}
