import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../models/url_entry.dart';
import '../services/url_file_service.dart';
import '../services/intent_handler.dart';
import '../widgets/url_card.dart';
import '../widgets/create_url_sheet.dart';
import '../widgets/url_open_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UrlEntry> _entries = [];
  bool _loading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _handleIncomingIntent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await UrlFileService.loadEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _handleIncomingIntent() async {
    final path = await IntentHandler.getSharedFilePath();
    if (path != null && mounted) {
      await _handleUrlFile(path);
    }
  }

  Future<void> _handleUrlFile(String filePath) async {
    final url = await UrlFileService.parseUrlFile(filePath);
    if (url == null || !mounted) return;

    final fileName = filePath.split('/').last;
    final name = fileName.endsWith('.url')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;

    showDialog(
      context: context,
      builder: (_) => UrlOpenDialog(
        fileName: name,
        url: url,
        filePath: filePath,
        onOpen: () async {
          Navigator.pop(context);
          await UrlFileService.openUrl(url);
        },
        onOpenWith: () async {
          Navigator.pop(context);
          await UrlFileService.openUrlFileWithSystem(filePath);
        },
        onSave: () async {
          Navigator.pop(context);
          await _saveExternalEntry(name, url, filePath);
        },
      ),
    );
  }

  Future<void> _saveExternalEntry(
      String name, String url, String filePath) async {
    final entry = UrlEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
      filePath: filePath,
      createdAt: DateTime.now(),
    );
    setState(() => _entries.insert(0, entry));
    await UrlFileService.saveEntries(_entries);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shortcut "$name" saved'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _openFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['url'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await _handleUrlFile(result.files.single.path!);
    }
  }

  Future<void> _showCreateSheet() async {
    final entry = await showModalBottomSheet<UrlEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateUrlSheet(),
    );

    if (entry != null) {
      setState(() => _entries.insert(0, entry));
      await UrlFileService.saveEntries(_entries);
    }
  }

  Future<void> _deleteEntry(UrlEntry entry) async {
    await UrlFileService.deleteEntry(entry, _entries);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${entry.name}" deleted'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  List<UrlEntry> get _filtered {
    if (_searchQuery.isEmpty) return _entries;
    final q = _searchQuery.toLowerCase();
    return _entries
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.url.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // Large top app bar
          SliverAppBar.large(
            backgroundColor: cs.surface,
            title: Text(
              'CatURL',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _openFilePicker,
                icon: const Icon(Icons.folder_open_rounded),
                tooltip: 'Open .url file',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search shortcuts…',
                leading: const Icon(Icons.search_rounded),
                trailing: _searchQuery.isNotEmpty
                    ? [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      ]
                    : null,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
          ),

          // Content
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                hasSearch: _searchQuery.isNotEmpty,
                onCreate: _showCreateSheet,
                onOpen: _openFilePicker,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList.builder(
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final entry = _filtered[i];
                  return UrlCard(
                    key: ValueKey(entry.id),
                    entry: entry,
                    index: i,
                    onOpen: () => UrlFileService.openUrl(entry.url),
                    onOpenWith: () =>
                        UrlFileService.openUrlFileWithSystem(entry.filePath),
                    onDelete: () => _deleteEntry(entry),
                    onShare: () => _shareEntry(entry),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('New Shortcut'),
      )
          .animate()
          .fadeIn(delay: 400.ms, duration: 300.ms)
          .slideY(begin: 0.3),
    );
  }

  Future<void> _shareEntry(UrlEntry entry) async {
    // share_plus usage
    try {
      final file = File(entry.filePath);
      if (await file.exists()) {
        // XFile for sharing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File: ${entry.filePath}'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {}
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onCreate;
  final VoidCallback onOpen;

  const _EmptyState({
    required this.hasSearch,
    required this.onCreate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.link_off_rounded,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.8, 0.8), duration: 400.ms,
                    curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              hasSearch ? 'No results found' : 'No shortcuts yet',
              style: tt.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'Create a new .url shortcut or\nopen an existing one',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),
            if (!hasSearch) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Open file'),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}
