import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _fetchMonthAppointments(DateTime focusedDay) async {
    try {
      if (!mounted) return;
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
      final lastDay = DateTime(
        focusedDay.year,
        focusedDay.month + 1,
        0,
        23,
        59,
        59,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('vetId', isEqualTo: currentVetId)
          .where('date', isGreaterThanOrEqualTo: firstDay)
          .where('date', isLessThanOrEqualTo: lastDay)
          .get();

      if (!mounted) return;

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
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage =
            'Failed to load appointments. Please make sure the required Firestore index exists.';
      });
    }
  }

  Future<void> _deleteAppointment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text(
          "Are you sure you want to delete this appointment?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .delete();
      _fetchMonthAppointments(_focusedDay);
    }
  }

  void _showEditAppointmentDialog(Map<String, dynamic> editData) {
    final formKey = GlobalKey<FormState>();
    String petName = editData['petName'];
    String ownerName = editData['ownerName'];
    DateTime appointmentDate = (editData['date'] as Timestamp).toDate();
    TimeOfDay appointmentTime = TimeOfDay(
      hour: appointmentDate.hour,
      minute: appointmentDate.minute,
    );
    String? petId = editData['petId'];
    String? userId = editData['userId'];
    String vetId = currentVetId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Appointment"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: petName,
                  decoration: const InputDecoration(labelText: "Pet Name"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => petName = val!,
                ),
                TextFormField(
                  initialValue: ownerName,
                  decoration: const InputDecoration(labelText: "Owner Name"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => ownerName = val!,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${DateFormat('MMM dd, yyyy').format(appointmentDate)}",
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: appointmentDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setStateDialog(() => appointmentDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text("Time: ${appointmentTime.format(context)}"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: appointmentTime,
                        );
                        if (picked != null) {
                          setStateDialog(() => appointmentTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
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

                if (context.mounted) Navigator.pop(context);
                _fetchMonthAppointments(_focusedDay);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(DateTime day) {
    if (_hasError) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          textAlign: TextAlign.center,
        ),
      );
    }

    final appointments =
        _monthAppointments[DateTime(day.year, day.month, day.day)] ?? [];
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          "No appointments for this day",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final data = appointments[index];
        final date = (data['date'] as Timestamp).toDate();
        return Card(
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              "${data['petName']} - ${data['ownerName']}",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy hh:mm a').format(date),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => _showEditAppointmentDialog(data),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
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
    return Column(
      children: [
        CustomAppBar("Appointments Calendar"),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Divider(),
        ),

        // Table Calendar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarStyle: CalendarStyle(
              defaultDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              weekendDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              outsideTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.secondary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchMonthAppointments(focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final date = DateTime(day.year, day.month, day.day);
                if (_monthAppointments.containsKey(date) &&
                    _monthAppointments[date]!.isNotEmpty) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),

        Padding(padding: const EdgeInsets.all(16), child: Divider()),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Expanded(
              child: _buildAppointmentsList(_selectedDay ?? DateTime.now()),
            ),
          ),
        ),
      ],
    );
  }
}

class AppointmentsPageNavigationDestination extends StatelessWidget {
  const AppointmentsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: "Appointments",
    );
  }
}
