import 'package:flutter/material.dart';

class ChatbotService {
  static const Map<String, String> _menuOptions = {
    '1': 'File a Complaint 📝',
    '2': 'Report Emergency 🚨',
    '3': 'Marine Safety Info ⛵',
    '4': 'Contact Admin 👤',
    '5': 'Help ℹ️',
  };

  static List<Widget> getMainMenuButtons(Function(String) onOptionSelected) {
    return _menuOptions.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onOptionSelected(entry.key),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF48A7FF).withOpacity(0.9),
                    const Color(0xFF48A7FF).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF48A7FF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  static String getResponse(String option) {
    switch (option) {
      case '1':
        return 'You selected File a Complaint. Please choose from the following options:';
      case '2':
        return 'You selected Report Emergency. Our emergency reporting system will be available soon.';
      case '3':
        return 'You selected Marine Safety Info. Here are some important safety topics:';
      case '4':
        return 'You selected Contact Admin. This feature will be available in the next update.';
      case '5':
        return 'Returning to main menu...';
      case 'sub1_1':
        return 'To file a pollution complaint, please provide the following details:\n• Location\n• Type of pollution\n• Date and time observed\n• Description of the incident';
      case 'sub1_2':
        return 'To report illegal fishing, please provide:\n• Location of activity\n• Type of illegal fishing observed\n• Vessel description (if applicable)\n• Date and time';
      case 'sub1_3':
        return 'For other marine-related complaints, please include:\n• Nature of complaint\n• Location\n• Date and time\n• Detailed description';
      case 'sub3_1':
        return 'Marine Weather Safety Tips:\n• Always check weather forecasts before heading out\n• Monitor weather changes while at sea\n• Keep emergency equipment readily available\n• Know emergency protocols';
      case 'sub3_2':
        return 'Navigation Safety Guidelines:\n• Maintain proper lookout\n• Follow maritime traffic rules\n• Keep navigation lights operational\n• Carry updated nautical charts';
      case 'sub3_3':
        return 'Emergency Response Procedures:\n• Stay calm and assess the situation\n• Contact nearest coast guard station\n• Use appropriate distress signals\n• Follow evacuation procedures if necessary';
      default:
        return 'Please select a valid option from the menu.';
    }
  }

  static List<Widget> getComplaintMenuButtons(
      Function(String) onOptionSelected) {
    return [
      _buildMenuButton(
          '1. Report Marine Pollution', 'sub1_1', onOptionSelected),
      _buildMenuButton('2. Report Illegal Fishing', 'sub1_2', onOptionSelected),
      _buildMenuButton(
          '3. Other Marine Complaints', 'sub1_3', onOptionSelected),
      _buildMenuButton('5. Return to Main Menu', '5', onOptionSelected),
    ];
  }

  static List<Widget> getSafetyInfoButtons(Function(String) onOptionSelected) {
    return [
      _buildMenuButton('1. Marine Weather Safety', 'sub3_1', onOptionSelected),
      _buildMenuButton('2. Navigation Guidelines', 'sub3_2', onOptionSelected),
      _buildMenuButton('3. Emergency Procedures', 'sub3_3', onOptionSelected),
      _buildMenuButton('5. Return to Main Menu', '5', onOptionSelected),
    ];
  }

  static Widget _buildMenuButton(
      String text, String option, Function(String) onOptionSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOptionSelected(option),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF48A7FF).withOpacity(0.9),
                  const Color(0xFF48A7FF).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF48A7FF).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildAdminContactButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        color: Color(0xFF48A7FF),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Coming Soon!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This feature is currently under development.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF48A7FF).withOpacity(0.9),
                  const Color(0xFF48A7FF).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF48A7FF).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Feature Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
