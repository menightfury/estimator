import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:estimator/common_libs.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';
import 'package:estimator/model/rate_model.dart';

import 'table_schema.dart';

class EstimatorSqliteApi {
  // preventing from calling the class
  EstimatorSqliteApi._() : _tableEventController = StreamController<TableEvent>.broadcast();

  final StreamController<TableEvent> _tableEventController;

  static EstimatorSqliteApi? _instance;
  static EstimatorSqliteApi get instance {
    assert(_instance != null, 'No instance found, please make sure to call initialize() before getting instance');
    return _instance!;
  }

  static const _dbName = 'estimator_master.db';

  Database? _db;
  Database get db {
    assert(_db != null, 'Please make sure to call initialize() before getting database');
    return _db!;
  }

  final List<TableSchema> _tables = [];

  // Stream of TableChangeEvent
  Stream<TableEvent> get onTableChange => _tableEventController.stream;

  static Future<EstimatorSqliteApi> initialize(Directory dbDirectory) async {
    final dbPath = p.join(dbDirectory.path, _dbName);
    final tables = <TableSchema>[ItemTable(), LoaTable(), RateTable()];

    _instance = EstimatorSqliteApi._();
    instance._db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          final batch = db.batch();

          // initialize all necessary tables in database
          for (final table in tables) {
            batch.execute(table.createTableSql);
          }

          await batch.commit(noResult: true, continueOnError: true);
        },
      ),
    );

    // ?? Close database at the end ??
    instance._tables.addAll(tables);

    return instance;
  }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() {
    return _tables.firstWhereOrNull((table) => table is T) as T?;
  }

  // Table getters
  ItemTable? get itemTable => getTable<ItemTable>();
  LoaTable? get loaTable => getTable<LoaTable>();
  RateTable? get rateTable => getTable<RateTable>();

  Future<List<Map<String, dynamic>>> select(
    TableSchema table, {
    List<TableSchema> join = const [],
    List<TableColumnBase>? columns,
    List<TableColumn>? groupBy,
    TableFilter? filter,
    int? limit,
    Map<TableColumn, bool>? orderBy,
  }) async {
    final List<Map<String, dynamic>> data = [];

    // SELECT table1.*, table2.id as table2_id FROM table1 JOIN table2 ON table1.amc_id = table2.id
    final effectiveTableName = StringBuffer(table.title);
    final defaultTableColumns = List<TableColumnBase>.from(table.columns);

    if (join.isNotEmpty && table.foreignKeys.isNotEmpty) {
      for (final j in join) {
        // get foreignKey
        final fkc = table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == j.title);
        if (fkc == null) continue;
        // Write table name
        effectiveTableName.write(' JOIN ${j.title} ');
        effectiveTableName.write('ON ${fkc.fullTitle} = ${j.title}.${fkc.foreignReference!.columnName}');

        // Write default table columns
        final jColumns = j.columns.map<TableColumnBase>((col) {
          return col.alias('${j.type.toString().toCamelCase()}_${col.title}');
        });
        defaultTableColumns.addAll(jColumns);
      }
    }

    final whereClause = filter?.toSql();

    // print query for debugging
    $logger.d('''SELECT ${defaultTableColumns.map((col) => col.fullTitleWithAggregateAndAlias).join(', ')}
       FROM $effectiveTableName
       ${whereClause != null ? 'WHERE ${whereClause.$1}' : ''}
       ${groupBy != null ? 'GROUP BY ${groupBy.map((col) => col.fullTitle).join(', ')}' : ''}
       ${limit != null ? 'LIMIT $limit' : ''}''');

    try {
      final list = await db.query(
        effectiveTableName.toString(),
        columns: (columns ?? defaultTableColumns).map<String>((col) => col.fullTitleWithAggregateAndAlias).toList(),
        where: whereClause?.$1,
        whereArgs: whereClause?.$2,
        limit: limit,
        groupBy: groupBy?.map<String>((col) => col.fullTitle).join(', '),
        orderBy: orderBy?.entries.map<String>((col) => '${col.key.fullTitle} ${col.value ? 'DESC' : 'ASC'}').join(', '),
      );

      if (list.isEmpty) return List<Map<String, dynamic>>.empty();

      for (final el in list) {
        final map = Map<String, dynamic>.from(el);
        if (join.isNotEmpty && table.foreignKeys.isNotEmpty) {
          for (final j in join) {
            final fkc = table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == j.title);
            if (fkc == null) continue;
            map.nest(j.type.toString().toCamelCase());
          }
        }
        data.add(map);
      }
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
    return data;
  }

  Future<int> insert(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    for (final pkc in table.primaryKeys) {
      if (pkc.isAutoIncrement) {
        values.remove(pkc.title);
      }
    }
    final r = await db.insert(table.title, values);
    _tableEventController.add(TableEvent(table, TableEventType.insert, data));
    return r;
  }

  Future<int> update(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    final where = <String>[];
    final whereArgs = <Object>[];
    for (final pkc in table.primaryKeys) {
      where.add('${pkc.fullTitle} = ?');
      whereArgs.add(values.remove(pkc.title));
    }

    final r = await db.update(table.title, values, where: where.join(' AND '), whereArgs: whereArgs);
    _tableEventController.add(TableEvent(table, TableEventType.update, data));
    return r;
  }

  Future<int> delete(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    final where = <String>[];
    final whereArgs = <Object>[];
    for (final pkc in table.primaryKeys) {
      where.add('${pkc.fullTitle} = ?');
      whereArgs.add(values.remove(pkc.title));
    }
    final r = await db.delete(table.title, where: where.join(' AND '), whereArgs: whereArgs);
    _tableEventController.add(TableEvent(table, TableEventType.delete, data));
    return r;
  }

  Future<void> close() async {
    await _db?.close();
    await _tableEventController.close();
  }
}
