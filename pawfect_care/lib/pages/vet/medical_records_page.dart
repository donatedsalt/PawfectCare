import 'package:flutter/material.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  final List<Map<String, String>> _records = [
    {
      "petName": "Bella",
      "diagnosis": "Check-up",
      "treatment": "Vaccination",
      "date": "2025-09-12",
    },
    {
      "petName": "Max",
      "diagnosis": "Dental",
      "treatment": "Cleaning",
      "date": "2025-09-10",
    },
  ];

  // void _addRecord(Map<String, String> newRecord) {
  //   setState(() {
  //     _records.add(newRecord);
  //   });
  // }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar("Medical Records"),

        // Medical Records List
        Expanded(
          child: _records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "No medical records available",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            record['petName']!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          subtitle: Text(
                            "${record['diagnosis']} - ${record['treatment']}\nDate: ${record['date']}",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withAlpha(150),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _deleteRecord(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MedicalRecordsPageFloatingActionButton extends StatelessWidget {
  const MedicalRecordsPageFloatingActionButton({super.key});

  void _addRecord(Map<String, String> newRecord) {}

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        final TextEditingController petController = TextEditingController();
        final TextEditingController diagnosisController =
            TextEditingController();
        final TextEditingController treatmentController =
            TextEditingController();
        final TextEditingController dateController = TextEditingController();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              "Add Medical Record",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: petController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Pet Name",
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(150),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: diagnosisController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Diagnosis",
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(150),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: treatmentController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Treatment",
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(150),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Date (YYYY-MM-DD)",
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(150),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () {
                        if (petController.text.isNotEmpty &&
                            diagnosisController.text.isNotEmpty &&
                            treatmentController.text.isNotEmpty &&
                            dateController.text.isNotEmpty) {
                          _addRecord({
                            "petName": petController.text,
                            "diagnosis": diagnosisController.text,
                            "treatment": treatmentController.text,
                            "date": dateController.text,
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MedicalRecordsPageNavigationDestination extends StatelessWidget {
  const MedicalRecordsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.folder_open_outlined),
      selectedIcon: Icon(Icons.folder_open),
      label: "Records",
    );
  }
}
