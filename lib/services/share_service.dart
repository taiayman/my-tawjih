// File: lib/services/share_service.dart

import 'package:share_plus/share_plus.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/models/school_model.dart';
import 'package:easy_localization/easy_localization.dart';

class ShareService {
  Future<void> shareAnnouncement(Announcement announcement, School school) async {
    final String shareText = '''
${announcement.title}

${announcement.description}

${'school'.tr()}: ${school.name}
${'category'.tr()}: ${announcement.category}
${'date'.tr()}: ${DateFormat('yyyy-MM-dd').format(announcement.date)}

${'shared_via'.tr()} Taleb Educational Platform
''';

    try {
      await Share.share(shareText, subject: announcement.title);
    } catch (e) {
      print('Error sharing announcement: $e');
      throw Exception('Failed to share announcement: $e');
    }
  }
}