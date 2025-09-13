import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

/// 🎨 Brand Colors
class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color(0xFFD6E3FF);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
}

/// -----------------------------
/// Appointments Page
/// -----------------------------
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final String currentVetId = FirebaseAuth.instance.currentUser!.uid;

  Map<DateTime, List<Map<String, dynamic>>> _monthAppointments = {};
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMonthAppointments(_focusedDay);
  }

  /// 🔹 Fetch appointments for the visible month
  Future<void> _fetchMonthAppointments(DateTime focusedDay) async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
      final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('vetId', isEqualTo: currentVetId)
          .where('date', isGreaterThanOrEqualTo: firstDay)
          .where('date', isLessThanOrEqualTo: lastDay)
          .get();

      Map<DateTime, List<Map<String, dynamic>>> monthData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final day = DateTime(date.year, date.month, date.day);
        if (!monthData.containsKey(day)) monthData[day] = [];
        monthData[day]!.add({...data, 'docId': doc.id});
      }

      setState(() {
        _monthAppointments = monthData;
      });
    } catch (e) {
      debugPrint('Error fetching month appointments: $e');
      setState(() {
        _hasError = true;
        _errorMessage =
            'Failed to load appointments. Please make sure the required Firestore index exists.';
      });
    }
  }

  /// 🔹 Delete Appointment
  Future<void> _deleteAppointment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
      _fetchMonthAppointments(_focusedDay);
    }
  }

  /// 🔹 Edit Appointment Form
  void _showEditAppointmentDialog(Map<String, dynamic> editData) {
    final _formKey = GlobalKey<FormState>();
    String petName = editData['petName'];
    String ownerName = editData['ownerName'];
    DateTime appointmentDate = (editData['date'] as Timestamp).toDate();
    TimeOfDay appointmentTime = TimeOfDay(hour: appointmentDate.hour, minute: appointmentDate.minute);
    String? petId = editData['petId'];
    String? userId = editData['userId'];
    String vetId = currentVetId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Appointment"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: petName,
                  decoration: const InputDecoration(labelText: "Pet Name"),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => petName = val!,
                ),
                TextFormField(
                  initialValue: ownerName,
                  decoration: const InputDecoration(labelText: "Owner Name"),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => ownerName = val!,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text("Date: ${DateFormat('MMM dd, yyyy').format(appointmentDate)}")),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: appointmentDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setStateDialog(() => appointmentDate = picked);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text("Time: ${appointmentTime.format(context)}")),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: appointmentTime,
                        );
                        if (picked != null) setStateDialog(() => appointmentTime = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final appointmentDateTime = DateTime(
                  appointmentDate.year,
                  appointmentDate.month,
                  appointmentDate.day,
                  appointmentTime.hour,
                  appointmentTime.minute,
                );

                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(editData['docId'])
                    .update({
                  'petName': petName,
                  'ownerName': ownerName,
                  'date': appointmentDateTime,
                  'vetId': vetId,
                  'userId': userId,
                  'petId': petId,
                });

                Navigator.pop(context);
                _fetchMonthAppointments(_focusedDay);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Build Appointments List
  Widget _buildAppointmentsList(DateTime day) {
    if (_hasError) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: BrandColors.textWhite), textAlign: TextAlign.center),
      );
    }

    final appointments = _monthAppointments[DateTime(day.year, day.month, day.day)] ?? [];
    if (appointments.isEmpty) {
      return const Center(
        child: Text("No appointments for this day", style: TextStyle(color: BrandColors.primaryBlue)),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final data = appointments[index];
        final date = (data['date'] as Timestamp).toDate();
        return Card(
          color: BrandColors.cardBlue,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text("${data['petName']} - ${data['ownerName']}",
                style: const TextStyle(color: BrandColors.textWhite)),
            subtitle: Text(DateFormat('MMM dd, yyyy hh:mm a').format(date),
                style: const TextStyle(color: BrandColors.textGrey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: BrandColors.accentGreen),
                  onPressed: () => _showEditAppointmentDialog(data),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteAppointment(data['docId']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: const Center(
                child: Text("Appointments Calendar",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BrandColors.textWhite)),
              ),
            ),

            // Table Calendar
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(color: BrandColors.cardBlue, borderRadius: BorderRadius.circular(8)),
                weekendDecoration: BoxDecoration(color: BrandColors.cardBlue, borderRadius: BorderRadius.circular(8)),
                todayDecoration: BoxDecoration(color: BrandColors.accentGreen, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: BrandColors.primaryBlue, shape: BoxShape.circle),
                defaultTextStyle: const TextStyle(color: BrandColors.textWhite),
                weekendTextStyle: const TextStyle(color: BrandColors.textWhite),
                outsideTextStyle: const TextStyle(color: BrandColors.textGrey),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    const TextStyle(color: BrandColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: BrandColors.primaryBlue),
                rightChevronIcon: const Icon(Icons.chevron_right, color: BrandColors.primaryBlue),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchMonthAppointments(focusedDay);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final date = DateTime(day.year, day.month, day.day);
                  if (_monthAppointments.containsKey(date) && _monthAppointments[date]!.isNotEmpty) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent)),
                    );
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 10),
            Expanded(child: _buildAppointmentsList(_selectedDay ?? DateTime.now())),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------
/// Navigation Destination
/// -----------------------------
class AppointmentsPageNavigationDestination extends StatelessWidget {
  const AppointmentsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today_rounded),
      label: "Appointments",
    );
  }
}
