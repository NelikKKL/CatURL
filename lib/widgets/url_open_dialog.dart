import 'package:flutter/material.dart';

class UrlOpenDialog extends StatelessWidget {
  final String fileName;
  final String url;
  final String filePath;
  final VoidCallback onOpen;
  final VoidCallback onOpenWith;
  final VoidCallback onSave;

  const UrlOpenDialog({
    super.key,
    required this.fileName,
    required this.url,
    required this.filePath,
    required this.onOpen,
    required this.onOpenWith,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.link_rounded, color: cs.onPrimaryContainer, size: 28),
      ),
      title: Text(
        fileName,
        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('URL:', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              url,
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Text('What would you like to do?',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onSave,
          child: const Text('Save to list'),
        ),
        FilledButton.tonal(
          onPressed: onOpenWith,
          child: const Text('Open with…'),
        ),
        FilledButton(
          onPressed: onOpen,
          child: const Text('Open'),
        ),
      ],
    );
  }
}
