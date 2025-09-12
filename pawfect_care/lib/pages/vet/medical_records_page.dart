import 'package:flutter/material.dart';

/// 🎨 Brand Colors (HomePage/CalendarPage ke theme ke hisaab se)
class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromARGB(255, 196, 255, 232);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
  static const Color fabGreen = Color(0xFF32C48D);
}

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

  void _addRecord(Map<String, String> newRecord) {
    setState(() {
      _records.add(newRecord);
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🌈 Gradient Header with Back Button
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        BrandColors.accentGreen,
                        BrandColors.primaryBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Medical Records",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 📋 Medical Records List
            Expanded(
              child: _records.isEmpty
                  ? const Center(
                      child: Text(
                        "No medical records available",
                        style: TextStyle(color: BrandColors.textWhite),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          color: BrandColors.cardBlue,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              record['petName']!,
                              style: const TextStyle(
                                color: BrandColors.textWhite,
                              ),
                            ),
                            subtitle: Text(
                              "${record['diagnosis']} - ${record['treatment']}\nDate: ${record['date']}",
                              style: const TextStyle(
                                color: BrandColors.textGrey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRecord(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ➕ Add Medical Record FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.fabGreen,
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
              backgroundColor: BrandColors.cardBlue,
              title: const Text(
                "Add Medical Record",
                style: TextStyle(color: BrandColors.textWhite),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: petController,
                      style: const TextStyle(color: BrandColors.textWhite),
                      decoration: const InputDecoration(
                        hintText: "Pet Name",
                        hintStyle: TextStyle(color: BrandColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: diagnosisController,
                      style: const TextStyle(color: BrandColors.textWhite),
                      decoration: const InputDecoration(
                        hintText: "Diagnosis",
                        hintStyle: TextStyle(color: BrandColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: treatmentController,
                      style: const TextStyle(color: BrandColors.textWhite),
                      decoration: const InputDecoration(
                        hintText: "Treatment",
                        hintStyle: TextStyle(color: BrandColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      style: const TextStyle(color: BrandColors.textWhite),
                      decoration: const InputDecoration(
                        hintText: "Date (YYYY-MM-DD)",
                        hintStyle: TextStyle(color: BrandColors.textGrey),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.accentGreen,
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
              ],
            ),
          );
        },
      ),
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
