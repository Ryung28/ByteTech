import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/userdashboard/banperioidpage/reusable_banperiod.dart';
import 'package:mobileapplication/userdashboard/banperioidpage/banperiodcalender_page.dart';
import 'package:mobileapplication/admindashboard/banpage/ban_period_service.dart';
import 'package:mobileapplication/admindashboard/banpage/notification_service.dart';
import 'package:intl/intl.dart'; // Added import statement

class BanPeriodSchedulePage extends StatefulWidget {
  const BanPeriodSchedulePage({Key? key}) : super(key: key);

  @override
  State<BanPeriodSchedulePage> createState() => _BanPeriodSchedulePageState();
}

class _BanPeriodSchedulePageState extends State<BanPeriodSchedulePage> {
  final BanPeriodService _banPeriodService = BanPeriodService();
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadCurrentBanPeriod();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadCurrentBanPeriod() async {
    if (_isDisposed) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('banPeriod')
          .doc('schedule')
          .get();

      if (_isDisposed) return;
      if (doc.exists) {
        final data = doc.data();
        if (mounted) {
          setState(() {
            _currentStartDate = (data?['startDate'] as Timestamp?)?.toDate();
            _currentEndDate = (data?['endDate'] as Timestamp?)?.toDate();
          });
        }
      }
    } catch (e) {
      print('Error loading ban period: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ban period: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBanPeriod(DateTime startDate, DateTime endDate) async {
    if (_isDisposed) return;
    
    // Show confirmation dialog
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ban Period Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to set this ban period?'),
            const SizedBox(height: 16),
            Text('Start: ${DateFormat('MMM d, yyyy').format(startDate)}'),
            Text('End: ${DateFormat('MMM d, yyyy').format(endDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldUpdate) {
      setState(() {
        _selectedStartDate = null;
        _selectedEndDate = null;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      print('Attempting to update ban period...');
      await _banPeriodService.updateBanPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      if (_isDisposed) return;
      if (mounted) {
        setState(() {
          _currentStartDate = startDate;
          _currentEndDate = endDate;
          _selectedStartDate = null;
          _selectedEndDate = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ban period updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error in _updateBanPeriod: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating ban period: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    await NotificationService.requestPermissions();
    await NotificationService.listenToBanPeriodChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: BanPeriodCalendar(
                        isAdmin: true,
                        onDateRangeSelected: (startDate, endDate) {
                          setState(() {
                            _selectedStartDate = startDate;
                            _selectedEndDate = endDate;
                          });
                        },
                      ),
                    ),
                    if (_selectedStartDate != null && _selectedEndDate != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                _updateBanPeriod(_selectedStartDate!, _selectedEndDate!);
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_rounded),
                                  SizedBox(width: 8),
                                  Text('Save Ban Period'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedStartDate = null;
                                  _selectedEndDate = null;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blue.shade200.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ban Period History',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: AnimatedRotation(
                                    duration: const Duration(milliseconds: 300),
                                    turns: _showHistory ? 0.5 : 0,
                                    child: Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 28,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showHistory = !_showHistory;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: _showHistory 
                                ? CrossFadeState.showFirst 
                                : CrossFadeState.showSecond,
                            firstChild: Container(
                              constraints: const BoxConstraints(maxHeight: 400),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _banPeriodService.getBanPeriodHistory(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Error: ${snapshot.error}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                            textAlign: TextAlign.center,
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

                                  final history = snapshot.data!.docs;
                                  if (history.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.history_rounded,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No history available yet',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    shrinkWrap: true,
                                    itemCount: history.length,
                                    itemBuilder: (context, index) {
                                      final record = history[index].data() as Map<String, dynamic>;
                                      final startDate = (record['startDate'] as Timestamp).toDate();
                                      final endDate = (record['endDate'] as Timestamp).toDate();
                                      final updatedAt = (record['archivedAt'] as Timestamp).toDate();

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      Icons.calendar_today_rounded,
                                                      size: 20,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Previous Ban Period',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Start',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          DateFormat('MMM d, yyyy').format(startDate),
                                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 1,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 16),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'End',
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            DateFormat('MMM d, yyyy').format(endDate),
                                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Archived ${DateFormat('MMM d, yyyy • HH:mm').format(updatedAt)}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            secondChild: const SizedBox(height: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}