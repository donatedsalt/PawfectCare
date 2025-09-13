import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/pages/user/add_appointment_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  late Future<void> _fetchAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAppointmentsFuture = _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final newAppointments = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        final petName = data['petName'] ?? 'Unnamed Pet';
        final vetId = data['vetId'] ?? '';

        final vetDoc =
            await FirebaseFirestore.instance.collection('users').doc(vetId).get();
        final vetName = vetDoc.data()?['name'] ?? 'Unnamed Vet';

        final appointmentDetails = {
          'id': doc.id,
          'display': '$vetName - $petName',
        };

        if (newAppointments.containsKey(normalizedDate)) {
          newAppointments[normalizedDate]!.add(appointmentDetails);
        } else {
          newAppointments[normalizedDate] = [appointmentDetails];
        }
      }

      setState(() {
        _appointments = newAppointments;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _confirmCancelAppointment(
      DateTime day, Map<String, dynamic> appointment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );

    if (result == true) {
      // Optimistic update: remove from local list first for faster UI feedback
      setState(() {
        _appointments[day]?.remove(appointment);
      });

      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointment['id'])
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment canceled successfully')),
        );
      } catch (e) {
        // On failure, restore the appointment locally
        setState(() {
          if (_appointments[day] != null) {
            _appointments[day]!.add(appointment);
          } else {
            _appointments[day] = [appointment];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar("Book Appointment"),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _fetchAppointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading appointments."));
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TableCalendar<String>(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _getAppointmentsForDay(day)
                        .map((e) => e['display'] as String)
                        .toList(),
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
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      outsideTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 4,
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: _selectedDay == null
                        ? Center(
                            child: Text(
                              "Select a date",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final appointments = _getAppointmentsForDay(
                                _selectedDay!,
                              );
                              if (appointments.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No appointments on this day",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: appointments.length,
                                itemBuilder: (context, index) {
                                  final appointment = appointments[index];
                                  return Card(
                                    color: Theme.of(context).colorScheme.primary,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      title: Text(
                                        appointment['display'],
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.surface,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () => _confirmCancelAppointment(
                                            _selectedDay!, appointment),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: const AppointmentPageFloatingActionButton(),
    );
  }
}

class AppointmentPageFloatingActionButton extends StatelessWidget {
  const AppointmentPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAppointmentPage()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class AppointmentPageNavigationDestination extends StatelessWidget {
  const AppointmentPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.local_hospital_outlined),
      selectedIcon: const Icon(Icons.local_hospital),
      label: "Appointment",
    );
  }
}
