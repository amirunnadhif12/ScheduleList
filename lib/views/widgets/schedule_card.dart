import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getColorFromName(String? colorInput) {
    if (colorInput == null || colorInput.isEmpty) {
      return Colors.grey[50]!;
    }

    // If it's a hex color, parse it
    if (colorInput.startsWith('#')) {
      try {
        final hexColor = colorInput.replaceFirst('#', '0xFF');
        final color = Color(int.parse(hexColor));
        // Return a lighter version for the background
        return color.withOpacity(0.15);
      } catch (e) {
        return Colors.grey[50]!;
      }
    }

    // Otherwise, use color name matching
    switch (colorInput.toLowerCase()) {
      case 'blue':
        return Colors.blue[50]!;
      case 'green':
        return Colors.green[50]!;
      case 'purple':
        return Colors.purple[50]!;
      case 'orange':
        return Colors.orange[50]!;
      case 'red':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getBorderColorFromName(String? colorInput) {
    if (colorInput == null || colorInput.isEmpty) {
      return Colors.grey[300]!;
    }

    // If it's a hex color, parse it
    if (colorInput.startsWith('#')) {
      try {
        final hexColor = colorInput.replaceFirst('#', '0xFF');
        return Color(int.parse(hexColor));
      } catch (e) {
        return Colors.grey[300]!;
      }
    }

    // Otherwise, use color name matching
    switch (colorInput.toLowerCase()) {
      case 'blue':
        return Colors.blue[300]!;
      case 'green':
        return Colors.green[300]!;
      case 'purple':
        return Colors.purple[300]!;
      case 'orange':
        return Colors.orange[300]!;
      case 'red':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getColorFromName(schedule.color),
        border: Border(
          left: BorderSide(
            color: _getBorderColorFromName(schedule.color),
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  schedule.activity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                '${schedule.startTime} - ${schedule.endTime}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  schedule.location,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            schedule.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
