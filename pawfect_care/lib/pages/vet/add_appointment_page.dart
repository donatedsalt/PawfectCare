import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/scale_fade_in.dart';
import 'package:pawfect_care/widgets/slide_fade_in.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPet;
  String? ownerName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final notesController = TextEditingController();

  final CollectionReference petsRef = FirebaseFirestore.instance.collection(
    'pets',
  );
  final CollectionReference appointmentsRef = FirebaseFirestore.instance
      .collection('appointments');

  List<String> petList = [];
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Load pets dynamically
    petsRef.snapshots().listen((snapshot) {
      final pets = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] as String;
      }).toList();

      setState(() => petList = pets);
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      filled: true,
      fillColor: Theme.of(context).colorScheme.primary.withAlpha(240),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.primary,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        dateController.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              surface: Theme.of(context).colorScheme.primary,
              onSurface: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
        timeController.text = time.format(context);
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await appointmentsRef.add({
        'petName': selectedPet,
        'ownerName': ownerName,
        'date': dateTime,
        'notes': notesController.text,
        'vetId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) context.showSnackBar("Appointment Saved");

      _formKey.currentState!.reset();
      setState(() {
        selectedPet = null;
        ownerName = null;
        selectedDate = null;
        selectedTime = null;
      });
      dateController.clear();
      timeController.clear();
      notesController.clear();
    } catch (e) {
      if (mounted) context.showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomAppBar("New Appointment", showBack: !_isSubmitting),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Pet Dropdown
                    ScaleFadeIn(
                      key: const ValueKey("petDropdown"),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedPet,
                        decoration: _inputDecoration("Select Pet"),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: petList
                            .map(
                              (pet) => DropdownMenuItem(
                                value: pet,
                                child: Text(
                                  pet,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (val) => setState(() => selectedPet = val),
                        validator: (val) => val == null ? "Select a pet" : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Owner Name
                    ScaleFadeIn(
                      key: const ValueKey("ownerNameField"),
                      child: TextFormField(
                        enabled: !_isSubmitting,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        decoration: _inputDecoration("Owner Name"),
                        onChanged: (val) => ownerName = val,
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter owner name"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    ScaleFadeIn(
                      key: const ValueKey("dateField"),
                      child: TextFormField(
                        enabled: !_isSubmitting,
                        controller: dateController,
                        readOnly: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        decoration: _inputDecoration("Select Date"),
                        onTap: _isSubmitting ? null : _pickDate,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Select date" : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Picker
                    ScaleFadeIn(
                      key: const ValueKey("timeField"),
                      child: TextFormField(
                        enabled: !_isSubmitting,
                        controller: timeController,
                        readOnly: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        decoration: _inputDecoration("Select Time"),
                        onTap: _isSubmitting ? null : _pickTime,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Select time" : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    ScaleFadeIn(
                      key: const ValueKey("notesField"),
                      child: TextFormField(
                        enabled: !_isSubmitting,
                        controller: notesController,
                        maxLines: 3,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        decoration: _inputDecoration("Notes / Reason"),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    SlideFadeIn(
                      key: const ValueKey("saveButton"),
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _saveAppointment,
                          style: ButtonStyle(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Save Appointment",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
