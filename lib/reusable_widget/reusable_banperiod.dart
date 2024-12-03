import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildCalendarGridView({
  required List<DateTime> days,
  required DateTime currentMonth,
  required DateTime? startDate,
  required DateTime? endDate,
  required bool isAdmin,
  required bool isEditing,
  required Function(DateTime, DateTime)? onDateRangeSelected,
  required Function(DateTime) startDateCallback,
  required Function(DateTime) endDateCallback,
  required double calendarSize,
}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7,
      childAspectRatio: 1,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    ),
    itemCount: days.length,
    itemBuilder: (context, index) {
      final date = days[index];
      final isCurrentMonth = date.month == currentMonth.month;
      final isStartDate = startDate != null && date.isAtSameMomentAs(startDate);
      final isEndDate = endDate != null && date.isAtSameMomentAs(endDate);

      return buildCalendarDayCell(
        date: date,
        isCurrentMonth: isCurrentMonth,
        isStartDate: isStartDate,
        isEndDate: isEndDate,
        isEnabled: isCurrentMonth && (isAdmin || isEditing),
        onTap: () {
          if (startDate == null || endDate != null) {
            startDateCallback(date);
          } else {
            if (date.isBefore(startDate)) {
              endDateCallback(startDate);
              startDateCallback(date);
            } else {
              endDateCallback(date);
              if (onDateRangeSelected != null) {
                onDateRangeSelected(startDate, date);
              }
            }
          }
        },
      );
    },
  );
}

Widget buildCalendarDayCell({
  required DateTime date,
  required bool isCurrentMonth,
  required bool isStartDate,
  required bool isEndDate,
  required bool isEnabled,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: isEnabled ? onTap : null,
    child: Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isStartDate
            ? const Color(0xFF4CAF50)
            : isEndDate
                ? const Color(0xFFE57373)
                : Colors.transparent,
        border: !isStartDate && !isEndDate && isCurrentMonth
            ? Border.all(color: const Color(0xFF90CAF9))
            : null,
        boxShadow: (isStartDate || isEndDate) ? [
          BoxShadow(
            color: (isStartDate ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: !isCurrentMonth
                ? Colors.grey.withOpacity(0.3)
                : isStartDate || isEndDate
                    ? Colors.white
                    : const Color(0xFF1565C0),
            fontSize: 14,
            fontWeight: isStartDate || isEndDate ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}

Widget buildCalendarHeader({
  required DateTime currentMonth,
  required VoidCallback onPreviousMonth,
  required VoidCallback onNextMonth,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: const BoxDecoration(
      color: Color(0xFF1565C0),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
              onPressed: onPreviousMonth,
              splashRadius: 24,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              onPressed: onNextMonth,
              splashRadius: 24,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildCalendarContainer({
  required double calendarSize,
  required Widget child,
}) {
  return Container(
    width: calendarSize,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget buildDetailsCard({
  required double calendarSize,
}) {
  return Container(
    width: calendarSize,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        buildDateIndicator(
          label: 'Start Date',
          color: const Color(0xFFFF7B7B),
        ),
        const SizedBox(height: 4),
        buildDateIndicator(
          label: 'End Date',
          color: const Color(0xFF7BDCB5),
        ),
      ],
    ),
  );
}

Widget buildDateIndicator({
  required String label,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    ],
  );
}
