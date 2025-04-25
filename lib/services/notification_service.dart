import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  final String baseUrl;

  NotificationService({required this.baseUrl});

  Future<List<NotificationModel>> getNotifications() async {
    // try {
    //   final response = await http.get(Uri.parse('$baseUrl/notifications'));

    //   if (response.statusCode == 200) {
    //     final List<dynamic> data = json.decode(response.body);
    //     return data.map((json) => NotificationModel.fromJson(json)).toList();
    //   } else {
    //     throw Exception('Failed to load notifications: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   throw Exception('Error fetching notifications: $e');
    // }
    final now = DateTime.now();

    return [
      NotificationModel(
        id: '1',
        title: 'Donation Update',
        description: 'Your recent donation has been successfully processed.',
        icon: 'donation',
        time: '23 min',
        actions: [
          ActionButton(label: 'View Details', action: 'view_details'),
          ActionButton(label: 'Share', action: 'share'),
        ],
        createdAt: now.subtract(const Duration(minutes: 23)),
      ),
      NotificationModel(
        id: '2',
        title: 'Message from Recipient',
        description: 'You have received a thank you message from a recipient.',
        icon: 'message',
        time: '31 min',
        actions: [
          ActionButton(label: 'View Message', action: 'view_message'),
          ActionButton(label: 'Reply', action: 'reply'),
        ],
        createdAt: now.subtract(const Duration(minutes: 31)),
      ),
      NotificationModel(
        id: '3',
        title: 'Fundraiser Update',
        description: 'New update on the fundraiser you supported.',
        icon: 'fundraiser',
        time: 'Yesterday',
        actions: [
          ActionButton(label: 'View Update', action: 'view_update'),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        title: 'Volunteer Opportunity',
        description: 'New volunteer opportunity available in your area.',
        icon: 'volunteer',
        time: '2 days ago',
        actions: [
          ActionButton(label: 'View Details', action: 'view_details'),
          ActionButton(label: 'Sign Up', action: 'sign_up'),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
