import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/reusable_widget/reusable_banperiod.dart';

class BanPeriodCalendar extends StatefulWidget {
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool isAdmin;

  const BanPeriodCalendar({
    Key? key,
    this.onDateRangeSelected,
    this.initialStartDate,
    this.initialEndDate,
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

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
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

  bool _isStartDate(DateTime date) {
    return _startDate != null && date.isAtSameMomentAs(_startDate!);
  }

  bool _isEndDate(DateTime date) {
    return _endDate != null && date.isAtSameMomentAs(_endDate!);
  }

  void _showEditConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirm Changes'),
        content: Text('Are you sure you want to update the ban period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ban period updated successfully'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ),
              );
              setState(() => _isEditing = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1ABC9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final screenWidth = MediaQuery.of(context).size.width;
    final calendarSize = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 150),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
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
                              buildCalendarGridView(
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startDate != null 
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Not set',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.blue.shade100,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE57373),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'End Date',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _endDate != null 
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Not set',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (widget.isAdmin)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: 8,
              child: IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_circle : Icons.edit,
                  color: _isEditing ? const Color(0xFF1ABC9C) : Colors.grey,
                ),
                onPressed: () => _isEditing 
                    ? _showEditConfirmation() 
                    : setState(() => _isEditing = true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}