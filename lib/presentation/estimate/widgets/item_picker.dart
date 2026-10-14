part of '../create_estimate_page.dart';

class _ItemPicker extends StatelessWidget {
  const _ItemPicker({super.key, this.onItemSelected});

  final ValueChanged<EstimatorItem>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final itemsState = context.read<ItemsCubit>().state;

    if (itemsState is ItemsLoaded) {
      return SearchableListView<EstimatorItem>(
        optionViewBuilder: (context, option, isHighlighted, onSelected) {
          return ListTile(
            title: Text(option.name),
            subtitle: Text(
              option.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall,
            ),
            trailing: _TypeBadge(type: option.type ?? EstimatorItemType.both),
            onTap: () => onItemSelected?.call(option),
            selected: isHighlighted,
            hoverColor: Colors.amber,
          );
        },
        optionsBuilder: (value) {
          return itemsState.items;
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final EstimatorItemType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: type.color(context).withAlpha(30),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        type.title,
        style: context.textTheme.bodySmall?.copyWith(color: type.color(context), fontWeight: FontWeight.w600),
      ),
    );
  }
}

// enum ItemSearchStateStatus { initial, empty, loading, success, error }

// class ItemSearchNotifier extends ChangeNotifier {
//   ItemSearchNotifier()
//     : _itemCache = {},
//       _debouncer = Debouncer(2.seconds),
//       _status = ItemSearchStateStatus.initial,
//       _results = const [];

//   final Map<String, List<EstimatorItem>> _itemCache;
//   final Debouncer _debouncer;

//   ItemSearchStateStatus _status;
//   ItemSearchStateStatus get status => _status;

//   List<EstimatorItem> _results;
//   List<EstimatorItem> get results => _results;

//   Future<void> search(String query) async {
//     final q = query.trim();
//     if (q.isEmpty) {
//       _status = ItemSearchStateStatus.empty;
//       _results = const [];
//       notifyListeners();
//       return;
//     }

//     final key = q.toLowerCase();
//     final cachedResult = _itemCache[key];
//     if (cachedResult != null) {
//       _status = ItemSearchStateStatus.success;
//       _results = cachedResult;
//       notifyListeners();
//       return;
//     }

//     _status = ItemSearchStateStatus.loading;
//     _results = const [];
//     notifyListeners();

//     try {
//       await _debouncer.wait();
//       final results = await EstimatorRepository.instance.searchItems(query);
//       $logger.d(results);
//       _status = ItemSearchStateStatus.success;
//       _results = results;
//       _itemCache[key] = results;
//     } on Exception catch (_) {
//       _status = ItemSearchStateStatus.error;
//       _results = const [];
//     }
//     notifyListeners();
//   }

//   @override
//   String toString() => 'status: $_status, results: $_results';
// }
