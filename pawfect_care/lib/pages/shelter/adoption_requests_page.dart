import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class AdoptionRequestsPage extends StatefulWidget {
  const AdoptionRequestsPage({super.key});

  @override
  State<AdoptionRequestsPage> createState() => _AdoptionRequestsPageState();
}

class _AdoptionRequestsPageState extends State<AdoptionRequestsPage> {
  final List<String> statuses = const [
    'pending',
    'requested',
    'available',
    'adopted',
    'rejected',
  ];

  // Map to hold dropdown selected values
  final Map<String, String> selectedStatuses = {};

  Future<Map<String, String>> fetchNames(String petId, String userId) async {
    final petDoc = await FirebaseFirestore.instance
        .collection('pets')
        .doc(petId)
        .get();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final petName = petDoc.exists
        ? (petDoc.data()?['name'] ?? 'Unknown Pet')
        : 'Unknown Pet';
    final userName = userDoc.exists
        ? (userDoc.data()?['name'] ?? 'Unknown User')
        : 'Unknown User';

    return {'petName': petName, 'userName': userName};
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'available':
        return Colors.orange;
      case 'adopted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar("Adoption Requests"),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('adoptionRequests')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No Adoption Requests Found",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: requests.length,
                itemBuilder: (_, index) {
                  final request = requests[index];
                  final requestId = request.id;
                  final requestData = request.data() as Map<String, dynamic>;

                  final petId = requestData['petId'] ?? 'Unknown';
                  final userId = requestData['userId'] ?? 'Unknown';
                  final status = (requestData['status'] ?? 'available')
                      .toString()
                      .toLowerCase()
                      .trim();
                  final timestamp = requestData['timestamp'] != null
                      ? (requestData['timestamp'] as Timestamp).toDate()
                      : DateTime.now();
                  final formattedDate = DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(timestamp);

                  // Initialize selected status if not already
                  selectedStatuses.putIfAbsent(requestId, () => status);

                  return FutureBuilder<Map<String, String>>(
                    future: fetchNames(petId, userId),
                    builder: (context, nameSnapshot) {
                      final petName =
                          nameSnapshot.data?['petName'] ?? 'Loading...';
                      final userName =
                          nameSnapshot.data?['userName'] ?? 'Loading...';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(200),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pet: $petName",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Requested By: $userName",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Requested At: $formattedDate",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              value: selectedStatuses[requestId],
                              items: statuses.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(
                                    s[0].toUpperCase() +
                                        s.substring(1), // display nicely
                                    style: TextStyle(
                                      color: getStatusColor(s),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newStatus) async {
                                if (newStatus != null) {
                                  if (newStatus == 'rejected') {
                                    // Delete the adoption request if rejected
                                    await FirebaseFirestore.instance
                                        .collection('adoptionRequests')
                                        .doc(requestId)
                                        .delete();

                                    setState(() {
                                      selectedStatuses.remove(requestId);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Adoption request rejected and deleted.",
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Otherwise, just update the status
                                    await FirebaseFirestore.instance
                                        .collection('adoptionRequests')
                                        .doc(requestId)
                                        .update({'status': newStatus});

                                    setState(() {
                                      selectedStatuses[requestId] = newStatus;
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
