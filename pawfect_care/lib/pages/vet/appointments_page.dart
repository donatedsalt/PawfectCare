import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 🎨 Brand Colors (HomePage ke theme ke hisaab se)
class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromARGB(255, 196, 255, 232);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
  static const Color fabGreen = Color(0xFF32C48D);
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final ValueNotifier<List<String>> _selectedAppointments;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Example appointments: Map of Date -> List of appointment titles
  final Map<DateTime, List<String>> _appointments = {
    DateTime.utc(2025, 9, 12): ['Bella - Check-up', 'Max - Vaccination'],
    DateTime.utc(2025, 9, 13): ['Luna - Surgery Follow-up'],
  };

  List<String> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedAppointments = ValueNotifier(
      _getAppointmentsForDay(_selectedDay!),
    );
  }

  @override
  void dispose() {
    _selectedAppointments.dispose();
    super.dispose();
  }

  void _addAppointment(String title) {
    final dateKey = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    if (_appointments.containsKey(dateKey)) {
      _appointments[dateKey]!.add(title);
    } else {
      _appointments[dateKey] = [title];
    }
    _selectedAppointments.value = _getAppointmentsForDay(_selectedDay!);
  }

  void _removeAppointment(String title) {
    final dateKey = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    _appointments[dateKey]?.remove(title);
    _selectedAppointments.value = _getAppointmentsForDay(_selectedDay!);
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
                        BrandColors.primaryBlue
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
                      "Appointments Calendar",
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

            // 📅 Table Calendar
            TableCalendar<String>(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(
                  color: BrandColors.cardBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                weekendDecoration: BoxDecoration(
                  color: BrandColors.cardBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                todayDecoration: BoxDecoration(
                  color: BrandColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: BrandColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(color: BrandColors.textWhite),
                weekendTextStyle: const TextStyle(color: BrandColors.textWhite),
                outsideTextStyle: const TextStyle(color: BrandColors.textGrey),
                todayTextStyle: const TextStyle(
                  color: BrandColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: const TextStyle(
                  color: BrandColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: BrandColors.accentGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronMargin: const EdgeInsets.symmetric(horizontal: 8),
                rightChevronMargin: const EdgeInsets.symmetric(horizontal: 8),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BrandColors.accentGreen, // background color
                    shape: BoxShape.circle, // circular background
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: BrandColors.textWhite,
                    size: 20,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BrandColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: BrandColors.textWhite,
                    size: 20,
                  ),
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedAppointments.value = _getAppointmentsForDay(
                    selectedDay,
                  );
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final dayAppointments = _getAppointmentsForDay(day);
                  if (dayAppointments.isNotEmpty) {
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

            const SizedBox(height: 10),

            // 📋 Appointments List
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _selectedAppointments,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return const Center(
                      child: Text(
                        "No appointments for this day",
                        style: TextStyle(color: BrandColors.textWhite),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final appointment = value[index];
                      return Card(
                        color: BrandColors.cardBlue,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            appointment,
                            style:
                                const TextStyle(color: BrandColors.textWhite),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeAppointment(appointment),
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
      ),

      // ➕ Add Appointment FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.fabGreen,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController _controller = TextEditingController();
              return AlertDialog(
                backgroundColor: BrandColors.cardBlue,
                title: const Text(
                  "Add Appointment",
                  style: TextStyle(color: BrandColors.textWhite),
                ),
                content: TextField(
                  controller: _controller,
                  style: const TextStyle(color: BrandColors.textWhite),
                  decoration: const InputDecoration(
                    hintText: "Enter appointment title",
                    hintStyle: TextStyle(color: BrandColors.textGrey),
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
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _addAppointment(_controller.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.accentGreen,
                    ),
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AppointmentsPageNavigationDestination extends StatelessWidget {
  const AppointmentsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(
        Icons.calendar_today_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Appointments",
    );
  }
}
