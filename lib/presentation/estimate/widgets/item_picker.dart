part of '../create_estimate_page.dart';

class _ItemPicker extends StatefulWidget {
  const _ItemPicker({super.key});

  @override
  State<_ItemPicker> createState() => _ItemPickerState();
}

class _ItemPickerState extends State<_ItemPicker> {
  @override
  Widget build(BuildContext context) {
    final searchNotifier = ItemSearchNotifier();

    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Type to search',
            contentPadding: iFormFieldContentPadding.copyWith(top: 16.0, bottom: 16.0),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: Icon(Icons.search_rounded),
            ),
            // suffix: IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
          ),
          // onChanged: (value) => searchNotifier.search(value),
        ),

        const EstimatorDivider(),

        // ~ Results
        Expanded(
          child: _ItemView(results: []),
          // child: ListenableBuilder(
          //   listenable: searchNotifier,
          //   builder: (context, _) {
          //     $logger.d(searchNotifier);
          //     if (searchNotifier.status == ItemSearchStateStatus.error) {
          //       return Center(child: Text('Some error occurred! Try again later.', textAlign: TextAlign.center));
          //     }

          //     if (searchNotifier.status == ItemSearchStateStatus.initial ||
          //         searchNotifier.status == ItemSearchStateStatus.empty) {
          //       return Center(child: Text('Type to search items'));
          //     }

          //     if (searchNotifier.status == ItemSearchStateStatus.success) {
          //       if (searchNotifier.results.isEmpty) {
          //         return Center(child: Text('No matching items'));
          //       }

          //       final results = searchNotifier.results;
          //       return _ItemView(results: results);
          //     }

          //     return const Center(child: CircularProgressIndicator());
          //   },
          // ),
        ),
      ],
    );
  }
}

class _ItemView extends StatefulWidget {
  const new({super.key, required this.results});

  final List<ItemInDb> results;

  @override
  State<_ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<_ItemView> {
  static const int _pageSize = 4;

  late final List<ItemInDb> _options;
  late final ValueNotifier<int> _highlightedOptionIndex;

  @override
  void initState() {
    super.initState();
    _options = widget.results;
    _highlightedOptionIndex = ValueNotifier<int>(0);
  }

  void _updateHighlight(int nextIndex) {
    _highlightedOptionIndex.value = _options.isEmpty ? 0 : nextIndex.clamp(0, _options.length - 1);
  }

  void _highlightPreviousOption() {
    _highlightOption(_highlightedOptionIndex.value - 1);
  }

  void _highlightNextOption() {
    _highlightOption(_highlightedOptionIndex.value + 1);
  }

  void _highlightFirstOption() {
    _highlightOption(0);
  }

  void _highlightLastOption() {
    _highlightOption(_options.length - 1);
  }

  void _highlightNextPageOption() {
    _highlightOption(_highlightedOptionIndex.value + _pageSize);
  }

  void _highlightPreviousPageOption() {
    _highlightOption(_highlightedOptionIndex.value - _pageSize);
  }

  void _highlightOption(int index) {
    // assert(_canShowOptionsView);
    // _updateOptionsViewVisibility();
    // assert(_optionsViewController.isShowing);
    _updateHighlight(index);
  }

  @override
  Widget build(BuildContext context) {
    final int highlightedIndex = AutocompleteHighlightedOption.of(context);

    return Material(
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(LogicalKeyboardKey.arrowUp): _highlightPreviousOption,
          SingleActivator(LogicalKeyboardKey.arrowDown): _highlightNextOption,
          SingleActivator(LogicalKeyboardKey.pageUp): _highlightPreviousPageOption,
          SingleActivator(LogicalKeyboardKey.pageDown): _highlightNextPageOption,
          SingleActivator(LogicalKeyboardKey.arrowUp, control: true): _highlightFirstOption,
          SingleActivator(LogicalKeyboardKey.arrowDown, control: true): _highlightLastOption,
        },
        child: AutocompleteHighlightedOption(
          highlightIndexNotifier: _highlightedOptionIndex,
          // Exclude the options overlay from the ambient focus
          // traversal tree. Autocomplete options are navigated by
          // arrow keys (via the widget's own shortcuts) and selected
          // via Enter or tap, so they don't participate in TAB
          // traversal. Without this, TAB from the field would
          // detour into focusable items in the options overlay
          // instead of advancing to the next form field.
          child: ExcludeFocus(
            child: ListView.builder(
              itemBuilder: ((context, index) {
                // final item = results[index];
                final highlight = highlightedIndex == index;
                return ListTile(
                  // title: Text(item.name),
                  title: Text('This is the title text'),
                  subtitle: Text(
                    // item.description,
                    'Subtitle goes here. Subtitle is very long text by clipped to only two lines. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus feugiat egestas nulla. Aenean pretium volutpat lacus vitae fringilla. Sed dictum at nunc accumsan mollis. Aenean mollis tristique leo non suscipit. Aenean efficitur urna a luctus gravida. Pellentesque porta at est sit amet luctus. Aenean malesuada metus eu erat mollis, luctus consectetur dolor rhoncus. Nulla vel ullamcorper nibh. Aliquam ut ipsum libero. Mauris sapien enim, consequat sed purus at, tempor dignissim sapien.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                  onTap: () {},
                  selected: highlight,
                  hoverColor: Colors.amber,
                  focusColor: Colors.red,
                );
              }),
              // separatorBuilder: (_, _) => const SizedBox(height: 8.0),
              // itemCount: results.length,
              itemCount: 13,
            ),
          ),
        ),
      ),
    );
  }
}

enum ItemSearchStateStatus { initial, empty, loading, success, error }

class ItemSearchNotifier extends ChangeNotifier {
  ItemSearchNotifier()
    : _amcCache = {},
      _debouncer = Debouncer(2.seconds),
      _status = ItemSearchStateStatus.initial,
      _results = const [];

  final Map<String, List<ItemInDb>> _amcCache;
  final Debouncer _debouncer;

  ItemSearchStateStatus _status;
  ItemSearchStateStatus get status => _status;

  List<ItemInDb> _results;
  List<ItemInDb> get results => _results;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      _status = ItemSearchStateStatus.empty;
      _results = const [];
      notifyListeners();
      return;
    }

    final key = q.toLowerCase();
    final cachedResult = _amcCache[key];
    if (cachedResult != null) {
      _status = ItemSearchStateStatus.success;
      _results = cachedResult;
      notifyListeners();
      return;
    }

    _status = ItemSearchStateStatus.loading;
    _results = const [];
    notifyListeners();

    try {
      await _debouncer.wait();
      final results = await EstimatorRepository.instance.searchItems(query);
      $logger.d(results);
      _status = ItemSearchStateStatus.success;
      _results = results;
      _amcCache[key] = results;
    } on Exception catch (_) {
      _status = ItemSearchStateStatus.error;
      _results = const [];
    }
    notifyListeners();
  }

  @override
  String toString() => 'status: $_status, results: $_results';
}
