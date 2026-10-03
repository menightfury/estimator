import 'package:estimator/database/table_schema.dart';

class RateInDb extends TableDataModel {
  const RateInDb({
    required this.id,
    required this.itemId,
    required this.loaId,
    this.loaSchedule,
    this.loaItemNumber,
    required this.tenderRate,
    this.offeredRate,
    this.offeredPercent,
  });

  final String id;
  final String itemId;
  final String loaId;
  final String? loaSchedule;
  final int? loaItemNumber;
  final double tenderRate;
  final double? offeredRate;
  final double? offeredPercent;

  @override
  List<Object?> get props => [id, itemId, loaId, loaSchedule, loaItemNumber, tenderRate, offeredRate, offeredPercent];
}

class EstimatorRate extends RateInDb {
  const EstimatorRate({
    required super.id,
    required super.itemId,
    required super.loaId,
    super.loaSchedule,
    super.loaItemNumber,
    required super.tenderRate,
    super.offeredRate,
    super.offeredPercent,
  });

  factory EstimatorRate.fromDb(RateInDb rate) {
    return EstimatorRate(
      id: rate.id,
      itemId: rate.itemId,
      loaId: rate.loaId,
      loaSchedule: rate.loaSchedule,
      loaItemNumber: rate.loaItemNumber,
      tenderRate: rate.tenderRate,
      offeredRate: rate.offeredRate,
      offeredPercent: rate.offeredPercent,
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
  TableColumn<double> get tenderRateColumn => TableColumn<double>('tender_rate', title);
  TableColumn<double> get offeredRateColumn => TableColumn<double>('offered_rate', title, isNullable: true);
  TableColumn<double> get offeredPercentColumn => TableColumn<double>('offered_percent', title, isNullable: true);

  @override
  Set<TableColumn> get columns {
    return {
      idColumn,
      itemIdColumn,
      loaIdColumn,
      loaScheduleColumn,
      loaItemNumberColumn,
      tenderRateColumn,
      offeredRateColumn,
      offeredPercentColumn,
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
      tenderRateColumn.title: rate.tenderRate,
      offeredRateColumn.title: rate.offeredRate,
      offeredPercentColumn.title: rate.offeredPercent,
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
      tenderRate: (map[tenderRateColumn.title] as num).toDouble(),
      offeredRate: map[offeredRateColumn.title] as double?,
      offeredPercent: map[offeredPercentColumn.title] as double?,
    );
  }
}
