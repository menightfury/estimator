part of '../create_estimate_page.dart';

class _ItemPicker extends StatefulWidget {
  const _ItemPicker({super.key, this.onItemSelected});

  final ValueChanged<ItemInDb>? onItemSelected;

  @override
  State<_ItemPicker> createState() => _ItemPickerState();
}

class _ItemPickerState extends State<_ItemPicker> {
  static const int _pageSize = 4;

  late final ItemSearchNotifier _searchNotifier;
  late final ValueNotifier<int> _highlightedIndexNotifier;
  String? _lastFieldText;

  Iterable<ItemInDb> _options = Iterable<ItemInDb>.empty();

  @override
  void initState() {
    super.initState();
    _searchNotifier = ItemSearchNotifier();
    _highlightedIndexNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _searchNotifier.dispose();
    _highlightedIndexNotifier.dispose();
    super.dispose();
  }

  void _updateHighlight(int nextIndex) {
    _highlightedIndexNotifier.value = _options.isEmpty ? 0 : nextIndex.clamp(0, _options.length - 1);
  }

  void _highlightPreviousOption() {
    _highlightOption(_highlightedIndexNotifier.value - 1);
  }

  void _highlightNextOption() {
    _highlightOption(_highlightedIndexNotifier.value + 1);
  }

  void _highlightFirstOption() {
    _highlightOption(0);
  }

  void _highlightLastOption() {
    _highlightOption(_options.length - 1);
  }

  void _highlightNextPageOption() {
    _highlightOption(_highlightedIndexNotifier.value + _pageSize);
  }

  void _highlightPreviousPageOption() {
    _highlightOption(_highlightedIndexNotifier.value - _pageSize);
  }

  void _highlightOption(int index) {
    // assert(_canShowOptionsView);
    // _updateOptionsViewVisibility();
    // assert(_optionsViewController.isShowing);
    _updateHighlight(index);
  }

  // Assigning an ID to every call of _onChangedField is necessary to avoid a
  // situation where _options is updated by an older call when multiple
  // _onChangedField calls are running simultaneously.
  int _onChangedCallId = 0;
  // Called when [TextField] value changes.
  Future<void> _onChangedField(String value) async {
    // During a selection, changes to the field text should not trigger
    // options update.
    // if (_selecting) {
    //   return;
    // }
    // final TextEditingValue value = _textEditingController.value;

    // Makes sure that options change only when content of the field changes.
    var shouldUpdateOptions = false;
    if (value != _lastFieldText) {
      shouldUpdateOptions = true;
      _onChangedCallId += 1;
    }
    _lastFieldText = value;
    final int callId = _onChangedCallId;
    await _searchNotifier.search(value);

    if (!mounted) {
      return;
    }

    // Makes sure that previous call results do not replace new ones.
    if (callId != _onChangedCallId || !shouldUpdateOptions) {
      return;
    }

    _updateHighlight(0);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.arrowUp): _highlightPreviousOption,
        SingleActivator(LogicalKeyboardKey.arrowDown): _highlightNextOption,
        SingleActivator(LogicalKeyboardKey.pageUp): _highlightPreviousPageOption,
        SingleActivator(LogicalKeyboardKey.pageDown): _highlightNextPageOption,
        SingleActivator(LogicalKeyboardKey.arrowUp, control: true): _highlightFirstOption,
        SingleActivator(LogicalKeyboardKey.arrowDown, control: true): _highlightLastOption,
      },
      child: Column(
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
            onChanged: _onChangedField,
          ),

          const EstimatorDivider(),

          // ~ Results
          Expanded(
            child: ListenableBuilder(
              listenable: _searchNotifier,
              builder: (context, _) {
                $logger.d(_searchNotifier);
                if (_searchNotifier.status == ItemSearchStateStatus.error) {
                  return Center(child: Text('Some error occurred! Try again later.', textAlign: TextAlign.center));
                }

                if (_searchNotifier.status == ItemSearchStateStatus.initial ||
                    _searchNotifier.status == ItemSearchStateStatus.empty) {
                  return Center(child: Text('Type to search items'));
                }

                if (_searchNotifier.status == ItemSearchStateStatus.success) {
                  if (_searchNotifier.results.isEmpty) {
                    return Center(child: Text('No matching items'));
                  }

                  final results = _searchNotifier.results;
                  _options = _searchNotifier.results;

                  return Material(
                    // Exclude the options overlay from the ambient focus
                    // traversal tree. Autocomplete options are navigated by
                    // arrow keys (via the widget's own shortcuts) and selected
                    // via Enter or tap, so they don't participate in TAB
                    // traversal. Without this, TAB from the field would
                    // detour into focusable items in the options overlay
                    // instead of advancing to the next form field.
                    child: ExcludeFocus(
                      child: ValueListenableBuilder(
                        valueListenable: _highlightedIndexNotifier,
                        builder: (context, highlightedIndex, _) {
                          return ListView.builder(
                            itemBuilder: ((context, index) {
                              final item = results[index];
                              final highlight = highlightedIndex == index;

                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall,
                                ),
                                onTap: () => widget.onItemSelected?.call(item),
                                selected: highlight,
                                hoverColor: Colors.amber,
                              );
                            }),
                            // separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                            itemCount: results.length,
                          );
                        },
                      ),
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
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
