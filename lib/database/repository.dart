import 'dart:async';

import 'package:estimator/common_libs.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';
import 'package:estimator/model/rate_model.dart';

import 'api.dart';
import 'table_schema.dart';

class EstimatorRepository {
  // singleton api instance
  static EstimatorRepository? _instance;
  static EstimatorRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory EstimatorRepository.initialize(EstimatorApi api) {
    _instance ??= EstimatorRepository._(api);
    return _instance!;
  }
  const EstimatorRepository._(this._api);

  final EstimatorApi _api;

  // ~ Items related
  Future<List<EstimatorItem>> searchItems(String query) async {
    final searchTerm = query.trim();
    if (searchTerm.isEmpty) return const [];

    final table = _api.itemTable;
    final results = await _api.select(
      table,
      filter: SingleValueTableFilter<String>(table.nameColumn, searchTerm, operator: FilterOperator.like),
      orderBy: {table.nameColumn: false},
    );

    return results.map((map) => EstimatorItem.fromDb(table.fromMap(map))).toList();
  }

  Future<EstimatorItem?> getItem(String id) async {
    final table = _api.itemTable;
    final results = await _api.select(table, filter: SingleValueTableFilter<String>(table.idColumn, id));

    if (results.isEmpty) return null;

    return EstimatorItem.fromDb(table.fromMap(results.first));
  }

  // ~ LOA related
  Future<List<EstimatorLoa>> searchLoas(String query) async {
    final searchTerm = query.trim();
    if (searchTerm.isEmpty) return const [];

    final table = _api.loaTable;
    final results = await _api.select(
      table,
      filter: SingleValueTableFilter<String>(table.numberColumn, searchTerm, operator: FilterOperator.like),
      orderBy: {table.numberColumn: false},
    );

    return results.map((map) => EstimatorLoa.fromDb(table.fromMap(map))).toList();
  }

  Future<EstimatorLoa?> getLoa(String id) async {
    final table = _api.loaTable;
    final results = await _api.select(table, filter: SingleValueTableFilter<String>(table.idColumn, id));

    if (results.isEmpty) return null;

    return EstimatorLoa.fromDb(table.fromMap(results.first));
  }

  // ~ Rate related
  Future<List<EstimatorRate>> getRatesOfItem(String itemId) async {
    final rateTable = _api.rateTable;
    final itemTable = _api.itemTable;
    final loaTable = _api.loaTable;

    late final List<EstimatorRate> rates;
    try {
      final result = await _api.select(
        rateTable,
        join: [itemTable, loaTable],
        filter: SingleValueTableFilter<String>(rateTable.itemIdColumn, itemId),
        orderBy: {loaTable.dateColumn: true},
      );

      if (result.isEmpty) return List<EstimatorRate>.empty();

      rates = result.map<EstimatorRate>((map) {
        return EstimatorRate.fromDb(
          rateTable.fromMap(map),
          itemTable.fromMap(map[itemTable.type.toString().toCamelCase()] as Map<String, dynamic>),
          loaTable.fromMap(map[loaTable.type.toString().toCamelCase()] as Map<String, dynamic>),
        );
      }).toList();
    } on Exception catch (err) {
      $logger.e(err);
      rates = List<EstimatorRate>.empty();
    }

    return rates;
  }

  Future<List<EstimatorRate>> getRatesOfLoa(String loaId) async {
    final rateTable = _api.rateTable;
    final itemTable = _api.itemTable;
    final loaTable = _api.loaTable;

    late final List<EstimatorRate> rates;
    try {
      final result = await _api.select(
        rateTable,
        join: [itemTable, loaTable],
        filter: SingleValueTableFilter<String>(rateTable.loaIdColumn, loaId),
        orderBy: {loaTable.dateColumn: true},
      );

      if (result.isEmpty) return List<EstimatorRate>.empty();

      rates = result.map<EstimatorRate>((map) {
        return EstimatorRate.fromDb(
          rateTable.fromMap(map),
          itemTable.fromMap(map[itemTable.type.toString().toCamelCase()] as Map<String, dynamic>),
          loaTable.fromMap(map[loaTable.type.toString().toCamelCase()] as Map<String, dynamic>),
        );
      }).toList();
    } on Exception catch (err) {
      $logger.e(err);
      rates = List<EstimatorRate>.empty();
    }

    return rates;
  }

  // Stream<TableEvent> get onDataChanged {
  //   return _api.onTableChange.where((event) => event.table == _trnTable);
  // }

  // /// Get transactions
  // Future<List<InveslyTransaction>> getTransactions({
  //   int? accountId,
  //   AmcGenre? genre,
  //   String? amcId,
  //   DateTimeRange? dateRange,
  //   int? limit,
  //   bool descendingOrder = true,
  // }) async {
  //   final filters = <TableFilter>[];
  //   if (accountId != null) {
  //     filters.add(SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId));
  //   }

  //   if (genre != null) {
  //     filters.add(SingleValueTableFilter<String>(_amcTable.genreColumn, genre.name));
  //   }

  //   if (amcId != null) {
  //     filters.add(SingleValueTableFilter<String>(_trnTable.amcIdColumn, amcId));
  //   }

  //   if (dateRange != null) {
  //     filters.add(
  //       RangeValueTableFilter(
  //         _trnTable.dateColumn,
  //         dateRange.start.millisecondsSinceEpoch,
  //         dateRange.end.millisecondsSinceEpoch,
  //       ),
  //     );
  //   }

  //   late final List<InveslyTransaction> transactions;
  //   try {
  //     final result = await _api.select(
  //       _trnTable,
  //       join: [_accountTable, _amcTable],
  //       filter: filters.isEmpty ? null : TableFilterGroup(filters),
  //       limit: limit,
  //       orderBy: {_trnTable.dateColumn: true},
  //     );

  //     if (result.isEmpty) return List<InveslyTransaction>.empty();

  //     transactions = result.map<InveslyTransaction>((map) {
  //       return InveslyTransaction.fromDb(
  //         _trnTable.fromMap(map),
  //         _accountTable.fromMap(map[_accountTable.type.toString().toCamelCase()] as Map<String, dynamic>),
  //         _amcTable.fromMap(map[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
  //       );
  //     }).toList();
  //   } on Exception catch (err) {
  //     $logger.e(err);
  //     transactions = List<InveslyTransaction>.empty();
  //   }

  //   return transactions;
  // }

  // /// Add or update a transaction
  // Future<void> saveTransaction(TransactionInDb transaction, [bool isNew = true]) async {
  //   if (isNew) {
  //     await _api.insert(_trnTable, transaction);
  //   } else {
  //     await _api.update(_trnTable, transaction);
  //   }
  // }

  // /// Insert multiple transaction at once
  // Future<void> insertTransactions(List<TransactionInDb> transactions) async {
  //   final batch = _api.db.batch();
  //   // ignore: avoid_function_literals_in_foreach_calls
  //   transactions.forEach((trn) => batch.insert(_trnTable.title, _trnTable.fromModel(trn)));

  //   await batch.commit(noResult: true, continueOnError: true);
  // }

  // Future<String> transactionsToCsv([String separator = ',']) async {
  //   final csvHeader = _trnTable.columns.map((col) => col.title.toCamelCase()).toList();
  //   final transactions = await getTransactions();

  //   final csvData = transactions.map((trn) => _trnTable.fromModel(trn).values.toList()).toList();

  //   // return const ListToCsvConverter().convert([csvHeader, ...csvData], fieldDelimiter: separator);
  //   return Csv(fieldDelimiter: separator).encode([csvHeader, ...csvData]);
  // }
}
