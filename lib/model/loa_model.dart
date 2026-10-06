import 'package:estimator/database/table_schema.dart';

class LoaInDb extends TableDataModel {
  const LoaInDb({required this.id, required this.number, required this.dateInt, this.rebate});

  final String id;
  final String number;
  final int dateInt;
  final double? rebate;

  @override
  List<Object?> get props => [id, number, dateInt, rebate];
}

class EstimatorLoa extends LoaInDb {
  EstimatorLoa({required super.id, required super.number, required this.date, super.rebate})
    : super(dateInt: (date.millisecondsSinceEpoch / 1_000).round());

  final DateTime date;

  factory EstimatorLoa.fromDb(LoaInDb loa) {
    return EstimatorLoa(
      id: loa.id,
      number: loa.number,
      date: DateTime.fromMillisecondsSinceEpoch(loa.dateInt * 1_000),
      rebate: loa.rebate,
    );
  }
}

class LoaTable extends TableSchema<LoaInDb> {
  // Singleton pattern to ensure only one instance exists
  const LoaTable._() : super('loas');
  static const instance = LoaTable._();
  factory LoaTable() => instance;

  TableColumn<String> get idColumn => TableColumn<String>('id', title, isPrimary: true);
  TableColumn<String> get numberColumn => TableColumn<String>('number', title, isUnique: true);
  TableColumn<int> get dateColumn => TableColumn<int>('date', title);
  TableColumn<double> get rebateColumn => TableColumn<double>('rebate', title, isNullable: true);

  @override
  Set<TableColumn> get columns => {idColumn, numberColumn, dateColumn, rebateColumn};

  @override
  Map<String, dynamic> fromModel(LoaInDb loa) {
    return <String, dynamic>{
      idColumn.title: loa.id,
      numberColumn.title: loa.number,
      dateColumn.title: loa.dateInt,
      rebateColumn.title: loa.rebate,
    };
  }

  @override
  LoaInDb fromMap(Map<String, dynamic> map) {
    return LoaInDb(
      id: map[idColumn.title] as String,
      number: map[numberColumn.title] as String,
      dateInt: map[dateColumn.title] as int,
      rebate: map[rebateColumn.title] as double?,
    );
  }
}
