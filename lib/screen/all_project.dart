import 'package:flutter/material.dart';
import 'package:qrkodu/class/project.dart';
import 'package:qrkodu/screen/project_detail.dart';

import 'package:qrkodu/services/project_services.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mevcut Projeler'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Proje bulunamadı'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project.name),
                  subtitle: Text(project.description),
                  trailing: Text(project.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsPage(project: project),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
