import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class IconProperty {
  final IconData? icon;
  final Color? color;
  final double? size;
  IconProperty({this.icon, this.color, this.size});
}

class SearchableDropdown extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    this.controller,
    this.initialValue,
    required this.dropDownList,
    this.padding,
    this.textStyle,
    this.onChanged,
    this.validator,
    this.selectColor = Colors.orange,
    this.isEnabled = true,
    this.enableSearch = false,
    this.readOnly = true,
    this.dropdownContainerDecoration,
    this.textFieldDecoration,
    this.dropDownIconProperty,
    this.dropDownItemCount = 6,
    this.searchTextStyle,
    this.searchFocusNode,
    this.textFieldFocusNode,
    this.searchAutofocus = false,
    this.emptyMessage,
    this.searchDecoration,
    this.searchShowCursor,
    this.searchKeyboardType,
    this.listSpace = 0,
    this.clearOption = true,
    this.clearIconProperty,
    this.suffixIconColor,
    this.suffixIconPadding,
    this.listPadding,
    this.listTextStyle,
    this.selectListTextStyle,
    this.selectBorderRadius,
    this.selectTextColor = Colors.white,
    this.dropdownContainerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    this.keyboardType,
    this.autovalidateMode,
  }) : assert(
         !(initialValue != null && controller != null),
         'you cannot add both initialValue and singleController,\nset initial value using controller \n\tEg: SingleValueDropDownController(data:initial value) ',
       ),
       assert(!(!readOnly && enableSearch), 'readOnly!=true or enableSearch=true both condition does not work'),
       assert(
         controller == null || controller is SingleValueDropDownController,
         'controller must be of type SingleValueDropDownController',
       ),
       isMultiSelection = false,
       singleController = controller,
       displayCompleteItem = false,
       submitButtonColor = null,
       submitButtonText = null,
       submitButtonTextStyle = null;

  /// Single and multi dropdown controller.
  /// Must be [SingleValueDropDownController]
  final dynamic controller;

  /// Single dropdown controller.
  final SingleValueDropDownController? singleController;

  /// Custom decoration for the dropdown list container.
  final BoxDecoration? dropdownContainerDecoration;

  /// Initial value. If null or not in [dropDownList], no value is displayed.
  final dynamic initialValue;

  /// List of dropdown values.
  final List<DropDownValueModel> dropDownList;

  /// Called when a value is selected.
  /// Returns a [DropDownValueModel] for single, or [List<DropDownValueModel>] for multi.
  final ValueSetter? onChanged;

  final bool isMultiSelection;

  final TextStyle? textStyle;

  final String? emptyMessage;

  final EdgeInsets? padding;

  /// Overrides the default text field decoration.
  final InputDecoration? textFieldDecoration;

  /// Customizes the dropdown arrow icon.
  final IconProperty? dropDownIconProperty;

  /// Selection highlight color for single-select.
  final Color selectColor;

  /// Border radius of the selected item highlight. Defaults to [BorderRadius.circular(12)].
  final BorderRadius? selectBorderRadius;

  /// Text color of the selected item. Defaults to [Colors.white].
  final Color selectTextColor;

  /// Padding inside the dropdown container. Defaults to [EdgeInsets.symmetric(horizontal: 6, vertical: 6)].
  final EdgeInsets dropdownContainerPadding;

  /// Set to false to disable the text field. Defaults to true.
  final bool isEnabled;

  final FormFieldValidator<String>? validator;

  /// Set to true to enable search in single-select dropdowns.
  final bool enableSearch;

  final bool readOnly;

  /// Set to true to show the full list of selected items; otherwise shows "N item selected".
  final bool displayCompleteItem;

  /// Maximum number of visible dropdown items. Defaults to 6.
  final int dropDownItemCount;

  final FocusNode? searchFocusNode;
  final FocusNode? textFieldFocusNode;
  final TextStyle? searchTextStyle;

  /// Overrides the default search field decoration.
  final InputDecoration? searchDecoration;

  /// Overrides the search keyboard type (single-select with search only).
  final TextInputType? searchKeyboardType;

  /// Set to true to auto-focus the search field on open (single-select with search only).
  final bool searchAutofocus;

  /// Set to false to hide the cursor in the search field.
  final bool? searchShowCursor;

  /// Set to false to hide the clear suffix icon.
  final bool clearOption;

  /// Customizes the clear icon.
  final IconProperty? clearIconProperty;

  /// Background color of the suffix icon area.
  final Color? suffixIconColor;

  /// Padding inside the suffix icon area.
  final EdgeInsets? suffixIconPadding;

  /// Space between the text field and the dropdown list. Defaults to 0.
  final double listSpace;

  /// Padding for each list item.
  final ListPadding? listPadding;

  /// Submit button text for multi-select.
  final String? submitButtonText;

  /// Submit button color for multi-select.
  final Color? submitButtonColor;

  /// Submit button text style for multi-select.
  final TextStyle? submitButtonTextStyle;

  /// Text style for unselected list items.
  final TextStyle? listTextStyle;

  /// Text style for the selected list item.
  final TextStyle? selectListTextStyle;

  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> with TickerProviderStateMixin {
  late TextEditingController _cnt;
  late String _hintText;

  late bool _isExpanded;
  OverlayEntry? _entry;
  OverlayEntry? _entry2;
  OverlayEntry? _barrierOverlay;
  final _layerLink = LayerLink();
  late AnimationController _controller;

  // FadeTransition animation: fades in quickly, fades out at full speed.
  late CurvedAnimation _fadeAnimation;
  // SizeTransition animation: grows from the anchor edge with a cubic ease.
  late CurvedAnimation _sizeAnimation;
  // True when the dropdown opens upward (not enough space below).
  bool _isOpenUpward = false;

  List<bool> _multiSelectionValue = [];
  late double _height;
  late List<DropDownValueModel> _dropDownList;
  late int _maxListItem;
  late double _searchWidgetHeight;
  late FocusNode _searchFocusNode;
  late FocusNode _textFieldFocusNode;
  late bool _isOutsideClickOverlay;
  late bool _isScrollPadding;
  // Delay (ms) before requesting search focus after overlay shift.
  static const int _duration = 200;
  late Offset _offset;
  late bool _searchAutofocus;
  late bool _isPortrait;
  late double _listTileHeight;
  late double _keyboardHeight;
  late TextStyle _listTileTextStyle;
  late TextStyle _selectListTextStyle;
  late ListPadding _listPadding;
  late TextDirection _currentDirection;
  final GlobalKey overlayKey = GlobalKey();

  @override
  void initState() {
    _cnt = TextEditingController();
    _keyboardHeight = 450;
    _searchAutofocus = false;
    _isScrollPadding = false;
    _isOutsideClickOverlay = false;
    _searchFocusNode = widget.searchFocusNode ?? FocusNode();
    _textFieldFocusNode = widget.textFieldFocusNode ?? FocusNode();
    _isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    // Grows/shrinks from the anchor edge with a smooth cubic curve.
    _sizeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    // Fades in fast (first 70% of open), fades out linearly.
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    _searchWidgetHeight = 70;
    _hintText = 'Select Item';
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && !_textFieldFocusNode.hasFocus && _isExpanded && !widget.isMultiSelection) {
        _isExpanded = !_isExpanded;
        hideOverlay();
      }
    });
    _textFieldFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && !_textFieldFocusNode.hasFocus && _isExpanded) {
        _isExpanded = !_isExpanded;
        hideOverlay();
        if (!widget.readOnly && widget.singleController?.dropDownValue?.name != _cnt.text) {
          setState(() {
            _cnt.clear();
          });
        }
      }
    });
    widget.singleController?.addListener(() {
      if (widget.singleController?.dropDownValue == null) {
        clearFun();
      }
    });
    for (int i = 0; i < widget.dropDownList.length; i++) {
      _multiSelectionValue.add(false);
    }

    updateInitialValue();
    updateFunction();
    super.initState();
  }

  Size _textWidgetSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  void updateInitialValue() {
    if (widget.initialValue != null) {
      _dropDownList = List.from(widget.dropDownList);
      if (widget.isMultiSelection) {
        for (int i = 0; i < widget.initialValue.length; i++) {
          final index = _dropDownList.indexWhere((element) => element.value.trim() == widget.initialValue[i].trim());
          if (index != -1) {
            _multiSelectionValue[index] = true;
          }
        }
        final int count = _multiSelectionValue.where((element) => element).toList().length;

        _cnt.text = (count == 0
            ? ''
            : widget.displayCompleteItem
            ? (widget.initialValue ?? []).join(',')
            : '$count item selected');
      } else {
        final element = _dropDownList.firstWhere(
          (element) => element.value.trim() == widget.initialValue.trim(),
          orElse: () => DropDownValueModel(value: '', name: ''),
        );

        if (element.value.isNotEmpty) {
          _cnt.text = element.name;
        }
      }
    }
  }

  void updateFunction({SearchableDropdown? oldWidget}) {
    _dropDownList = List.from(widget.dropDownList);
    _listPadding = widget.listPadding ?? ListPadding();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isMultiSelection) {
        if (oldWidget != null && !const DeepCollectionEquality().equals(oldWidget.dropDownList, _dropDownList)) {
          _multiSelectionValue = [];
          _cnt.text = '';
          for (int i = 0; i < _dropDownList.length; i++) {
            _multiSelectionValue.add(false);
          }
        }
      } else {
        if (widget.singleController != null) {
          if (widget.singleController!.dropDownValue != null) {
            _cnt.text = widget.singleController!.dropDownValue!.name;
          } else {
            _cnt.clear();
          }
        }
      }

      _listTileTextStyle = (widget.listTextStyle ?? Theme.of(context).textTheme.titleMedium)!;
      _selectListTextStyle = (widget.selectListTextStyle ?? Theme.of(context).textTheme.titleMedium)!.copyWith(
        color: widget.selectTextColor,
      );
      _listTileHeight =
          _textWidgetSize('dummy Text', _listTileTextStyle).height + _listPadding.top + _listPadding.bottom;
      _maxListItem = widget.dropDownItemCount;

      _height =
          (!widget.isMultiSelection
              ? (_dropDownList.length < _maxListItem
                    ? _dropDownList.length * _listTileHeight
                    : _listTileHeight * _maxListItem.toDouble())
              : _dropDownList.length < _maxListItem
              ? _dropDownList.length * _listTileHeight
              : _listTileHeight * _maxListItem.toDouble()) +
          10;
    });
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFunction(oldWidget: oldWidget);
    if (widget.dropDownList != oldWidget.dropDownList || widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          updateInitialValue();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.searchFocusNode == null) _searchFocusNode.dispose();
    if (widget.textFieldFocusNode == null) _textFieldFocusNode.dispose();
    _sizeAnimation.dispose();
    _fadeAnimation.dispose();
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    _cnt.dispose();
    super.dispose();
  }

  void clearFun() {
    if (_isExpanded) {
      _isExpanded = !_isExpanded;
      hideOverlay();
    }
    _cnt.clear();
    if (widget.isMultiSelection) {
      if (widget.onChanged != null) {
        widget.onChanged!([]);
      }

      _multiSelectionValue = [];
      for (int i = 0; i < _dropDownList.length; i++) {
        _multiSelectionValue.add(false);
      }
    } else {
      if (widget.singleController != null) {
        widget.singleController!.clearDropDown();
      }
      if (widget.onChanged != null) {
        widget.onChanged!(DropDownValueModel(name: '', value: ''));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    _currentDirection = Directionality.of(context);
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (!isKeyboardVisible && _isExpanded && _isScrollPadding) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            shiftOverlayEntry2to1();
          });
        }
        return CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: _cnt,
            focusNode: _textFieldFocusNode,
            keyboardType: widget.keyboardType,
            autovalidateMode: widget.autovalidateMode,
            style: widget.textStyle,
            enabled: widget.isEnabled,
            readOnly: widget.readOnly,
            onTapOutside: (event) {
              final ctx = overlayKey.currentContext;
              if (ctx != null) {
                final RenderBox? renderBox = ctx.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final overlayPosition = renderBox.localToGlobal(Offset.zero);
                  final overlaySize = renderBox.size;
                  final bool isOverlayTap =
                      (overlayPosition.dx <= event.position.dx &&
                          event.position.dx <= overlayPosition.dx + overlaySize.width) &&
                      (overlayPosition.dy <= event.position.dy &&
                          event.position.dy <= overlayPosition.dy + overlaySize.height);

                  if (!isOverlayTap) {
                    _textFieldFocusNode.unfocus();
                  }
                }
              }
            },
            onTap: () {
              _searchAutofocus = widget.searchAutofocus;
              if (!_isExpanded) {
                _showOverlay();
              } else {
                if (widget.readOnly) hideOverlay();
              }
            },
            validator: (value) => widget.validator != null ? widget.validator!(value) : null,
            decoration: widget.textFieldDecoration != null
                ? widget.textFieldDecoration!.copyWith(
                    suffixIcon: Container(
                      color: widget.suffixIconColor,
                      padding: widget.suffixIconPadding ?? EdgeInsets.zero,
                      child: (_cnt.text.isEmpty || !widget.clearOption)
                          ? Icon(
                              widget.dropDownIconProperty?.icon ?? Icons.arrow_drop_down_outlined,
                              size: widget.dropDownIconProperty?.size,
                              color: widget.dropDownIconProperty?.color,
                            )
                          : InkWell(
                              onTap: clearFun,
                              child: Icon(
                                widget.clearIconProperty?.icon ?? Icons.clear,
                                size: widget.clearIconProperty?.size,
                                color: widget.clearIconProperty?.color,
                              ),
                            ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  )
                : InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: _hintText,
                    hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                    suffixIcon: Container(
                      color: widget.suffixIconColor,
                      padding: widget.suffixIconPadding ?? EdgeInsets.zero,
                      child: (_cnt.text.isEmpty || !widget.clearOption)
                          ? Icon(
                              widget.dropDownIconProperty?.icon ?? Icons.arrow_drop_down_outlined,
                              size: widget.dropDownIconProperty?.size,
                              color: widget.dropDownIconProperty?.color,
                            )
                          : InkWell(
                              onTap: clearFun,
                              child: Icon(
                                widget.clearIconProperty?.icon ?? Icons.clear,
                                size: widget.clearIconProperty?.size,
                                color: widget.clearIconProperty?.color,
                              ),
                            ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showOverlay() async {
    // Always start animation from zero for a clean open.
    _controller.forward(from: 0.0);
    _isExpanded = true;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    _offset = renderBox.localToGlobal(Offset.zero);
    final double posFromTop = _offset.dy;
    final double posFromBot = MediaQuery.of(context).size.height - posFromTop;

    final double dropdownListHeight = _height + (widget.enableSearch ? _searchWidgetHeight : 0) + widget.listSpace;
    final double ht = dropdownListHeight + 120;
    if (_searchAutofocus && !(posFromBot < ht) && posFromBot < _keyboardHeight && !_isScrollPadding && _isPortrait) {
      _isScrollPadding = true;
    }
    _isOutsideClickOverlay =
        _isScrollPadding ||
        (widget.readOnly &&
            dropdownListHeight > (posFromTop - MediaQuery.of(context).padding.top - 15) &&
            posFromBot < ht);
    final double topPaddingHeight = _isOutsideClickOverlay
        ? (dropdownListHeight - (posFromTop - MediaQuery.of(context).padding.top - 15))
        : 0;

    final double htPos = posFromBot < ht
        ? size.height - 100 + topPaddingHeight
        : _isScrollPadding
        ? size.height - (_keyboardHeight - posFromBot)
        : size.height;

    // Determines animation grow direction (upward vs downward).
    _isOpenUpward = posFromBot < ht;

    if (_isOutsideClickOverlay) {
      _openOutSideClickOverlay(context);
    }

    if (_isScrollPadding) {
      _entry2 = OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.bottomCenter,
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, htPos),
            child: _buildOverlayContent(),
          ),
        ),
      );
      overlay.insert(_entry2!);
    } else {
      _entry = OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            targetAnchor: posFromBot < ht ? Alignment.bottomCenter : Alignment.topCenter,
            followerAnchor: posFromBot < ht ? Alignment.bottomCenter : Alignment.topCenter,
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, posFromBot < ht ? htPos - widget.listSpace : htPos + widget.listSpace),
            child: _buildOverlayContent(),
          ),
        ),
      );
      overlay.insert(_entry!);
    }
  }

  void _openOutSideClickOverlay(BuildContext context) {
    final overlay2 = Overlay.of(context);
    _barrierOverlay = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return GestureDetector(
          onTap: () {
            hideOverlay();
          },
          child: Container(width: size.width, height: size.height, color: Colors.transparent),
        );
      },
    );
    overlay2.insert(_barrierOverlay!);
  }

  void hideOverlay() {
    _controller.reverse().then<void>((void value) {
      if (_entry != null && _entry!.mounted) {
        _entry?.remove();
        _entry = null;
      }
      if (_entry2 != null && _entry2!.mounted) {
        _entry2?.remove();
        _entry2 = null;
      }

      if (_barrierOverlay != null && _barrierOverlay!.mounted) {
        _barrierOverlay?.remove();
        _barrierOverlay = null;
        _isOutsideClickOverlay = false;
      }
      _isScrollPadding = false;
      _isExpanded = false;
    });
    _textFieldFocusNode.unfocus();
  }

  void shiftOverlayEntry1to2() {
    _entry?.remove();
    _entry = null;
    if (_barrierOverlay != null && _barrierOverlay!.mounted) {
      _barrierOverlay?.remove();
      _barrierOverlay = null;
      _isOutsideClickOverlay = false;
    }
    _isScrollPadding = true;
    _showOverlay();
    _textFieldFocusNode.requestFocus();

    Future.delayed(const Duration(milliseconds: _duration), () {
      _searchFocusNode.requestFocus();
    });
  }

  void shiftOverlayEntry2to1() {
    _searchAutofocus = false;
    _entry2?.remove();
    _entry2 = null;
    if (_barrierOverlay != null && _barrierOverlay!.mounted) {
      _barrierOverlay?.remove();
      _barrierOverlay = null;
      _isOutsideClickOverlay = false;
    }
    _controller.reset();
    _isScrollPadding = false;
    _showOverlay();
    _textFieldFocusNode.requestFocus();
  }

  /// Builds the animated dropdown overlay content.
  ///
  /// Animation: scale 0.95→1.0 + translateY ±8px→0 + fade-in.
  /// - Opens downward → starts 8 px above its final position, slides down.
  /// - Opens upward   → starts 8 px below its final position, slides up.
  /// - Scale is anchored at the trigger edge (topCenter / bottomCenter).
  /// - The [Material] subtree is passed as [AnimatedBuilder.child] so it is
  ///   built only once; only the thin [Opacity]+[Transform] shell rebuilds
  ///   on each animation frame.
  Widget _buildOverlayContent() {
    return Directionality(
      textDirection: _currentDirection,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double t = _sizeAnimation.value; // 0.0 → 1.0, easeOutCubic
          // Scale: 95 % → 100 %, anchored at the dropdown's trigger edge.
          final double scale = 0.95 + 0.05 * t;
          // Translate: slides from ±8 px toward the trigger into final place.
          final double dy = _isOpenUpward ? 4.0 * (1.0 - t) : -4.0 * (1.0 - t);

          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0.0, dy),
              child: Transform.scale(
                scale: scale,
                alignment: _isOpenUpward ? Alignment.bottomCenter : Alignment.topCenter,
                child: child,
              ),
            ),
          );
        },
        child: Material(
          key: overlayKey,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Container(
              clipBehavior: Clip.hardEdge,
              padding: widget.dropdownContainerPadding,
              decoration:
                  widget.dropdownContainerDecoration ??
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
                  ),
              child: SingleSelection(
                mainController: _cnt,
                autoSort: !widget.readOnly,
                mainFocusNode: _textFieldFocusNode,
                searchTextStyle: widget.searchTextStyle,
                searchFocusNode: _searchFocusNode,
                enableSearch: widget.enableSearch,
                height: _height,
                listTileHeight: _listTileHeight,
                dropDownList: _dropDownList,
                listTextStyle: _listTileTextStyle,
                selectListTextStyle: _selectListTextStyle,
                emptyMessage: widget.emptyMessage,
                selectColor: widget.selectColor,
                selectBorderRadius: widget.selectBorderRadius,
                onChanged: (item) {
                  setState(() {
                    _cnt.text = item.name;
                    _isExpanded = !_isExpanded;
                  });
                  if (widget.singleController != null) {
                    widget.singleController!.setDropDown(item);
                  }
                  if (widget.onChanged != null) {
                    widget.onChanged!(item);
                  }

                  hideOverlay();
                },
                searchHeight: _searchWidgetHeight,
                searchKeyboardType: widget.searchKeyboardType,
                searchAutofocus: _searchAutofocus,
                searchDecoration: widget.searchDecoration,
                searchShowCursor: widget.searchShowCursor,
                listPadding: _listPadding,
                clearIconProperty: widget.clearIconProperty,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DropDownValueModel extends Equatable {
  final String name;
  final dynamic value;

  /// Tooltip message for multi-select items.
  final String? toolTipMsg;

  const DropDownValueModel({required this.name, required this.value, this.toolTipMsg});

  factory DropDownValueModel.fromJson(Map<String, dynamic> json) =>
      DropDownValueModel(name: json['name'], value: json['value'], toolTipMsg: json['toolTipMsg']);

  Map<String, dynamic> toJson() => {'name': name, 'value': value, 'toolTipMsg': toolTipMsg};

  @override
  List<Object> get props => [name, value];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropDownValueModel && runtimeType == other.runtimeType && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}

class SingleValueDropDownController extends ChangeNotifier {
  DropDownValueModel? dropDownValue;
  SingleValueDropDownController({DropDownValueModel? data}) {
    setDropDown(data);
  }

  void setDropDown(DropDownValueModel? model) {
    if (dropDownValue != model) {
      dropDownValue = model;
      notifyListeners();
    }
  }

  void clearDropDown() {
    if (dropDownValue != null) {
      dropDownValue = null;
      notifyListeners();
    }
  }
}

class ListPadding {
  double top;
  double bottom;
  double left;
  double right;
  ListPadding({this.top = 8, this.bottom = 8, this.left = 8, this.right = 8});
}

class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;
  const KeyboardVisibilityBuilder({super.key, required this.builder});
  @override
  State<KeyboardVisibilityBuilder> createState() => _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder> with WidgetsBindingObserver {
  var _isKeyboardVisible = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isKeyboardVisible);
}

class SingleSelection extends StatefulWidget {
  const SingleSelection({
    super.key,
    required this.dropDownList,
    required this.onChanged,
    required this.height,
    required this.enableSearch,
    required this.searchHeight,
    this.searchTextStyle,
    required this.searchFocusNode,
    required this.mainFocusNode,
    this.searchKeyboardType,
    required this.searchAutofocus,
    this.searchShowCursor,
    required this.mainController,
    required this.autoSort,
    required this.listTileHeight,
    this.emptyMessage,
    required this.selectColor,
    this.selectBorderRadius,
    this.selectListTextStyle,
    this.onSearchTap,
    this.onSearchSubmit,
    this.listTextStyle,
    this.searchDecoration,
    required this.listPadding,
    this.clearIconProperty,
  });

  final List<DropDownValueModel> dropDownList;
  final ValueSetter onChanged;
  final double height;
  final double listTileHeight;
  final bool enableSearch;
  final double searchHeight;
  final TextStyle? searchTextStyle;
  final FocusNode searchFocusNode;
  final FocusNode mainFocusNode;
  final TextInputType? searchKeyboardType;
  final Color selectColor;
  final BorderRadius? selectBorderRadius;
  final bool searchAutofocus;
  final bool? searchShowCursor;
  final TextEditingController mainController;
  final bool autoSort;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSearchSubmit;
  final TextStyle? listTextStyle;
  final TextStyle? selectListTextStyle;
  final ListPadding listPadding;
  final InputDecoration? searchDecoration;
  final IconProperty? clearIconProperty;
  final String? emptyMessage;

  @override
  State<SingleSelection> createState() => _SingleSelectionState();
}

class _SingleSelectionState extends State<SingleSelection> {
  late List<DropDownValueModel> newDropDownList;
  late TextEditingController _searchCnt;
  late InputDecoration _inpDec;

  void onItemChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        newDropDownList = List.from(widget.dropDownList);
      } else {
        newDropDownList = widget.dropDownList
            .where((item) => item.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    _inpDec = widget.searchDecoration ?? const InputDecoration();
    if (widget.searchAutofocus) {
      widget.searchFocusNode.requestFocus();
    }
    newDropDownList = List.from(widget.dropDownList);
    _searchCnt = TextEditingController();
    if (widget.autoSort) {
      onItemChanged(widget.mainController.text);
      widget.mainController.addListener(() {
        if (mounted) {
          onItemChanged(widget.mainController.text);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchCnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enableSearch)
          SizedBox(
            height: widget.searchHeight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: widget.searchTextStyle,
                focusNode: widget.searchFocusNode,
                showCursor: widget.searchShowCursor,
                keyboardType: widget.searchKeyboardType,
                controller: _searchCnt,
                onTap: () {
                  if (widget.onSearchTap != null) {
                    widget.onSearchTap!();
                  }
                },
                decoration: _inpDec.copyWith(
                  hintText: _inpDec.hintText ?? 'Search Here...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      widget.mainFocusNode.requestFocus();
                      _searchCnt.clear();
                      onItemChanged('');
                    },
                    child: widget.searchFocusNode.hasFocus
                        ? Icon(
                            widget.clearIconProperty?.icon ?? Icons.close,
                            size: widget.clearIconProperty?.size,
                            color: widget.clearIconProperty?.color,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                onChanged: onItemChanged,
                onSubmitted: (val) {
                  widget.mainFocusNode.requestFocus();
                  if (widget.onSearchSubmit != null) {
                    widget.onSearchSubmit!();
                  }
                },
              ),
            ),
          ),
        if (newDropDownList.isNotEmpty)
          SizedBox(
            height: widget.height,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: newDropDownList.length,
              itemBuilder: (BuildContext context, int index) {
                final bool isSelected = widget.mainController.text.trim() == newDropDownList[index].name;
                final BorderRadius radius = widget.selectBorderRadius ?? BorderRadius.circular(12);
                return InkWell(
                  onTap: () {
                    widget.onChanged(newDropDownList[index]);
                  },
                  borderRadius: radius,
                  child: Container(
                    // Use minHeight so that long text wraps rather than being clipped.
                    constraints: BoxConstraints(minHeight: widget.listTileHeight),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.selectColor : Colors.transparent,
                      borderRadius: radius,
                    ),
                    padding: EdgeInsets.only(
                      right: widget.listPadding.right,
                      left: widget.listPadding.left,
                      bottom: widget.listPadding.bottom,
                      top: widget.listPadding.top,
                    ),
                    child: Text(
                      newDropDownList[index].name,
                      style: isSelected ? widget.selectListTextStyle : widget.listTextStyle,
                    ),
                  ),
                );
              },
            ),
          ),
        if (newDropDownList.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Text(
                widget.emptyMessage ?? 'Please provide some dropdown list.',
                style: const TextStyle(fontSize: 14, color: Color(0xff90909A)),
              ),
            ),
          ),
      ],
    );
  }
}
