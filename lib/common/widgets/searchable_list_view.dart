import 'dart:async';

import 'package:estimator/common_libs.dart';

import 'divider.dart';

typedef AutocompleteOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(
  TextEditingValue textEditingValue,
);

typedef AutocompleteOnSelected<T extends Object> = void Function(T option);

typedef AutocompleteOptionViewBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T option,
  bool isHighlighted,
  AutocompleteOnSelected<T> onSelected,
);

class SearchableListView<T extends Object> extends StatefulWidget {
  const SearchableListView({
    super.key,
    required this.optionViewBuilder,
    required this.optionsBuilder,
    this.focusNode,
    this.onSelected,
    this.textEditingController,
    this.initialValue,
  }) : assert((focusNode == null) == (textEditingController == null)),
       assert(
         !(textEditingController != null && initialValue != null),
         'textEditingController and initialValue cannot be simultaneously defined.',
       );

  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final TextEditingValue? initialValue;
  final AutocompleteOptionViewBuilder<T> optionViewBuilder;
  final AutocompleteOnSelected<T>? onSelected;
  final AutocompleteOptionsBuilder<T> optionsBuilder;

  @override
  State<SearchableListView<T>> createState() => _SearchableListViewState<T>();
}

class _SearchableListViewState<T extends Object> extends State<SearchableListView<T>> {
  static const int _pageSize = 4;
  late bool _hasFocus;
  bool _selecting = false;

  TextEditingController? _internalTextEditingController;
  TextEditingController get _textEditingController {
    return widget.textEditingController ??
        (_internalTextEditingController ??= TextEditingController()..addListener(_onChangedField));
  }

  FocusNode? _internalFocusNode;
  FocusNode get _focusNode {
    // return widget.focusNode ?? (_internalFocusNode ??= FocusNode()..addListener(_onFocusChange));
    return widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  Iterable<T> _options = Iterable<T>.empty();
  T? _selection;
  // Set the initial value to null so when this widget gets focused for the first
  // time it will try to run the options view builder.
  String? _lastFieldText;
  final ValueNotifier<int> _highlightedOptionIndexNotifier = ValueNotifier<int>(0);

  // void _onFocusChange() {
  //   if (_focusNode.hasFocus != _hasFocus) {
  //     _hasFocus = _focusNode.hasFocus;
  //   }
  // }

  // Assigning an ID to every call of _onChangedField is necessary to avoid a
  // situation where _options is updated by an older call when multiple
  // _onChangedField calls are running simultaneously.
  int _onChangedCallId = 0;
  // Called when _textEditingController changes.
  Future<void> _onChangedField() async {
    // During a selection, changes to the field text should not trigger options update.
    if (_selecting) {
      return;
    }
    final TextEditingValue value = _textEditingController.value;

    // Makes sure that options change only when content of the field changes.
    var shouldUpdateOptions = false;
    if (value.text != _lastFieldText) {
      shouldUpdateOptions = true;
      _onChangedCallId += 1;
    }
    _lastFieldText = value.text;

    final int callId = _onChangedCallId;
    final Iterable<T> options = await widget.optionsBuilder(value);
    if (!mounted) {
      return;
    }

    // Makes sure that previous call results do not replace new ones.
    if (callId != _onChangedCallId || !shouldUpdateOptions) {
      return;
    }
    $logger.i(options);
    setState(() {
      _options = options;
      _updateHighlight(0);
      _selection = null;
    });
  }

  // Called from fieldViewBuilder when the user submits the field.
  void _onFieldSubmitted() {
    _select(_options.elementAt(_highlightedOptionIndexNotifier.value));
  }

  // Select the given option and update the widget.
  void _select(T nextSelection) {
    if (nextSelection == _selection) {
      return;
    }
    _selecting = true;
    _selection = nextSelection;
    widget.onSelected?.call(nextSelection);
    _selecting = false;
  }

  void _updateHighlight(int nextIndex) {
    _highlightedOptionIndexNotifier.value = _options.isEmpty ? 0 : nextIndex.clamp(0, _options.length - 1);
  }

  void _highlightPreviousOption() {
    _highlightOption(_highlightedOptionIndexNotifier.value - 1);
  }

  void _highlightNextOption() {
    _highlightOption(_highlightedOptionIndexNotifier.value + 1);
  }

  void _highlightFirstOption() {
    _highlightOption(0);
  }

  void _highlightLastOption() {
    _highlightOption(_options.length - 1);
  }

  void _highlightNextPageOption() {
    _highlightOption(_highlightedOptionIndexNotifier.value + _pageSize);
  }

  void _highlightPreviousPageOption() {
    _highlightOption(_highlightedOptionIndexNotifier.value - _pageSize);
  }

  void _highlightOption(int index) {
    _updateHighlight(index);
  }

  @override
  void initState() {
    super.initState();
    final TextEditingController initialController =
        widget.textEditingController ??
        (_internalTextEditingController = TextEditingController.fromValue(widget.initialValue));
    initialController.addListener(_onChangedField);
    _hasFocus = _focusNode.hasFocus;
    // widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SearchableListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.textEditingController, widget.textEditingController)) {
      oldWidget.textEditingController?.removeListener(_onChangedField);
      if (oldWidget.textEditingController == null) {
        _internalTextEditingController?.dispose();
        _internalTextEditingController = null;
      }
      widget.textEditingController?.addListener(_onChangedField);
    }
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
    }
  }

  @override
  void dispose() {
    widget.textEditingController?.removeListener(_onChangedField);
    _internalTextEditingController?.dispose();
    _internalFocusNode?.dispose();
    _highlightedOptionIndexNotifier.dispose();
    super.dispose();
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _textEditingController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Type to search',
              contentPadding: iFormFieldContentPadding.copyWith(top: 16.0, bottom: 16.0),
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Icon(Icons.search_rounded),
              ),
            ),
          ),

          const EstimatorDivider(),

          // ~ Results
          Expanded(
            child: TextFieldTapRegion(
              // Exclude the options overlay from the ambient focus
              // traversal tree. Autocomplete options are navigated by
              // arrow keys (via the widget's own shortcuts) and selected
              // via Enter or tap, so they don't participate in TAB
              // traversal. Without this, TAB from the field would
              // detour into focusable items in the options overlay
              // instead of advancing to the next form field.
              child: ExcludeFocus(
                child: Material(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _highlightedOptionIndexNotifier,
                    builder: (context, highlightedIndex, _) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          final option = _options.elementAt(index);
                          final isHighlighted = highlightedIndex == index;
                          return widget.optionViewBuilder(context, option, isHighlighted, _select);
                        },
                        itemCount: _options.length,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
