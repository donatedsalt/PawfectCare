import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/pages/vet/add_patient_page.dart';
import 'package:pawfect_care/pages/vet/appointments_detail_page.dart';
import 'package:pawfect_care/pages/vet/new_appointment_page.dart';
import 'package:pawfect_care/pages/vet/patients_detail_page.dart';
import 'package:pawfect_care/pages/vet/reports_page.dart';

class BrandColors {
  static const Color primaryBlue = Color.fromRGBO(38, 49, 100, 1);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromRGBO(222, 239, 255, 1);
  static const Color cardBlue = Color.fromRGBO(38, 49, 100, 0.9);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
  static const Color fabGreen = Color(0xFF32C48D);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<Map<String, dynamic>> quickActions = [
    {'title': 'Add Patient', 'icon': Icons.person_add},
    {'title': 'New Appointment', 'icon': Icons.add_box},
    {'title': 'Reports', 'icon': Icons.bar_chart},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    final appointmentsRef = FirebaseFirestore.instance.collection(
      'appointments',
    );
    final patientsRef = FirebaseFirestore.instance.collection('patients');

    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 👋 Welcome
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "Welcome back, Dr. $userName 👋",
                style: const TextStyle(
                  color: BrandColors.accentGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // 📊 Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: appointmentsRef.snapshots(),
                    builder: (context, snapshot) {
                      int count = snapshot.hasData
                          ? snapshot.data!.docs.length
                          : 0;
                      return _summaryCard(
                        context,
                        'Appointments',
                        count,
                        Icons.calendar_today,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: patientsRef.snapshots(),
                    builder: (context, snapshot) {
                      int count = snapshot.hasData
                          ? snapshot.data!.docs.length
                          : 0;
                      return _summaryCard(
                        context,
                        'Patients',
                        count,
                        Icons.pets,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📅 Appointments List
            StreamBuilder<QuerySnapshot>(
              stream: appointmentsRef.orderBy('date').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return _emptyCard("No appointments found.");
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _appointmentCard(
                      context,
                      doc.id,
                      data,
                      doc.reference,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 16),

            // ⚡ Quick Actions
            Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;
                    if (width > 1200) {
                      crossAxisCount = 4;
                    } else if (width > 800) {
                      crossAxisCount = 3;
                    }

                    final otherActions = quickActions
                        .where((a) => a['title'] != 'Reports')
                        .toList();

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                      children: otherActions.map((action) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              switch (action['title']) {
                                case 'Add Patient':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddPatientPage(),
                                    ),
                                  );
                                  break;
                                case 'New Appointment':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NewAppointmentPage(),
                                    ),
                                  );
                                  break;
                              }
                            },
                            child: _quickActionCard(
                              action['title'],
                              action['icon'],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsPage()),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: _quickActionCard('Reports', Icons.bar_chart),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: const HomePageFloatingActionButtonExpanded(),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            onTap: () {
              if (title == "Appointments") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppointmentsDetailPage(),
                  ),
                );
              } else if (title == "Patients") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientsDetailPage()),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, size: 30, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: BrandColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _appointmentCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    DocumentReference ref,
  ) {
    final date = (data['date'] as Timestamp?)?.toDate();
    final dateStr = date != null
        ? "${date.day}-${date.month}-${date.year}"
        : "Unknown date";

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Dismissible(
              key: Key(id),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.delete();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: BrandColors.cardBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: BrandColors.accentGreen.withOpacity(0.25),
                    child: const Icon(Icons.pets, color: BrandColors.textWhite),
                  ),
                  title: Text(
                    "${data['petName'] ?? 'Unknown Pet'} - ${data['type'] ?? 'General'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BrandColors.textWhite,
                    ),
                  ),
                  subtitle: Text(
                    "${data['ownerName'] ?? 'Unknown Owner'} • $dateStr • ${data['time'] ?? ''}",
                    style: const TextStyle(color: BrandColors.textGrey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: BrandColors.textGrey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentsDetailPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _quickActionCard(String title, IconData icon) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.accentGreen.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: BrandColors.accentGreen),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: BrandColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyCard(String text) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: BrandColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageFloatingActionButtonExpanded extends StatefulWidget {
  const HomePageFloatingActionButtonExpanded({super.key});

  @override
  State<HomePageFloatingActionButtonExpanded> createState() =>
      _HomePageFloatingActionButtonExpandedState();
}

class _HomePageFloatingActionButtonExpandedState
    extends State<HomePageFloatingActionButtonExpanded>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void toggleMenu() {
    if (isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => isOpen = !isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: isOpen ? 200 : 56,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 70,
            right: 0,
            child: ScaleTransition(
              scale: _controller,
              child: FloatingActionButton(
                heroTag: "home_add_patient_fab",
                mini: true,
                backgroundColor: BrandColors.accentGreen,
                child: const Icon(
                  Icons.person_add,
                  color: BrandColors.textWhite,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPatientPage()),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 0,
            child: ScaleTransition(
              scale: _controller,
              child: FloatingActionButton(
                heroTag: "home_new_appointment_fab",
                mini: true,
                backgroundColor: BrandColors.accentGreen,
                child: const Icon(Icons.add_box, color: BrandColors.textWhite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewAppointmentPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "home_main_fab",
            backgroundColor: BrandColors.accentGreen,
            onPressed: toggleMenu,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
              color: BrandColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HomePageNavigationDestination extends StatelessWidget {
  const HomePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: "Home",
    );
  }
}
