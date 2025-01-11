import 'package:cloud_firestore/cloud_firestore.dart';

class RecentActivitiesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getRecentReports() async {
    try {
      final QuerySnapshot reportSnapshot = await _firestore
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return reportSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'title': 'Report #${data['complaintNumber'] ?? ''}',
          'time': _formatTimestamp(data['timestamp'] as Timestamp?),
          'description': data['complaint'] ?? 'No description available',
          'type': 'report',
          'status': data['status'] ?? 'Pending'
        };
      }).toList();
    } catch (e) {
      print('Error fetching recent reports: $e');
      return [];
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
