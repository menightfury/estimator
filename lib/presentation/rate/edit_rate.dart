import 'package:estimator/common/widgets/date_picker.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/presentation/widgets/loa_picker.dart';

import 'cubit/edit_rate_cubit.dart';

class EditRatePage extends StatelessWidget {
  const EditRatePage({
    super.key,
    // this.initialRate, this.initialAccountId, this.initialAmc
  });

  // final InveslyRate? initialRate;
  // final int? initialAccountId;
  // final InveslyAmc? initialAmc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return EditRateCubit(
          repository: EstimatorRepository.instance,
          // initialRate: initialRate,
          // initialAccountId: initialAccountId,
          // initialAmc: initialAmc,
        );
      },
      child: const _EditRatePageContent(),
    );
  }
}

class _EditRatePageContent extends StatefulWidget {
  const _EditRatePageContent({super.key});

  @override
  State<_EditRatePageContent> createState() => _EditRatePageContentState();
}

class _EditRatePageContentState extends State<_EditRatePageContent> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditRateCubit>();
    // final genres = AmcGenre.values;
    // final types = RateType.values;
    $logger.i('Rebuilding edit Rate screen');

    // return BlocListener<EditRateCubit, EditRateState>(
    //   listenWhen: (prev, curr) => prev.loaNumber != curr.loaNumber,
    //   listener: (context, state) async {
    //     loaNumberController.text = state.loaNumber ?? '';
    //     late final SnackBar message;
    //     if (state.status == EditRateStatus.saved) {
    //       message = const SnackBar(content: Text('Investment saved successfully'), backgroundColor: Colors.teal);
    //       context.canPop ? Navigator.pop(context) : context.go(const DashboardPage());
    //     } else if (state.status == EditRateStatus.failed) {
    //       message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
    //     }
    //     ScaffoldMessenger.of(context)
    //       ..hideCurrentSnackBar()
    //       ..showSnackBar(message);
    //   },
    //   child: PopScope(
    //     canPop: false, // prevents default
    //     onPopInvokedWithResult: (didPop, _) async {
    //       if (didPop) return;

    //       if (cubit.state.isEdited) {
    //         final shouldPop = await showDiscardChangesDialog(context) ?? false;
    //         if (shouldPop && context.mounted) Navigator.pop(context);
    //       } else {
    //         if (context.mounted) Navigator.pop(context);
    //       }
    // },
    // child:
    return Scaffold(
      appBar: AppBar(title: Text('Add / Edit Rate')),
      body: SafeArea(
        child: ListView(
          padding: iPaddingFromScreenEdge,
          children: <Widget>[
            // SliverAppBar(
            //   snap: true,
            //   floating: true,
            //   title: Text('${cubit.state.isNewRate ? 'Add' : 'Edit'} Investment'),
            // ),

            // ~ Title
            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
            //     Text(cubit.state.isNewRate ? 'Add' : 'Edit', style: context.textTheme.headlineSmall),
            //     Text('Rates', style: context.textTheme.headlineMedium),
            //   ],
            // ),

            // ~ LOA picker
            SizedBox(height: 300.0, child: LoaPicker(onPickup: (value) => cubit.getRatesOfLoa(value))),

            const Gap(iFormFieldsInterSpacing),

            // ~~~ LOA Details ~~~
            Row(
              spacing: iFormFieldLabelSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: BlocSelector<EditRateCubit, EditRateState, String?>(
                    selector: (state) => state.loaNumber,
                    builder: (context, loaNumber) {
                      return Text(loaNumber ?? 'LOA / PO Number');
                    },
                  ),
                ),
                Expanded(
                  child: BlocSelector<EditRateCubit, EditRateState, DateTime?>(
                    selector: (state) => state.date,
                    builder: (context, date) {
                      return EstimatorDatePicker(initialDate: date, child: Text(date?.toReadable() ?? 'Pick a date'));
                    },
                  ),
                ),
                Expanded(
                  // child: TextField(
                  //   decoration: InputDecoration(hintText: 'Rebate'),
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: <TextInputFormatter>[
                  //     // FilteringTextInputFormatter.digitsOnly, // Blocks everything except 0-9
                  //     FilteringTextInputFormatter.allow(
                  //       RegExp(r'^\d*\.?\d*'),
                  //     ), // Allows only digits and a single decimal point
                  //     MaxValueTextInputFormatter(100), // Restrict maximum value to 100
                  //   ],
                  // ),
                  child: BlocSelector<EditRateCubit, EditRateState, double?>(
                    selector: (state) => state.rebate,
                    builder: (context, rebate) {
                      return Text('${rebate ?? 0}');
                    },
                  ),
                ),
              ],
            ),

            const Gap(iFormFieldsInterSpacing),

            // ~~~ Rate Details ~~~
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: iFormFieldsInterSpacing,
              children: <Widget>[
                Row(
                  spacing: iFormFieldLabelSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextField(decoration: InputDecoration(hintText: 'Select Item')),
                    ),
                    Expanded(
                      child: TextField(decoration: InputDecoration(hintText: 'Schedule Number')),
                    ),
                    Expanded(
                      child: TextField(decoration: InputDecoration(hintText: 'Serial Number')),
                    ),
                  ],
                ),
                Row(
                  spacing: iFormFieldLabelSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Tender Rate'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // FilteringTextInputFormatter.digitsOnly, // Blocks everything except 0-9
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ), // Allows only digits and a single decimal point
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Offered Rate'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // FilteringTextInputFormatter.digitsOnly, // Blocks everything except 0-9
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ), // Allows only digits and a single decimal point
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Offered Percentage (%)'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // FilteringTextInputFormatter.digitsOnly, // Blocks everything except 0-9
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ), // Allows only digits and a single decimal point
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                onPressed: () {},
                label: const Text('Add item'),
                icon: Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }

  // Future<void> _handleSavePressed(BuildContext context) async {
  //   final RateCubit = context.read<EditRateCubit>();
  //   await RateCubit.save();
  // }
}

// class _DatePicker extends StatelessWidget {
//   const _DatePicker({super.key});

//   Widget _buildChild(BuildContext context, [DateTime? date]) {
//     if (date == null) {
//       return const Text(
//         'Select date',
//         style: TextStyle(color: Colors.grey),
//         overflow: TextOverflow.ellipsis,
//       );
//     }
//     final days = DateTime.now().difference(date).inDays;
//     final label = switch (days) {
//       0 => 'Today',
//       1 => 'Yesterday',
//       _ => date.toReadable(),
//     };
//     return Text(label, overflow: TextOverflow.ellipsis);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateNow = DateTime.now();
//     final cubit = context.read<EditRateCubit>();

//     return BlocBuilder<EditRateCubit, EditRateState>(
//       buildWhen: (prev, curr) {
//         return prev.date != curr.date ||
//             prev.dateError != curr.dateError ||
//             (prev.status != curr.status && curr.isError && curr.dateError != null);
//       },
//       builder: (context, state) {
//         $logger.i('Date Picker Rebuilding');
//         return _TappableFocusableField(
//           onTap: () async {
//             final newDate = await showDatePicker(
//               context: context,
//               initialDate: state.date ?? dateNow,
//               firstDate: DateTime(1990),
//               lastDate: dateNow,
//             );
//             if (newDate == null) return;
//             cubit.updateDate(newDate.startOfDay);
//           },
//           // leading: const Icon(Icons.edit_calendar_rounded),
//           errorText: state.dateError,
//           child: _buildChild(context, state.date),
//         );
//       },
//     );
//   }
// }

// class _TappableFocusableField extends StatefulWidget {
//   const _TappableFocusableField({
//     super.key,
//     this.enabled = true,
//     this.onTap,
//     this.focusNode,
//     required this.child,
//     this.leading,
//     this.trailing,
//     this.errorText,
//     this.errorBuilder,
//     this.padding = iFormFieldContentPadding,
//     this.minHeight,
//     this.borderRadius,
//     this.suggestion,
//   });

//   final bool enabled;
//   final VoidCallback? onTap;
//   final FocusNode? focusNode;
//   final Widget child;
//   final Widget? leading;
//   final Widget? trailing;
//   final String? errorText;
//   final Widget Function(BuildContext, String)? errorBuilder;
//   final EdgeInsets padding;
//   final double? minHeight;
//   final BorderRadius? borderRadius;
//   final Widget? suggestion;

//   @override
//   State<_TappableFocusableField> createState() => _TappableFocusableFieldState();
// }

// class _TappableFocusableFieldState extends State<_TappableFocusableField> {
//   late final WidgetStatesController statesController;
//   FocusNode? get _focusNode => widget.focusNode;
//   // FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

//   bool get hasFocus => _focusNode?.hasFocus ?? false;

//   bool get hasError => widget.errorText != null;

//   void handleStatesControllerChange() {
//     // Force a rebuild to resolve WidgetStateProperty properties
//     setState(() {});
//   }

//   void handleFocusUpdate(bool hasFocus) {
//     statesController.update(WidgetState.focused, hasFocus);
//   }

//   @override
//   void initState() {
//     super.initState();
//     statesController = WidgetStatesController({
//       if (!widget.enabled) WidgetState.disabled,
//       if (hasError) WidgetState.error,
//       if (hasFocus) WidgetState.focused,
//     });

//     statesController.addListener(handleStatesControllerChange);
//   }

//   @override
//   void dispose() {
//     statesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final inputTheme = InputDecorationTheme.of(context);
//     final defaultColor = inputTheme.fillColor ?? context.colors.secondaryContainer.lighten(50);
//     final resolvedBorder = WidgetStateProperty.resolveAs<InputBorder?>(inputTheme.border, statesController.value);
//     final effectiveBorderRadius =
//         widget.borderRadius ?? (resolvedBorder is OutlineInputBorder ? resolvedBorder.borderRadius : BorderRadius.zero);

//     Widget content = widget.child;

//     if (widget.leading != null || widget.trailing != null) {
//       content = Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         // spacing: widget.spacing,
//         children: <Widget>[
//           ?widget.leading,
//           Expanded(child: content),
//           ?widget.trailing,
//         ],
//       );
//     }

//     // ~ inner container
//     content = Container(
//       decoration: BoxDecoration(
//         color: WidgetStateProperty.resolveAs<Color?>(defaultColor, statesController.value),
//         border: resolvedBorder != null ? Border.fromBorderSide(resolvedBorder.borderSide) : null,
//         borderRadius: effectiveBorderRadius,
//       ),
//       padding: widget.padding,
//       constraints: BoxConstraints(minWidth: double.infinity, minHeight: widget.minHeight ?? iFormFieldMinimumHeight),
//       child: content,
//     );

//     if (widget.onTap != null) {
//       content = GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: widget.enabled
//             ? () {
//                 widget.onTap?.call();
//                 widget.focusNode?.requestFocus();
//               }
//             : null,
//         child: content,
//       );
//     }

//     if (hasError) {
//       content = Shake(child: content);
//     }

//     if (_focusNode != null) {
//       content = TextFieldTapRegion(
//         onTapOutside: hasFocus ? (event) => _onTapOutside(context, event) : null,
//         child: Focus(focusNode: _focusNode, onFocusChange: handleFocusUpdate, child: content),
//       );
//     }

//     if (widget.suggestion != null) {
//       // ~ Suggestion container - Required for horizontally scrollable widgets
//       final suggestion = DecoratedBox(
//         position: DecorationPosition.foreground,
//         decoration: BoxDecoration(
//           border: Border.all(color: context.colors.secondaryContainer),
//           borderRadius: effectiveBorderRadius.copyWith(topLeft: Radius.zero, topRight: Radius.zero),
//         ),
//         child: Padding(
//           padding: widget.padding.copyWith(top: 8.0, bottom: 8.0),
//           child: DefaultTextStyle(
//             style: context.textTheme.bodySmall!.copyWith(color: context.colors.onSecondaryContainer),
//             child: AnimatedExpand(expand: true, duration: 500.ms, child: widget.suggestion!),
//           ),
//         ),
//       );

//       // ~ outer container
//       content = Container(
//         decoration: BoxDecoration(borderRadius: effectiveBorderRadius, color: context.colors.secondaryContainer),
//         clipBehavior: Clip.hardEdge,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[content, suggestion],
//         ),
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       // spacing: 4.0,
//       children: <Widget>[
//         content,

//         if (hasError)
//           Padding(
//             padding: widget.padding.copyWith(top: 4.0, bottom: 0.0),
//             child: FadeIn(
//               from: Offset(0.0, -0.25),
//               child: DefaultTextStyle(
//                 style: context.textTheme.bodySmall!
//                     .copyWith(color: context.colors.error)
//                     .merge(context.theme.inputDecorationTheme.errorStyle),
//                 child:
//                     widget.errorBuilder?.call(context, widget.errorText!) ??
//                     Text(widget.errorText!, overflow: TextOverflow.ellipsis, maxLines: 1),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   void _onTapOutside(BuildContext context, PointerDownEvent event) {
//     if (!mounted) return;
//     FocusScope.of(context).unfocus();
//   }
// }

class MaxValueTextInputFormatter extends TextInputFormatter {
  final num maxValue;

  MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Try parsing as integer or double depending on your needs
    final num? value = num.tryParse(newValue.text);

    if (value == null) {
      return oldValue; // Reject invalid characters (e.g. letters)
    }

    if (value > maxValue) {
      return oldValue; // Block input if it exceeds max value
    }

    return newValue;
  }
}
