import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  String? _selectedVet;
  String? _selectedPet;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  List<Map<String, String>> _vets = [];
  List<Map<String, String>> _pets = [];

  @override
  void initState() {
    super.initState();
    _fetchVets();
    _fetchPets();
  }

  Future<void> _fetchVets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'veterinarian')
        .get();

    setState(() {
      _vets = snapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc['name']?.toString() ?? 'Unnamed Vet'};
      }).toList();
    });
  }

  Future<void> _fetchPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .get();

    setState(() {
      _pets = snapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc['name']?.toString() ?? 'Unnamed Pet'};
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedVet == null || _selectedPet == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a pet, vet, and date")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Find the pet's name based on the selected ID
      final petData = _pets.firstWhereOrNull(
        (pet) => pet['id'] == _selectedPet,
      );
      final petName = petData?['name'] ?? 'Unnamed Pet';

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'petId': _selectedPet,
        'petName': petName,
        'ownerName': user.displayName,
        'vetId': _selectedVet,
        'date': _selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment booked successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) context.showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar("Book Appointment", showBack: !_isSubmitting),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Pet",
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedPet,
              items: _pets.map((pet) {
                return DropdownMenuItem<String>(
                  value: pet['id'],
                  child: Text(pet['name'] ?? ''),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedPet = val),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Vet",
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedVet,
              items: _vets.map((vet) {
                return DropdownMenuItem<String>(
                  value: vet['id'],
                  child: Text(vet['name'] ?? ''),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedVet = val),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Select Date"),
              subtitle: Text(
                _selectedDate == null
                    ? "No date chosen"
                    : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
              ),
              trailing: ElevatedButton(
                onPressed: _pickDate,
                child: const Text("Pick Date"),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _bookAppointment,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text("Book Appointment"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
