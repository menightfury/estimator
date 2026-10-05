import 'package:estimator/database/table_schema.dart';

class LoaInDb extends TableDataModel {
  const LoaInDb({required this.id, required this.number, required this.date, this.rebate});

  final String id;
  final String number;
  final int date;
  final double? rebate;

  @override
  List<Object?> get props => [id, number, date, rebate];
}

class EstimatorLoa extends LoaInDb {
  const EstimatorLoa({required super.id, required super.number, required super.date, super.rebate});

  factory EstimatorLoa.fromDb(LoaInDb loa) {
    return EstimatorLoa(id: loa.id, number: loa.number, date: loa.date, rebate: loa.rebate);
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
      dateColumn.title: loa.date,
      rebateColumn.title: loa.rebate,
    };
  }

  @override
  LoaInDb fromMap(Map<String, dynamic> map) {
    return LoaInDb(
      id: map[idColumn.title] as String,
      number: map[numberColumn.title] as String,
      date: map[dateColumn.title] as int,
      rebate: map[rebateColumn.title] as double?,
    );
  }
}
