import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/pages/vet/home_page.dart';

class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key});

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? selectedPet;
  String? ownerName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final notesController = TextEditingController();
  bool _isPressed = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Firebase references
  final CollectionReference petsRef = FirebaseFirestore.instance.collection(
    'pets',
  ); // pet collection
  final CollectionReference appointmentsRef = FirebaseFirestore.instance
      .collection('appointments');

  List<String> petList = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load pets dynamically from Firebase
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
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BrandColors.textWhite),
      filled: true,
      fillColor: BrandColors.cardBlue.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BrandColors.primaryBlue, width: 2),
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
            colorScheme: const ColorScheme.dark(
              primary: BrandColors.accentGreen,
              onPrimary: Colors.white,
              surface: BrandColors.cardBlue,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: BrandColors.cardBlue,
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: BrandColors.accentGreen,
              onPrimary: Colors.white,
              surface: BrandColors.cardBlue,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

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
        'dateTime': dateTime,
        'notes': notesController.text,
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        context.showSnackBar("Appointment Saved");
      }

      _formKey.currentState!.reset();
      setState(() {
        selectedPet = null;
        ownerName = null;
        selectedDate = null;
        selectedTime = null;
      });
      notesController.clear();
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Error: $e");
      }
    }
  }

  Widget _animatedField(Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, double value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _animatedButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _saveAppointment();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
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
                'Save Appointment',
                style: TextStyle(
                  fontSize: 18,
                  color: BrandColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      margin: const EdgeInsets.only(bottom: 20),
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
                          "New Appointment",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: BrandColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: BrandColors.textWhite,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                // Pet Dropdown
                _animatedField(
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Select Pet"),
                    dropdownColor: BrandColors.cardBlue,
                    items:
                        ["Fluffy", "Bella", "Max"] // <-- Static list
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
                    value: selectedPet,
                    onChanged: (val) => setState(() => selectedPet = val),
                    validator: (val) => val == null ? "Select a pet" : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Owner Name
                _animatedField(
                  TextFormField(
                    style: const TextStyle(color: BrandColors.textWhite),
                    decoration: _inputDecoration("Owner Name"),
                    onChanged: (val) => ownerName = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter owner name" : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                _animatedField(
                  TextFormField(
                    readOnly: true,
                    style: const TextStyle(color: BrandColors.textWhite),
                    decoration: _inputDecoration("Select Date"),
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                          : "",
                    ),
                    onTap: _pickDate,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Select date" : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Time Picker
                _animatedField(
                  TextFormField(
                    readOnly: true,
                    style: const TextStyle(color: BrandColors.textWhite),
                    decoration: _inputDecoration("Select Time"),
                    controller: TextEditingController(
                      text: selectedTime != null
                          ? selectedTime!.format(context)
                          : "",
                    ),
                    onTap: _pickTime,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Select time" : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                _animatedField(
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    style: const TextStyle(color: BrandColors.textWhite),
                    decoration: _inputDecoration("Notes / Reason"),
                  ),
                ),
                const SizedBox(height: 30),

                _animatedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
