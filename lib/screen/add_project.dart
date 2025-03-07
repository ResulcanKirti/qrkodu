import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qrkodu/services/constans.dart';
import 'dart:convert';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _description;
  int? _managerId;
  double? _budget;
  DateTime? _deadline;
  String _status = 'Active';

  final TextEditingController _deadlineController = TextEditingController();

  @override
  void dispose() {
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _deadline = pickedDate;
        _deadlineController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _deadline != null) {
      _formKey.currentState!.save();

      final Map<String, dynamic> payload = {
        'name': _name,
        'description': _description,
        'manager_id': _managerId,
        'budget': _budget,
        'deadline': _deadline!.toIso8601String().split('T')[0],
        'status': _status,
      };

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/api/projects'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proje başarıyla oluşturuldu!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Proje oluşturulamadı: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje Ekle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Proje Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen proje adını girin';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açıklama girin';
                  }
                  return null;
                },
                onSaved: (value) => _description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Manager ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen manager id girin';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  return null;
                },
                onSaved: (value) => _managerId = int.tryParse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bütçe'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bütçe girin';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  return null;
                },
                onSaved: (value) => _budget = double.tryParse(value!),
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(labelText: 'Bitiş Tarihi'),
                readOnly: true,
                onTap: () => _selectDeadline(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bitiş tarihini seçin';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Durum'),
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                items: <String>['Active', 'Inactive', 'Completed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Proje Ekle',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
