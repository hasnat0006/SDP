import 'package:flutter/material.dart';
import '../models/task_model.dart';

class ImprovedTaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ImprovedTaskTile({
    Key? key,
    required this.task,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: task.isOverdue && !task.isCompleted
            ? Border.all(color: Colors.red[300]!, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: onChanged,
                activeColor: Colors.grey,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: _getTextColor(),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          style: TextStyle(
                            color: _getTextColor().withOpacity(0.7),
                            fontSize: 12,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Priority indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: task.priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priorityText,
                            style: TextStyle(
                              fontSize: 10,
                              color: task.priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Due date indicator
                        if (task.dueDate != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDueDateColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 10,
                                  color: _getDueDateColor(),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  _formatDueDate(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getDueDateColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Overdue indicator
                        if (task.isOverdue && !task.isCompleted)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning,
                                  size: 10,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'OVERDUE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: 1.5708, // 90 degrees in radians
                child: _buildPopupMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (task.isCompleted) {
      return Colors.grey[100]!;
    }
    if (task.isOverdue) {
      return Colors.red[50]!;
    }
    return Colors.grey[200]!;
  }

  Color _getTextColor() {
    if (task.isCompleted) {
      return Colors.grey;
    }
    if (task.isOverdue) {
      return Colors.red[800]!;
    }
    return Colors.black;
  }

  Color _getDueDateColor() {
    if (task.isOverdue && !task.isCompleted) {
      return Colors.red;
    }
    if (task.dueDate != null) {
      final now = DateTime.now();
      final timeDiff = task.dueDate!.difference(now).inHours;
      if (timeDiff <= 24) {
        return Colors.orange;
      }
    }
    return Colors.blue;
  }

  String _formatDueDate() {
    if (task.dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final taskDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${task.dueDate!.day}/${task.dueDate!.month}';
    }

    return '$dateStr ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPopupMenu(BuildContext context) {
    List<PopupMenuEntry<String>> menuItems = [];

    // Only show edit button for incomplete tasks
    if (!task.isCompleted && onEdit != null) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.grey[600], size: 20),
              SizedBox(width: 8),
              Text('Edit Task'),
            ],
          ),
        ),
      );
    }

    // Always show delete button if onDelete is provided
    if (onDelete != null) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red[400], size: 20),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red[400])),
            ],
          ),
        ),
      );
    }

    // If no menu items, don't show the menu
    if (menuItems.isEmpty) {
      return SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey),
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            if (onEdit != null) onEdit!();
            break;
          case 'delete':
            if (onDelete != null) onDelete!();
            break;
        }
      },
      itemBuilder: (BuildContext context) => menuItems,
    );
  }
}
