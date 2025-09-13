import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/pages/user/add_appointment_page.dart';

class AppointmentPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppointmentPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Book Appointment'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<String>> _appointments = {};
  late Future<void> _fetchAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAppointmentsFuture = _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final newAppointments = <DateTime, List<String>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        final petName = data['petName'] ?? 'Unnamed Pet';
        final vetId = data['vetId'] ?? '';

        // Fetch vet's name
        final vetDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(vetId)
            .get();
        final vetName = vetDoc.data()?['name'] ?? 'Unnamed Vet';

        final appointmentDetails = '$vetName - $petName';

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
      // In a real app, you would want to handle this error more gracefully,
      // maybe showing an error message to the user.
      print("Error fetching appointments: $e");
    }
  }

  List<String> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
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
                    eventLoader: _getAppointmentsForDay,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: appointments.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        appointments[index],
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
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
      selectedIcon: Icon(Icons.local_hospital),
      label: "Appointment",
    );
  }
}
