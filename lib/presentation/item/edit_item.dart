import 'package:estimator/common/extensions/widget_extension.dart';
import 'package:estimator/common/widgets/searchable_dropdown.dart';
import 'package:estimator/common/widgets/searchable_list_view.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

import 'cubit/edit_item_cubit.dart';

class EditItemPage extends StatelessWidget {
  const EditItemPage({super.key, this.initialItem});

  final EstimatorItem? initialItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditItemCubit(repository: EstimatorRepository.instance, initialItem: initialItem),
      child: const _EditItemView(),
    );
  }
}

class _EditItemView extends StatelessWidget {
  const _EditItemView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditItemCubit, EditItemState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.isNew ? 'Item saved.' : 'Item updated.'), backgroundColor: Colors.teal),
            );
          if (context.canPop) context.pop();
        } else if (state.isErrorSaving) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Error saving item. Please try again.'), backgroundColor: Colors.redAccent),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocSelector<EditItemCubit, EditItemState, bool>(
            selector: (state) => state.isNew,
            builder: (_, isNew) => Text(isNew ? 'New Item' : 'Edit Item'),
          ),
        ),
        body: const SafeArea(child: _EditItemForm()),
      ),
    );
  }
}

class _EditItemForm extends StatefulWidget {
  const _EditItemForm();

  @override
  State<_EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<_EditItemForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditItemCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _descriptionController = TextEditingController(text: state.description);
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditItemCubit>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      children: <Widget>[
        // ~ Name field with autocomplete suggestions
        SizedBox(
          height: 300.0,
          child: SearchableListView<String>(
            optionsBuilder: (textEditingValue) {
              return ['Satya', 'Subho', 'Jyoti', 'Biswas', 'Jhuma', 'Mantu'];
            },
            optionViewBuilder: (context, option, isHighlighted, onSelected) {
              return ListTile(title: Text(option));
            },
          ),
        ),

        const Gap(20),

        _NameFieldWithSuggestions(
          controller: _nameController,
          focusNode: _nameFocusNode,
          onChanged: cubit.onNameChanged,
          onSuggestionSelected: (item) {
            // Sync controllers to the newly loaded values
            _nameController.text = item.name;
            _descriptionController.text = item.description;
            cubit.onSuggestionSelected(item);
          },
        ).withLabel('Item Name'),

        const Gap(20),

        // ~ Description field
        _DescriptionField(
          controller: _descriptionController,
          onChanged: cubit.onDescriptionChanged,
        ).withLabel('Description'),

        const Gap(20),

        // ~ Unit dropdown
        const _UnitDropdown().withLabel('Unit'),

        const Gap(20),

        // ~ Type choice
        const _TypePicker().withLabel('Type'),

        const Gap(32),

        // ~ Save button
        BlocSelector<EditItemCubit, EditItemState, bool>(
          selector: (state) => state.isSaving,
          builder: (context, isSaving) => ElevatedButton(
            onPressed: isSaving ? null : () => context.read<EditItemCubit>().save(),
            child: Text(isSaving ? 'Saving…' : 'Save Item'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Name field with live suggestion overlay
// ─────────────────────────────────────────────────────────────────────────────

class _NameFieldWithSuggestions extends StatelessWidget {
  const _NameFieldWithSuggestions({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<EstimatorItem> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TextField
        BlocSelector<EditItemCubit, EditItemState, String?>(
          selector: (s) => s.nameError,
          builder: (context, nameError) => TextField(
            controller: controller,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Reinforcement Steel',
              errorText: nameError,
              suffixIcon: BlocSelector<EditItemCubit, EditItemState, bool>(
                selector: (s) => s.isLoadingSuggestions,
                builder: (_, loading) => loading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            onChanged: onChanged,
          ),
        ),

        // Suggestions panel (only shown when list is non-empty)
        BlocSelector<EditItemCubit, EditItemState, List<EstimatorItem>>(
          selector: (s) => s.suggestions,
          builder: (context, suggestions) {
            if (suggestions.isEmpty) return const SizedBox.shrink();
            return _SuggestionPanel(suggestions: suggestions, onSelected: onSuggestionSelected);
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestions panel – rendered below the name field
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.suggestions, required this.onSelected});

  final List<EstimatorItem> suggestions;
  final ValueChanged<EstimatorItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [BoxShadow(color: colors.shadow.withAlpha(30), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.map((item) {
          return InkWell(
            onTap: () => onSelected(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: context.textTheme.labelSmall),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: context.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (item.type != null) ...[const Gap(8), _TypeBadge(type: item.type!)],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Description textarea – vertically resizable, min 4 lines
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 4,
      maxLines: null, // unbounded → user can keep typing / textarea grows
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(hintText: 'Optional description…', alignLabelWithHint: true),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unit dropdown – common construction measurement units
// ─────────────────────────────────────────────────────────────────────────────

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown();

  static const _units = <String>[
    'mtr', // metre
    'rmt', // running metre
    'sqm', // square metre
    'cum', // cubic metre
    'kg', // kilogram
    'MT', // metric tonne
    'nos', // numbers / pieces
    'set', // set
    'lump', // lump sum
    'lot', // lot
    'bag', // bag
    'ltr', // litre
    'hr', // hour
    'day', // day
    'job', // job
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EditItemCubit, EditItemState, String?>(
      selector: (state) => state.unit,
      builder: (context, selectedUnit) {
        return DropdownButtonFormField<String>(
          initialValue: selectedUnit,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Select unit'),
          items: _units.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
          onChanged: context.read<EditItemCubit>().onUnitChanged,
          validator: (v) => v == null ? 'Unit is required' : null,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type picker – three segmented choices
// ─────────────────────────────────────────────────────────────────────────────

class _TypePicker extends StatelessWidget {
  const _TypePicker();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EditItemCubit, EditItemState, EstimatorItemType?>(
      selector: (state) => state.type,
      builder: (context, selectedType) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EstimatorItemType.values.map((t) {
            final selected = selectedType == t;
            return _TypeChip(
              type: t,
              selected: selected,
              onTap: () {
                // Toggle off if already selected (type is optional).
                context.read<EditItemCubit>().onTypeChanged(selected ? null : t);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.selected, required this.onTap});

  final EstimatorItemType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chipColor = selected ? type.color(context) : colors.surface;
    final borderColor = selected ? type.color(context) : colors.outlineVariant;
    final labelColor = selected ? Colors.white : colors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: chipColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Text(
          type.title,
          style: context.textTheme.labelSmall?.copyWith(
            color: labelColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small type badge (used in suggestion panel)
// ─────────────────────────────────────────────────────────────────────────────

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
