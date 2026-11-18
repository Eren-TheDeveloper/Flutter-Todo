import 'package:flutter/material.dart';

class ToDoList extends StatelessWidget {
  const ToDoList({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });
  final String taskName;
  final bool taskCompleted;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              semanticLabel:
                  '$taskName: ${taskCompleted ? 'tamamlandı' : 'bekliyor'}',
            ),
            Expanded(
              child: Text(
                taskName,
                style: TextStyle(
                  fontSize: 16,
                  color: taskCompleted
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                  decoration: taskCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            PopupMenuButton<String>(
              enabled: onEdit != null && onDelete != null,
              tooltip: 'Görev seçenekleri',
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else {
                  onDelete?.call();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                PopupMenuItem(value: 'delete', child: Text('Sil')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
