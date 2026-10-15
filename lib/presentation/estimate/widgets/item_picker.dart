part of '../create_estimate_page.dart';

class _ItemPicker extends StatelessWidget {
  const _ItemPicker({super.key, this.onItemSelected});

  final ValueChanged<EstimatorItem>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final itemsState = context.read<ItemsCubit>().state;

    if (itemsState is ItemsErrorState) {
      return Center(
        child: Text(itemsState.msg, style: TextStyle(color: context.colors.error)),
      );
    }

    if (itemsState is ItemsLoadedState) {
      return _ItemSearch(items: itemsState.items, onItemSelected: onItemSelected);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _ItemSearch extends StatefulWidget {
  const _ItemSearch({super.key, this.items = const [], this.onItemSelected});

  final ValueChanged<EstimatorItem>? onItemSelected;
  final List<EstimatorItem> items;

  @override
  State<_ItemSearch> createState() => _ItemSearchState();
}

class _ItemSearchState extends State<_ItemSearch> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Request focus after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () => widget.onItemSelected?.call(option),
          selected: isHighlighted,
          hoverColor: Colors.amber,
        );
      },
      optionsBuilder: (text) {
        final items = widget.items;
        final searchText = text.trim();
        if (searchText.isEmpty) {
          return items;
        }
        return items.where((item) => item.name.contains(searchText));
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
