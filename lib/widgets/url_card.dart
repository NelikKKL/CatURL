import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/url_entry.dart';

class UrlCard extends StatelessWidget {
  final UrlEntry entry;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onOpenWith;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const UrlCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onOpen,
    required this.onOpenWith,
    required this.onDelete,
    required this.onShare,
  });

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final domain = _getDomain(entry.url);
    final dateStr =
        DateFormat('MMM d, yyyy').format(entry.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: cs.onPrimaryContainer,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        domain,
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<_Action>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _Action.open:
                        onOpen();
                      case _Action.openWith:
                        onOpenWith();
                      case _Action.share:
                        onShare();
                      case _Action.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _Action.open,
                      child: ListTile(
                        leading: const Icon(Icons.open_in_browser_rounded),
                        title: const Text('Open'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: _Action.openWith,
                      child: ListTile(
                        leading: const Icon(Icons.open_in_new_rounded),
                        title: const Text('Open with…'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: _Action.share,
                      child: ListTile(
                        leading: const Icon(Icons.share_rounded),
                        title: const Text('Share'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: _Action.delete,
                      child: ListTile(
                        leading: Icon(Icons.delete_outline_rounded,
                            color: cs.error),
                        title: Text('Delete',
                            style: TextStyle(color: cs.error)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
        .slideX(begin: 0.05);
  }
}

enum _Action { open, openWith, share, delete }
