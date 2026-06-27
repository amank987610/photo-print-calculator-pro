import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../data/models/calculation_record.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/section_card.dart';
import 'edit_calculation_screen.dart';
import 'invoice_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete every saved calculation. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<HistoryProvider>().clearAll();
    }
  }

  Future<void> _confirmDelete(BuildContext context, CalculationRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text(
          '${AppFormatters.decimal2(record.width)} x ${AppFormatters.decimal2(record.height)} '
          '${record.unit.shortLabel} order will be removed permanently.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<HistoryProvider>().deleteRecord(record.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final currency = context.watch<SettingsProvider>().settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear All',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: history.isEmpty ? null : () => _confirmClearAll(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by customer, size or amount...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            context.read<HistoryProvider>().search('');
                          },
                        ),
                ),
                onChanged: (value) => context.read<HistoryProvider>().search(value),
              ),
            ),
            Expanded(
              child: history.loading
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          onRefresh: () => history.load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: history.records.length,
                            itemBuilder: (context, index) {
                              final record = history.records[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HistoryTile(
                                  record: record,
                                  currencySymbol: currency,
                                  onTapView: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InvoicePreviewScreen(record: record),
                                    ),
                                  ),
                                  onTapEdit: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditCalculationScreen(record: record),
                                      ),
                                    );
                                  },
                                  onTapDelete: () => _confirmDelete(context, record),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'No calculations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Saved orders from the Calculator tab will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final CalculationRecord record;
  final String currencySymbol;
  final VoidCallback onTapView;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  const _HistoryTile({
    required this.record,
    required this.currencySymbol,
    required this.onTapView,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTapView,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_outlined, color: AppColors.primaryNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.customerName?.isNotEmpty == true
                        ? record.customerName!
                        : '${AppFormatters.decimal2(record.width)} x ${AppFormatters.decimal2(record.height)} ${record.unit.shortLabel}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${AppFormatters.decimal2(record.width)} x ${AppFormatters.decimal2(record.height)} ${record.unit.shortLabel} • Qty ${AppFormatters.decimal2(record.quantity)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppFormatters.dateTime(record.dateTime),
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(record.grandTotal, currencySymbol),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'edit') onTapEdit();
                    if (value == 'delete') onTapDelete();
                    if (value == 'view') onTapView();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'view', child: Text('View / PDF')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
