import 'package:flutter/material.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/userdashboard/banperiodcalender_page.dart';
import 'package:mobileapplication/userdashboard/ocean_education.dart';

class UserDashboardWidgets {
  static Widget buildCompactMarineCondition(IconData icon, String value,
      String label, bool isWhite, Color deepBlue, Color whiteWater) {
    Color textColor = isWhite ? whiteWater : Colors.black87;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget buildDateInfo(
      String label, String date, Color color, bool isWhite, Color whiteWater) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWhite ? whiteWater.withOpacity(0.1) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: whiteWater,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEducationCard(
      String title,
      IconData icon,
      String description,
      Color surfaceBlue,
      Color accentBlue,
      Color deepBlue,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarineEducationPage(
              isAdmin: false,
              category: title,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [surfaceBlue.withOpacity(0.2), accentBlue.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentBlue, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: deepBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                color: deepBlue.withOpacity(0.6),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
    List<Animation<double>> animations,
    Function(int) onTap,
    Color surfaceBlue,
    Color deepBlue,
  ) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 15,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? surfaceBlue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, isSelected ? -4 * animations[index].value : 0),
                  child: Icon(
                    icon,
                    color: isSelected ? surfaceBlue : deepBlue.withOpacity(0.5),
                    size: isSelected ? 28 : 24,
                  ),
                );
              },
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? surfaceBlue : deepBlue.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget navbarHeader(
    String userName,
    bool isLoading,
    Color deepBlue,
    Color surfaceBlue,
    Color whiteWater,
    VoidCallback onNotificationPressed,
  ) {
    // Function to truncate username if it's too long
    String formatUsername(String name) {
      if (name.length > 30) {  // Adjust this number as needed
        return '${name.substring(0, 8)}...';  // Show first 12 chars + ellipsis
      }
      return name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: whiteWater,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: deepBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: logoWidget(
                    'assets/MarineGuard-Logo-preview.png',
                    80,
                    80,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,  // Give more space to the text section
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      myText(
                        'Welcome back,',
                        labelstyle: const TextStyle(
                          color: Color.fromARGB(255, 78, 133, 228),
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        isLoading ? "Loading..." : formatUsername(userName),  // Use the format function
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 133, 228),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontFamily: "Poppins",
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'It takes courage to grow up and become who you really are.',
                        style: TextStyle(
                          color: deepBlue.withOpacity(0.9),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notification button in a separate container
          Container(
            margin: const EdgeInsets.only(right: 5),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: deepBlue.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              icon: Icon(
                Icons.notifications_rounded,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: onNotificationPressed,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildBanPeriodCard(
      String startDate,
      String endDate,
      Color surfaceBlue,
      Color accentBlue,
      Color whiteWater,
      BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deepBlue = isDark ? Colors.white : const Color(0xFF1A237E);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E), // Much darker blue
            const Color(0xFF1565C0), // Dark blue
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: surfaceBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_none,
                      color: isDark ? Colors.white : whiteWater, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Ban Period Schedule',
                    style: TextStyle(
                      color: isDark ? Colors.white : whiteWater,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.arrow_forward_ios,
                    color: isDark ? Colors.white : whiteWater, size: 18),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BanPeriodCalendar()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: buildDateInfo(
                  'Start Date',
                  startDate,
                  isDark ? deepBlue : Colors.green,  // Green for start date
                  true,
                  isDark ? deepBlue : whiteWater,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildDateInfo(
                  'End Date',
                  endDate,
                  isDark ? deepBlue : const Color.fromARGB(255, 255, 115, 0),  // Orange for end date
                  true,
                  isDark ? deepBlue : whiteWater,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //function for changing color of icons based on the dark/light mode color
  static Color _getMetricColor(
      String metricType, bool isDarkMode, Color deepBlue) {
    if (isDarkMode) return deepBlue;

    switch (metricType) {
      case 'Waves':
        return const Color(0xFF1976D2);
      case 'Wind':
        return const Color(0xFF00BCD4);
      case 'Visibility':
        return const Color(0xFF009688);
      case 'Temp':
        return const Color(0xFFFF7043);
      default:
        return deepBlue;
    }
  }

  static Widget buildMarineConditionsCard(
    Map<String, dynamic> marineData,
    Color whiteWater,
    Color deepBlue,
    Color accentBlue,
    Color surfaceBlue,
    VoidCallback onRefresh,
  ) {
    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteWater,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: deepBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.sunny, color: deepBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    myText(
                      'Marine Conditions',
                      labelstyle: TextStyle(
                        color: deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: deepBlue),
                  onPressed: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: whiteWater.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMarineMetric(
                    Icons.waves,
                    '${marineData['waveHeight']}m',
                    'Waves',
                    _getMetricColor('Waves', isDarkMode, deepBlue),
                  ),
                  _buildVerticalDivider(),
                  _buildMarineMetric(
                    Icons.air,
                    '${marineData['windSpeed']}km/h',
                    'Wind',
                    _getMetricColor('Wind', isDarkMode, deepBlue),
                  ),
                  _buildVerticalDivider(),
                  _buildMarineMetric(
                    Icons.visibility,
                    '${marineData['visibility']}km',
                    'Visibility',
                    _getMetricColor('Visibility', isDarkMode, deepBlue),
                  ),
                  _buildVerticalDivider(),
                  _buildMarineMetric(
                    Icons.thermostat,
                    '${marineData['temperature']}°C',
                    'Temp',
                    _getMetricColor('Temp', isDarkMode, deepBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  static Widget _buildMarineMetric(
      IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.teal.withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}
