import 'package:estimator/database/table_schema.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';

class RateInDb extends TableDataModel {
  const RateInDb({
    required this.id,
    required this.itemId,
    required this.loaId,
    this.loaSchedule,
    this.loaItemNumber,
    this.materialTenderRate,
    this.materialOfferedRate,
    this.materialOfferedPercent,
    this.labourTenderRate,
    this.labourOfferedRate,
    this.labourOfferedPercent,
  });

  final String id;
  final String itemId;
  final String loaId;
  final String? loaSchedule;
  final int? loaItemNumber;
  final double? materialTenderRate;
  final double? materialOfferedRate;
  final double? materialOfferedPercent;
  final double? labourTenderRate;
  final double? labourOfferedRate;
  final double? labourOfferedPercent;

  @override
  List<Object?> get props => [
    id,
    itemId,
    loaId,
    loaSchedule,
    loaItemNumber,
    materialTenderRate,
    materialOfferedRate,
    materialOfferedPercent,
    labourTenderRate,
    labourOfferedRate,
    labourOfferedPercent,
  ];
}

class EstimatorRate extends RateInDb {
  EstimatorRate({
    required super.id,
    required this.item,
    required this.loa,
    super.loaSchedule,
    super.loaItemNumber,
    required super.materialTenderRate,
    super.materialOfferedRate,
    super.materialOfferedPercent,
    super.labourTenderRate,
    super.labourOfferedRate,
    super.labourOfferedPercent,
  }) : super(itemId: item.id, loaId: loa.id);

  final EstimatorItem item;
  final EstimatorLoa loa;

  factory EstimatorRate.fromDb(RateInDb rate, ItemInDb item, LoaInDb loa) {
    return EstimatorRate(
      id: rate.id,
      item: EstimatorItem.fromDb(item),
      loa: EstimatorLoa.fromDb(loa),
      loaSchedule: rate.loaSchedule,
      loaItemNumber: rate.loaItemNumber,
      materialTenderRate: rate.materialTenderRate,
      materialOfferedRate: rate.materialOfferedRate,
      materialOfferedPercent: rate.materialOfferedPercent,
      labourTenderRate: rate.labourTenderRate,
      labourOfferedRate: rate.labourOfferedRate,
      labourOfferedPercent: rate.labourOfferedPercent,
    );
  }
}

// ~ Table Model
class RateTable extends TableSchema<RateInDb> {
  // Singleton pattern to ensure only one instance exists
  const RateTable._() : super('rates');
  static const instance = RateTable._();
  factory RateTable() => instance;

  TableColumn<String> get idColumn => TableColumn<String>('id', title, isPrimary: true);
  TableColumn<String> get itemIdColumn =>
      TableColumn<String>('item_id', title, foreignReference: ForeignReference('items', 'id'));
  TableColumn<String> get loaIdColumn =>
      TableColumn<String>('loa_id', title, foreignReference: ForeignReference('loas', 'id'));
  TableColumn<String> get loaScheduleColumn => TableColumn<String>('loa_schedule', title, isNullable: true);
  TableColumn<int> get loaItemNumberColumn => TableColumn<int>('loa_item_number', title, isNullable: true);

  // ~ Material (supply) related
  TableColumn<double> get materialTenderRateColumn =>
      TableColumn<double>('tender_rate_material', title, isNullable: true);
  TableColumn<double> get materialOfferedRateColumn =>
      TableColumn<double>('offered_rate_material', title, isNullable: true);
  TableColumn<double> get materialOfferedPercentColumn =>
      TableColumn<double>('offered_percent_material', title, isNullable: true);

  // ~ Labour (installation) related
  TableColumn<double> get labourTenderRateColumn => TableColumn<double>('tender_rate_labour', title, isNullable: true);
  TableColumn<double> get labourOfferedRateColumn =>
      TableColumn<double>('offered_rate_labour', title, isNullable: true);
  TableColumn<double> get labourOfferedPercentColumn =>
      TableColumn<double>('offered_percent_labour', title, isNullable: true);

  @override
  Set<TableColumn> get columns {
    return {
      idColumn,
      itemIdColumn,
      loaIdColumn,
      loaScheduleColumn,
      loaItemNumberColumn,
      materialTenderRateColumn,
      materialOfferedRateColumn,
      materialOfferedPercentColumn,
      labourTenderRateColumn,
      labourOfferedRateColumn,
      labourOfferedPercentColumn,
    };
  }

  @override
  Map<String, dynamic> fromModel(RateInDb rate) {
    return <String, dynamic>{
      idColumn.title: rate.id,
      itemIdColumn.title: rate.itemId,
      loaIdColumn.title: rate.loaId,
      loaScheduleColumn.title: rate.loaSchedule,
      loaItemNumberColumn.title: rate.loaItemNumber,
      materialTenderRateColumn.title: rate.materialTenderRate,
      materialOfferedRateColumn.title: rate.materialOfferedRate,
      materialOfferedPercentColumn.title: rate.materialOfferedPercent,
      labourTenderRateColumn.title: rate.labourTenderRate,
      labourOfferedRateColumn.title: rate.labourOfferedRate,
      labourOfferedPercentColumn.title: rate.labourOfferedPercent,
    };
  }

  @override
  RateInDb fromMap(Map<String, dynamic> map) {
    return RateInDb(
      id: map[idColumn.title] as String,
      itemId: map[itemIdColumn.title] as String,
      loaId: map[loaIdColumn.title] as String,
      loaSchedule: map[loaScheduleColumn.title] as String?,
      loaItemNumber: map[loaItemNumberColumn.title] as int?,
      materialTenderRate: map[materialTenderRateColumn.title] as double?,
      materialOfferedRate: map[materialOfferedRateColumn.title] as double?,
      materialOfferedPercent: map[materialOfferedPercentColumn.title] as double?,
      labourTenderRate: map[labourTenderRateColumn.title] as double?,
      labourOfferedRate: map[labourTenderRateColumn.title] as double?,
      labourOfferedPercent: map[labourTenderRateColumn.title] as double?,
    );
  }
}
