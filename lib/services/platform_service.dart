import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class PlatformService {
  static bool get isWeb => kIsWeb;
  
  static Future<void> redirectToWebAdmin() async {
    if (!kIsWeb) {
      final Uri webUrl = Uri.parse('http://your-web-admin-url.com');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }
}
