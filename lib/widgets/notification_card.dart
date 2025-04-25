import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final Function(String, String) onActionPressed;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...notification.actions.map((action) => _buildActionButton(action)),
                      const Spacer(),
                      Text(
                        notification.time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (notification.icon) {
      case 'donation':
        iconData = Icons.water_drop;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.red;
        break;
      case 'message':
        iconData = Icons.message;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.red[800]!;
        break;
      case 'fundraiser':
        iconData = Icons.campaign;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.orange;
        break;
      case 'volunteer':
        iconData = Icons.sync_alt;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.red[800]!;
        break;
      default:
        iconData = Icons.notifications;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.red;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildActionButton(ActionButton action) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => onActionPressed(action.action, notification.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.indigo,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(action.label),
      ),
    );
  }
}

