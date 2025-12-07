import 'package:flutter/material.dart';
import '../models/client_case.dart';

class CaseTimelineWidget extends StatelessWidget {
  final List<CaseMilestone> milestones;

  const CaseTimelineWidget({
    super.key,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No milestones available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              final isLast = index == milestones.length - 1;
              
              return _TimelineItem(
                milestone: milestone,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final CaseMilestone milestone;
  final bool isLast;

  const _TimelineItem({
    required this.milestone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = milestone.isCompleted;
    final isOverdue = !isCompleted && 
        milestone.dueDate != null && 
        milestone.dueDate!.isBefore(DateTime.now());

    Color statusColor;
    IconData statusIcon;
    
    if (isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.radio_button_unchecked;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date information
                if (isCompleted && milestone.completedDate != null)
                  _DateChip(
                    label: 'Completed',
                    date: milestone.completedDate!,
                    color: Colors.green,
                  )
                else if (milestone.dueDate != null)
                  _DateChip(
                    label: isOverdue ? 'Overdue' : 'Due',
                    date: milestone.dueDate!,
                    color: isOverdue ? Colors.red : Colors.orange,
                  ),
                
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;

  const _DateChip({
    required this.label,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: ${_formatDate(date)}',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays == -1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'In ${-difference.inDays} days';
    }
  }
}