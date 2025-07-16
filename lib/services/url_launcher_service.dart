import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<void> openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $urlString');
    }
  }
}
