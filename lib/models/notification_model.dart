class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String time;
  final List<ActionButton> actions;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.time,
    required this.actions,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      time: json['time'],
      actions: (json['actions'] as List)
          .map((action) => ActionButton.fromJson(action))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
 
class ActionButton {
  final String label;
  final String action;

  ActionButton({
    required this.label,
    required this.action,
  });

  factory ActionButton.fromJson(Map<String, dynamic> json) {
    return ActionButton(
      label: json['label'],
      action: json['action'],
    );
  }
}

