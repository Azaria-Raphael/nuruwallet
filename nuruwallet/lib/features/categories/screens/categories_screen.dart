import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/category_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';
import '../widgets/add_edit_category_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          // Separate top-level (parentCategoryId == null) from sub-categories
          final topLevel = categories
              .where((c) => c.parentCategoryId == null)
              .toList();
          final subCats = categories
              .where((c) => c.parentCategoryId != null)
              .toList();

          final expense = topLevel
              .where((c) =>
                  c.categoryType == 'expense' || c.categoryType == 'both')
              .toList();
          final income = topLevel
              .where((c) => c.categoryType == 'income')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (expense.isNotEmpty) ...[
                _SectionHeader('Expense (${expense.length})'),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ReorderableListView(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIdx, newIdx) =>
                        _reorder(oldIdx, newIdx, expense, ref),
                    children: [
                      for (int i = 0; i < expense.length; i++)
                        _ReorderableTileWrapper(
                          key: ValueKey(expense[i].id),
                          index: i,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CategoryTile(
                                category: expense[i],
                                onTap: () => showAddEditCategorySheet(
                                  context,
                                  category: expense[i],
                                ),
                              ),
                              ...subCats
                                  .where((s) =>
                                      s.parentCategoryId == expense[i].id)
                                  .map((child) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Divider(
                                              height: 1, indent: 56),
                                          _SubCategoryTile(
                                            category: child,
                                            onTap: () =>
                                                showAddEditCategorySheet(
                                              context,
                                              category: child,
                                            ),
                                          ),
                                        ],
                                      )),
                              if (i < expense.length - 1)
                                const Divider(height: 1, indent: 56),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (income.isNotEmpty) ...[
                _SectionHeader('Income (${income.length})'),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ReorderableListView(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIdx, newIdx) =>
                        _reorder(oldIdx, newIdx, income, ref),
                    children: [
                      for (int i = 0; i < income.length; i++)
                        _ReorderableTileWrapper(
                          key: ValueKey(income[i].id),
                          index: i,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CategoryTile(
                                category: income[i],
                                onTap: () => showAddEditCategorySheet(
                                  context,
                                  category: income[i],
                                ),
                              ),
                              ...subCats
                                  .where((s) =>
                                      s.parentCategoryId == income[i].id)
                                  .map((child) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Divider(
                                              height: 1, indent: 56),
                                          _SubCategoryTile(
                                            category: child,
                                            onTap: () =>
                                                showAddEditCategorySheet(
                                              context,
                                              category: child,
                                            ),
                                          ),
                                        ],
                                      )),
                              if (i < income.length - 1)
                                const Divider(height: 1, indent: 56),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditCategorySheet(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _reorder(
    int oldIndex,
    int newIndex,
    List<CategoryEntry> section,
    WidgetRef ref,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final updated = List<CategoryEntry>.from(section);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    await ref.read(categoryRepositoryProvider).reorderCategories(updated);
  }
}

class _ReorderableTileWrapper extends StatelessWidget {
  const _ReorderableTileWrapper({
    required super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: child,
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryEntry category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          CategoryIcon.get(category.iconName),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: category.monthlyLimit > 0
          ? Text(
              'Budget: ${CurrencyFormatter.format(category.monthlyLimit)}'
              '${category.rolloverEnabled ? " · rollover on" : ""}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.isDefault)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Default',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.drag_handle,
            size: 18,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({required this.category, required this.onTap});

  final CategoryEntry category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              CategoryIcon.get(category.iconName),
              color: color,
              size: 16,
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          ),
          subtitle: category.monthlyLimit > 0
              ? Text(
                  'Budget: ${CurrencyFormatter.format(category.monthlyLimit)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : null,
          trailing: Icon(
            Icons.subdirectory_arrow_right,
            size: 14,
            color: scheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
