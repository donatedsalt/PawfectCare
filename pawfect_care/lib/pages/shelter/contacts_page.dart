import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class ContactVolunteerPage extends StatelessWidget {
  const ContactVolunteerPage({super.key});

  /// Mark request as processed
  Future<void> _markProcessed(
    String collection,
    String docId,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).update(
        {'status': 'Processed'},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request marked as processed")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar("Contact, Volunteer & Donation", showBack: true),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('contactVolunteerRequests')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, contactSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('volunteerRequests')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, volunteerSnapshot) {
                    if (!contactSnapshot.hasData ||
                        !volunteerSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final requests = [
                      ...contactSnapshot.data!.docs.map(
                        (d) => {
                          'doc': d,
                          'collection': 'contactVolunteerRequests',
                        },
                      ),
                      ...volunteerSnapshot.data!.docs.map(
                        (d) => {'doc': d, 'collection': 'volunteerRequests'},
                      ),
                    ];

                    if (requests.isEmpty) {
                      return const Center(
                        child: Text(
                          "No contact, volunteer or donation requests yet.",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final doc = requests[index]['doc'] as DocumentSnapshot;
                        final collection =
                            requests[index]['collection'] as String;
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final status = (data['status'] ?? 'Pending').toString();

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['name'] ?? 'User',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              if (data['email'] != null)
                                Text(
                                  "Email: ${data['email']}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),

                              if (collection == 'volunteerRequests') ...[
                                Text(
                                  "Phone: ${data['phone'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "Skills: ${data['skills'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "Availability: ${data['availability'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],

                              if (collection == 'contactVolunteerRequests') ...[
                                Text(
                                  "Type: ${data['type'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "Message: ${data['message'] ?? '-'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // Action Button
                              if (status == 'Pending')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text("Mark Processed"),
                                    onPressed: () => _markProcessed(
                                      collection,
                                      docId,
                                      context,
                                    ),
                                  ),
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
      ),
    );
  }
}
