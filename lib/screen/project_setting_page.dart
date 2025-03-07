import 'package:flutter/material.dart';
import 'package:qrkodu/class/project.dart';

class ProjectSettingsPage extends StatefulWidget {
  final Project project;

  const ProjectSettingsPage({super.key, required this.project});

  @override
  State<ProjectSettingsPage> createState() => _ProjectSettingsPageState();
}

class _ProjectSettingsPageState extends State<ProjectSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController =
        TextEditingController(text: widget.project.description);
    _statusController = TextEditingController(text: widget.project.status);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Burada API'ye güncelleme isteği gönderebilirsin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proje ayarları kaydedildi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} - Ayarlar'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Proje Adı'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Durum'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text(
                'Kaydet',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
