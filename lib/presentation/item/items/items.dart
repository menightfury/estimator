import 'package:estimator/common_libs.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/presentation/item/edit_item/edit_item.dart';

import 'cubit/items_cubit.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ItemsView();
  }
}

class _ItemsView extends StatelessWidget {
  const _ItemsView();

  Future<void> _openItem(BuildContext context, [EstimatorItem? item]) async {
    await context.push<Object>(EditItemPage(initialItem: item));
    // if (context.mounted) {
    //   await context.read<ItemsCubit>().loadItems();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: BlocBuilder<ItemsCubit, ItemsState>(
        builder: (context, state) {
          return switch (state) {
            ItemsInitialState() || ItemsLoadingState() => const Center(child: CircularProgressIndicator()),
            ItemsErrorState() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load items. Please try again.'),
                  const Gap(12),
                  // OutlinedButton(onPressed: () => context.read<ItemsCubit>().loadItems(), child: const Text('Retry')),
                ],
              ),
            ),
            ItemsLoadedState(:final items) when items.isEmpty => const Center(child: Text('No items found.')),
            ItemsLoadedState(:final items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final subtitleParts = [
                  if (item.description.isNotEmpty) item.description,
                  item.unit,
                  if (item.type != null) item.type!.title,
                ];

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(subtitleParts.join(' · ')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openItem(context, item),
                );
              },
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openItem(context),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
