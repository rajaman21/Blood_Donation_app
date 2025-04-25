import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService(
    baseUrl: 'https://your-api-endpoint.com/api',
  );
  
  bool _isLoading = false;
  String? _error;
  List<NotificationModel> _notifications = [];
  
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }
  
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleActionPressed(String action, String notificationId) {
    switch (action) {
      case 'view_details':
        print('View details for notification: $notificationId');
        break;
      case 'share':
        print('Share notification: $notificationId');
        break;
      case 'view_message':
        print('View message for notification: $notificationId');
        break;
      case 'reply':
        print('Reply to notification: $notificationId');
        break;
      case 'view_update':
        print('View update for notification: $notificationId');
        break;
      case 'sign_up':
        print('Sign up for notification: $notificationId');
        break;
      default:
        print('Unknown action: $action for notification: $notificationId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color:Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _notifications.isEmpty
                  ? _buildEmptyWidget()
                  : _buildScrollableNotificationList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchNotifications,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No notifications yet'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchNotifications,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableNotificationList() {
    final Map<String, List<NotificationModel>> groupedNotifications = {};

    for (final notification in _notifications) {
      final groupTitle = DateFormatter.getGroupTitle(notification.createdAt);
      if (!groupedNotifications.containsKey(groupTitle)) {
        groupedNotifications[groupTitle] = [];
      }
      groupedNotifications[groupTitle]!.add(notification);
    }

    final sortedKeys = groupedNotifications.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        return a.compareTo(b);
      });

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemCount: sortedKeys.length * 2 - 1, // Headers and lists
              itemBuilder: (context, index) {
                if (index % 2 == 0) {
                  final headerIndex = index ~/ 2;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
                    child: Text(
                      sortedKeys[headerIndex],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  );
                } else {
                  final listIndex = index ~/ 2;
                  final groupKey = sortedKeys[listIndex];
                  final notificationsInGroup = groupedNotifications[groupKey]!;

                  return Column(
                    children: notificationsInGroup.map((notification) {
                      return NotificationCard(
                        notification: notification,
                        onActionPressed: _handleActionPressed,
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
