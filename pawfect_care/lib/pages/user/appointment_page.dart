import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pawfect_care/pages/user/add_appointment_page.dart';

/// 🎨 Colors same as before (you can import BrandColors if already defined)
class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromARGB(255, 196, 255, 232);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
}

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

  // Appointments fetched from Firestore
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
      backgroundColor: BrandColors.darkBackground,
      body: FutureBuilder(
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
                // 📅 Calendar
                TableCalendar<String>(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getAppointmentsForDay,
                  calendarStyle: CalendarStyle(
                    defaultDecoration: BoxDecoration(
                      color: BrandColors.cardBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    weekendDecoration: BoxDecoration(
                      color: BrandColors.cardBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    todayDecoration: const BoxDecoration(
                      color: BrandColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: BrandColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(
                      color: BrandColors.textWhite,
                    ),
                    weekendTextStyle: const TextStyle(
                      color: BrandColors.textWhite,
                    ),
                    outsideTextStyle: const TextStyle(
                      color: BrandColors.textGrey,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: BrandColors.accentGreen,
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 📋 Appointment List
                Expanded(
                  child: _selectedDay == null
                      ? const Center(
                          child: Text(
                            "Select a date",
                            style: TextStyle(color: BrandColors.textWhite),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final appointments = _getAppointmentsForDay(
                              _selectedDay!,
                            );
                            if (appointments.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No appointments on this day",
                                  style: TextStyle(
                                    color: BrandColors.textWhite,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: BrandColors.cardBlue,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      appointments[index],
                                      style: const TextStyle(
                                        color: BrandColors.textWhite,
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
