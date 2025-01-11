import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'reusable_banperiod.dart';
import 'package:mobileapplication/admindashboard/banpage/ban_period_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BanPeriodCalendar extends StatefulWidget {
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final bool isAdmin;

  const BanPeriodCalendar({
    Key? key,
    this.onDateRangeSelected,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  _BanPeriodCalendarState createState() => _BanPeriodCalendarState();
}

class _BanPeriodCalendarState extends State<BanPeriodCalendar> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEditing = false;
  bool _isLoading = true;
  StreamSubscription? _banPeriodSubscription;
  final BanPeriodService _banPeriodService = BanPeriodService();
  final _updateController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _setupBanPeriodStream();
  }

  void _setupBanPeriodStream() {
    // Create a debounced stream for updates
    _updateController.stream
        .distinct((previous, next) {
          final prevStart = previous['startDate'] as Timestamp?;
          final prevEnd = previous['endDate'] as Timestamp?;
          final nextStart = next['startDate'] as Timestamp?;
          final nextEnd = next['endDate'] as Timestamp?;
          
          return prevStart?.toDate() == nextStart?.toDate() && 
                 prevEnd?.toDate() == nextEnd?.toDate();
        })
        .listen(_updateBanPeriod);

    // Subscribe to Firestore updates
    _banPeriodSubscription = _banPeriodService.getCurrentBanPeriod().listen(
      (snapshot) {
        if (!mounted || _isEditing) return;
        
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          _updateController.add(data);
        }
        
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onError: (error) {
        print('Error in ban period stream: $error');
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _updateBanPeriod(Map<String, dynamic> data) {
    if (!mounted || _isEditing) return;
    
    final startTimestamp = data['startDate'] as Timestamp?;
    final endTimestamp = data['endDate'] as Timestamp?;
    
    final newStartDate = startTimestamp?.toDate();
    final newEndDate = endTimestamp?.toDate();
    
    if (_startDate != newStartDate || _endDate != newEndDate) {
      setState(() {
        _startDate = newStartDate;
        _endDate = newEndDate;
      });
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysBefore = first.weekday - 1;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    
    final last = DateTime(month.year, month.month + 1, 0);
    final daysAfter = 7 - last.weekday;
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return List.generate(
      lastToDisplay.difference(firstToDisplay).inDays + 1,
      (index) => firstToDisplay.add(Duration(days: index)),
    );
  }

  @override
  void dispose() {
    _banPeriodSubscription?.cancel();
    _updateController.close();
    super.dispose();
  }

  void _showEditConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirm Changes'),
        content: const Text('Are you sure you want to update the ban period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (_startDate == null || _endDate == null) {
                  throw Exception('Please select both start and end dates');
                }
                Navigator.pop(context);
                
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating ban period...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                await _banPeriodService.updateBanPeriod(
                  startDate: _startDate!,
                  endDate: _endDate!,
                );
                
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ban period updated successfully'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() => _isEditing = false);
              } catch (e) {
                if (!mounted) return;
                
                // Show error in a dialog for better visibility
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ABC9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final screenWidth = MediaQuery.of(context).size.width;
    final double calendarSize = widget.isAdmin
        ? 550.0
        : screenWidth * 1;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isAdmin ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1565C0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: !widget.isAdmin,
        title: const Text(
          'Ban Period Calendar',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Container(
                          width: calendarSize,
                          margin: EdgeInsets.only(bottom: widget.isAdmin ? 10 : 18),
                          padding: EdgeInsets.symmetric(
                            vertical: widget.isAdmin ? 8 : 16,
                            horizontal: widget.isAdmin ? 12 : 20
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ban Period Schedule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: widget.isAdmin ? 8 : 16,
                                        vertical: widget.isAdmin ? 8 : 12
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Start Date',
                                            style: TextStyle(
                                              color: Color(0xFF4CAF50),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _startDate != null
                                                ? DateFormat('MMMM d').format(_startDate!)
                                                : 'Not set',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'End Date',
                                            style: TextStyle(
                                              color: Color(0xFFE57373),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _endDate != null
                                                ? DateFormat('MMMM d').format(_endDate!)
                                                : 'Not set',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: widget.isAdmin ? 10 : 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: buildCalendarContainer(
                            calendarSize: calendarSize,
                            child: Column(
                              children: [
                                buildCalendarHeader(
                                  currentMonth: _currentMonth,
                                  onPreviousMonth: () => setState(() {
                                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                                  }),
                                  onNextMonth: () => setState(() {
                                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                                  }),
                                ),
                                CalendarGridView(
                                  calendarSize: calendarSize,
                                  days: days,
                                  currentMonth: _currentMonth,
                                  startDate: _startDate,
                                  endDate: _endDate,
                                  isAdmin: widget.isAdmin,
                                  isEditing: _isEditing,
                                  onDateRangeSelected: widget.onDateRangeSelected,
                                  startDateCallback: (DateTime date) {
                                    setState(() {
                                      _startDate = date;
                                      _endDate = null;
                                    });
                                  },
                                  endDateCallback: (DateTime date) {
                                    setState(() {
                                      _endDate = date;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      floatingActionButton: widget.isAdmin ? FloatingActionButton(
        onPressed: () => _isEditing 
            ? _showEditConfirmation() 
            : setState(() => _isEditing = true),
        child: Icon(
          _isEditing ? Icons.check_circle : Icons.edit,
          color: _isEditing ? Colors.white : Colors.grey[300],
        ),
        backgroundColor: _isEditing ? const Color(0xFF1ABC9C) : Colors.white,
      ) : null,
    );
  }
}