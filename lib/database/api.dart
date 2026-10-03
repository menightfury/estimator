import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:estimator/common_libs.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';
import 'package:estimator/model/rate_model.dart';

import 'table_schema.dart';

class EstimatorApi {
  final Directory databaseDirectory;
  final StreamController<TableEvent> _tableEventController;

  EstimatorApi(this.databaseDirectory) : _tableEventController = StreamController<TableEvent>.broadcast();

  Database? _db;
  Database get db {
    assert(_db != null, 'Please make sure to initialize before getting database');
    return _db!;
  }

  static const _dbName = 'estimator_master.db';

  final List<TableSchema> _tables = [];

  // Stream of TableChangeEvent
  Stream<TableEvent> get onTableChange => _tableEventController.stream;

  String get dbPath => p.join(databaseDirectory.path, _dbName);

  // define all necessary tables
  final _itemTable = ItemTable();
  final _loaTable = LoaTable();
  final _rateTable = RateTable();

  // Table getters
  ItemTable get accountTable => _itemTable;
  LoaTable get amcTable => _loaTable;
  RateTable get trnTable => _rateTable;

  Future<void> initializeDatabase() async {
    final tables = <TableSchema>[_itemTable, _loaTable, _rateTable];
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        final batch = db.batch();

        // initialize all necessary tables in database
        for (final table in tables) {
          batch.execute(table.createTableSql);
        }

        // create triggers for automatic stats updates (dynamically generated)
        // batch.execute(
        //   _rateTable.createTrigger(
        //     eventType: TableEventType.insert,
        //     operation: _buildTriggerOperation(TableEventType.insert),
        //   ),
        // );
        // batch.execute(
        //   _rateTable.createTrigger(
        //     eventType: TableEventType.update,
        //     operation: _buildTriggerOperation(TableEventType.update),
        //   ),
        // );
        // batch.execute(
        //   _rateTable.createTrigger(
        //     eventType: TableEventType.delete,
        //     operation: _buildTriggerOperation(TableEventType.delete),
        //   ),
        // );

        await batch.commit(noResult: true, continueOnError: true);
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   $logger.w('===== upgrading database ======');
      //   if (oldVersion < 7) {
      //     await _migrateAccountsToNewModel(db);
      //   }
      // },
    );
    // if (_db != null) {
    //   final version = await _db!.rawQuery('PRAGMA user_version');
    //   $logger.w(version);
    // }

    // ?? Close database at the end ??
    _tables.addAll(tables);
  }

  // Future<void> _migrateAccountsToNewModel(Database db) async {
  //   final accountTable = _itemTable;
  //   final columns = await db.rawQuery('PRAGMA table_info(${accountTable.title})');
  //   final existingColumns = columns.map((column) => column['name'] as String).toSet();
  //   final newColumns = _itemTable.columns.map((column) => column.title).toSet();
  //   final commonColumns = existingColumns.intersection(newColumns);

  //   if (commonColumns.isEmpty) {
  //     await db.execute(accountTable.createTableSql);
  //     return;
  //   }

  //   final batch = db.batch();
  //   batch.execute('PRAGMA foreign_keys = OFF');
  //   batch.execute('ALTER TABLE ${accountTable.title} RENAME TO sqliteinvesly_temp_table');
  //   batch.execute(accountTable.createTableSql);

  //   final columnList = commonColumns.join(', ');
  //   batch.execute('INSERT INTO ${accountTable.title} ($columnList) SELECT $columnList FROM sqliteinvesly_temp_table');

  //   batch.execute('DROP TABLE sqliteinvesly_temp_table');
  //   batch.execute('PRAGMA foreign_keys = ON');

  //   await batch.commit(noResult: true, continueOnError: true);
  // }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => _tables.firstWhereOrNull((table) => table is T) as T?;

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
