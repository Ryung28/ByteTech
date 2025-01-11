import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/reportpage/reusable_reportpage.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            ReportHeader(
              onBackPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            ReportSearchFilter(
              searchController: _searchController,
              selectedStatus: _selectedStatus,
              statusFilters: _statusFilters,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onStatusChanged: (value) =>
                  setState(() => _selectedStatus = value!),
            ),
            Expanded(
              child: _buildReportsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredReportsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('failed-precondition')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.build, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Setting up database indexes...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This may take a few minutes.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = _filterReports(snapshot.data!.docs);

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No reports found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final data = doc.data() as Map<String, dynamic>;
            DateTime? timestamp;

            // Try to get timestamp from different fields
            if (data['timestamp'] != null) {
              timestamp = (data['timestamp'] as Timestamp).toDate();
            } else if (data['createdAt'] != null) {
              if (data['createdAt'] is Timestamp) {
                timestamp = (data['createdAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is String) {
                timestamp = DateTime.parse(data['createdAt']);
              }
            }

            // Fallback to current time if no valid timestamp found
            timestamp ??= DateTime.now();

            print('📄 Processing report ${doc.id}:');
            print('   Status: ${data['status']}');
            print('   Timestamp: $timestamp');

            return ReportCard(
              reportId: doc.id,
              data: data,
              timestamp: timestamp,
              onUpdateStatus: () =>
                  _showUpdateStatusDialog(doc.id, data['status'] ?? 'Pending'),
              onDelete: () => _showDeleteConfirmation(doc.id),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredReportsStream() {
    print('🔍 Getting filtered reports stream');
    print('   Status filter: $_selectedStatus');
    print('   Search query: $_searchQuery');

    var query = FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('timestamp', descending: true);

    if (_selectedStatus != 'All') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return query.snapshots();
  }

  List<QueryDocumentSnapshot> _filterReports(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;

    final searchLower = _searchQuery.toLowerCase();
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Check various fields for the search query
      return data['name']?.toString().toLowerCase().contains(searchLower) ==
              true ||
          data['email']?.toString().toLowerCase().contains(searchLower) ==
              true ||
          data['phone']
                  ?.toString()
                  .toLowerCase()
                  .contains(searchLower) ==
              true ||
          data['address']?.toString().toLowerCase().contains(searchLower) ==
              true ||
          data['complaint']?.toString().toLowerCase().contains(searchLower) ==
              true;
    }).toList();
  }

  Future<void> _showUpdateStatusDialog(
      String reportId, String currentStatus) async {
    String selectedStatus = currentStatus;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select new status:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _statusFilters
                        .where((status) => status != 'All')
                        .map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedStatus = value!);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(reportId)
                    .update({
                  'status': selectedStatus,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error updating status: $e');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String reportId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
            'Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(reportId)
                    .delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error deleting report: $e');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
