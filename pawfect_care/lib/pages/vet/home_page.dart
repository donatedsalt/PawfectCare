import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/custom_card.dart';
import 'package:pawfect_care/widgets/slide_fade_in.dart';

import 'package:pawfect_care/pages/vet/all_patients_page.dart';
import 'package:pawfect_care/pages/vet/add_appointment_page.dart';
import 'package:pawfect_care/pages/vet/all_appointments_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in first."));
    }

    final userId = user.uid;
    final userName = user.displayName ?? 'User';

    final appointmentsRef = FirebaseFirestore.instance.collection(
      'appointments',
    );
    final patientsRef = FirebaseFirestore.instance.collection('patients');

    return Column(
      children: [
        _buildWelcomeBanner(context, userName),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards row with animation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SlideFadeIn(
                      beginOffset: const Offset(-0.3, 0),
                      delayMs: 100,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: appointmentsRef
                            .where('vetId', isEqualTo: userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CustomCard(
                              type: CustomCardType.summary,
                              title: "Appointments",
                              count: 0,
                              icon: Icons.calendar_today,
                            );
                          }
                          final count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return CustomCard(
                            type: CustomCardType.summary,
                            title: "Appointments",
                            count: count,
                            icon: Icons.calendar_today,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AllAppointmentsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SlideFadeIn(
                      beginOffset: const Offset(0.3, 0),
                      delayMs: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: patientsRef.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CustomCard(
                              type: CustomCardType.summary,
                              title: "Patients",
                              count: 0,
                              icon: Icons.pets,
                            );
                          }
                          final count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return CustomCard(
                            type: CustomCardType.summary,
                            title: "Patients",
                            count: count,
                            icon: Icons.pets,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AllPatientsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Appointments list with stagger animation
              _buildAppointmentsList(context, appointmentsRef, userId),
              const SizedBox(height: 16),

              // Quick actions with pop animation
              Column(
                children: [
                  SlideFadeIn(
                    beginOffset: const Offset(0, 0.3),
                    delayMs: 300,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAppointmentPage(),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: const CustomCard(
                          type: CustomCardType.quickAction,
                          title: 'New Appointment',
                          icon: Icons.add_box,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String userName) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        final safeValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -30),
            child: Opacity(opacity: safeValue, child: child),
          ),
        );
      },
      child: CustomAppBar("Welcome, Dr. $userName."),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    CollectionReference appointmentsRef,
    String userId,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsRef
          .where('vetId', isEqualTo: userId)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const CustomCard(
            title: 'No appointments found.',
            type: CustomCardType.empty,
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: docs.asMap().entries.map((entry) {
            final i = entry.key;
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp?)?.toDate();
            final dateStr = date != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                : "Unknown date";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: _deleteBackground(context),
                confirmDismiss: (_) async {
                  await doc.reference.delete();
                  return true;
                },
                child: StaggeredTile(
                  index: i,
                  child: _appointmentTile(context, data, dateStr),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _appointmentTile(
    BuildContext context,
    Map<String, dynamic> data,
    String dateStr,
  ) {
    return Container(
      decoration: _tileDecoration(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withAlpha(150),
          child: Icon(
            Icons.pets,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          "${data['petName'] ?? 'Unknown Pet'} - ${data['type'] ?? 'General'}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        subtitle: Text(
          "${data['ownerName'] ?? 'Unknown Owner'} • $dateStr",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllAppointmentsPage()),
        ),
      ),
    );
  }

  BoxDecoration _tileDecoration(BuildContext context) {
    return BoxDecoration(
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
        BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 6)),
      ],
    );
  }

  Widget _deleteBackground(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
    );
  }
}

class StaggeredTile extends StatefulWidget {
  final Widget child;
  final int index;
  final int baseDelayMs;
  final Duration duration;

  const StaggeredTile({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 100,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  StaggeredTileState createState() => StaggeredTileState();
}

class StaggeredTileState extends State<StaggeredTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(
      Duration(milliseconds: widget.index * widget.baseDelayMs),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final v = _animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 20),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HomePageFloatingActionButton extends StatelessWidget {
  const HomePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
      ),
      child: Icon(
        Icons.add_box,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

class HomePageNavigationDestination extends StatelessWidget {
  const HomePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: "Home",
    );
  }
}
