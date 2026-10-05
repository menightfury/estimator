import 'package:estimator/common_libs.dart';
import 'package:estimator/database/table_schema.dart';

// enum InveslyAccountIcon {
//   wallet(Icons.account_balance_wallet_rounded),
//   savings(Icons.savings_rounded),
//   card(Icons.credit_card_rounded),
//   home(Icons.home_rounded),
//   business(Icons.business_center_rounded),
//   chart(Icons.show_chart_rounded),
//   currency(Icons.currency_exchange_rounded),
//   receipt(Icons.receipt_long_rounded);

//   const InveslyAccountIcon(this.data);

//   final IconData data;

//   static InveslyAccountIcon? fromName(String value) {
//     if (value.trim().isEmpty) {
//       return null;
//     }

//     return values.firstWhereOrNull((icon) => icon.name == value);
//   }

//   Widget buildWidget(
//     BuildContext context, {
//     Color? color,
//     Color? backgroundColor,
//     BoxBorder? border,
//     double? iconSize,
//     double? radius,
//     double? padding = 8.0,
//   }) {
//     return Icon(data, color: color, size: iconSize).inContainer(
//       context,
//       color: backgroundColor ?? color?.lighten(80),
//       border: border,
//       radius: radius,
//       padding: padding,
//     );
//   }
// }

enum EstimatorItemType {
  material('Material'),
  labor('Labour'),
  both('Material + Labour');

  const EstimatorItemType(this.title);

  final String title;

  IconData get icon {
    return switch (this) {
      material => Icons.north_east_rounded,
      _ => Icons.south_west_rounded,
    };
  }

  static EstimatorItemType? fromName(String value) {
    final $value = value.trim();
    if ($value.isEmpty) {
      return null;
    }

    return values.firstWhereOrNull((type) => type.name == $value);
  }

  static EstimatorItemType? fromCode(String value) {
    final $value = value.trim();
    if ($value.isEmpty) return null;

    final $string = $value.toLowerCase();
    return switch ($string) {
      'm' => material,
      'l' => labor,
      'ml' => both,
      _ => null,
    };
  }

  Color color(BuildContext context) {
    return switch (this) {
      material => Colors.pink,
      labor => Colors.teal,
      both => Colors.blueAccent,
    };
  }
}

class ItemInDb extends TableDataModel {
  const ItemInDb({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    this.typeString,
  });

  final String id;
  final String name;
  final String description;
  final String unit;
  final String? typeString;

  @override
  List<Object?> get props => [id, name, description, unit, typeString];
}

class EstimatorItem extends ItemInDb {
  EstimatorItem({required super.id, required super.name, required super.description, required super.unit, this.type})
    : super(typeString: type?.name);

  final EstimatorItemType? type;

  // static const Color _defaultColor = EstimatorColors.green;

  factory EstimatorItem.fromDb(ItemInDb item) {
    return EstimatorItem(
      id: item.id,
      name: item.name,
      description: item.description,
      unit: item.unit,
      type: item.typeString != null ? EstimatorItemType.fromCode(item.typeString!) : null,
    );
  }
}

class ItemTable extends TableSchema<ItemInDb> {
  // Singleton pattern to ensure only one instance exists
  const ItemTable._() : super('items');
  static const instance = ItemTable._();
  factory ItemTable() => instance;

  TableColumn<String> get idColumn => TableColumn<String>('id', title, isPrimary: true);
  TableColumn<String> get nameColumn => TableColumn<String>('name', title, isUnique: true);
  TableColumn<String> get descriptionColumn => TableColumn<String>('description', title);
  TableColumn<String> get unitColumn => TableColumn<String>('unit', title);
  TableColumn<int> get typeColumn => TableColumn<int>('type', title, isNullable: true);

  @override
  Set<TableColumn> get columns => {idColumn, nameColumn, descriptionColumn, unitColumn, typeColumn};

  @override
  Map<String, dynamic> fromModel(ItemInDb item) {
    return <String, dynamic>{
      idColumn.title: item.id,
      nameColumn.title: item.name,
      descriptionColumn.title: item.description,
      unitColumn.title: item.unit,
      typeColumn.title: item.typeString,
    };
  }

  @override
  ItemInDb fromMap(Map<String, dynamic> map) {
    return ItemInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      description: map[descriptionColumn.title] as String,
      unit: map[unitColumn.title] as String,
      typeString: map[typeColumn.title] as String?,
    );
  }
}
