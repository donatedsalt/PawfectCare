import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/pages/vet/home_page.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();

  // Focus nodes
  final FocusNode _petFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  final FocusNode _speciesFocus = FocusNode();

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _ownerNameController.dispose();
    _ageController.dispose();
    _speciesController.dispose();

    _petFocus.dispose();
    _ownerFocus.dispose();
    _ageFocus.dispose();
    _speciesFocus.dispose();

    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('patients').add({
          'petName': _petNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'species': _speciesController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          context.showSnackBar(
            "Patient '${_petNameController.text}' added successfully!",
          );
        }

        _formKey.currentState!.reset();
        _petNameController.clear();
        _ownerNameController.clear();
        _ageController.clear();
        _speciesController.clear();
      } catch (e) {
        if (mounted) {
          context.showSnackBar("Error adding patient: $e");
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label, {bool isFocused = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isFocused ? BrandColors.accentGreen : BrandColors.textWhite,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: BrandColors.cardBlue.withOpacity(0.9),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BrandColors.accentGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground, // Your original dark theme
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Gradient header with back button
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
                          "Add New Patient",
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

                _animatedField(_petNameController, 'Pet Name', _petFocus),
                const SizedBox(height: 16),
                _animatedField(_ownerNameController, 'Owner Name', _ownerFocus),
                const SizedBox(height: 16),
                _animatedField(
                  _ageController,
                  'Age',
                  _ageFocus,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _animatedField(_speciesController, 'Species', _speciesFocus),
                const SizedBox(height: 30),

                _animatedSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedField(
    TextEditingController controller,
    String label,
    FocusNode focusNode, {
    bool isNumber = false,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: StatefulBuilder(
          builder: (context, setState) {
            focusNode.addListener(() => setState(() {}));
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              decoration: _inputDecoration(
                label,
                isFocused: focusNode.hasFocus,
              ),
              style: const TextStyle(color: BrandColors.textWhite),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter ${label.toLowerCase()}';
                if (isNumber && int.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            );
          },
        ),
      ),
    );
  }

  Widget _animatedSubmitButton() {
    bool _isPressed = false;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _submitForm();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BrandColors.accentGreen, BrandColors.primaryBlue],
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
                    'Add Patient',
                    style: TextStyle(
                      fontSize: 18,
                      color: BrandColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
