import 'dart:io';

import 'package:estimator/database/api.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory databaseDirectory;
  late EstimatorApi api;
  late EstimatorRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    databaseDirectory = await Directory.systemTemp.createTemp('estimator-search-test-');
    api = EstimatorApi(databaseDirectory);
    await api.initializeDatabase();
    repository = EstimatorRepository.initialize(api);

    await api.insert(
      api.itemTable,
      const ItemInDb(id: '1', name: 'Concrete Mix', description: 'Bagged mix', unit: 'bag'),
    );
    await api.insert(
      api.itemTable,
      const ItemInDb(id: '2', name: 'concrete block', description: 'Masonry unit', unit: 'each'),
    );
    await api.insert(
      api.itemTable,
      const ItemInDb(id: '3', name: 'Timber Plank', description: 'Treated timber', unit: 'length'),
    );
  });

  tearDown(() async {
    await api.close();
    await databaseDirectory.delete(recursive: true);
  });

  test('searchItems finds partial names without regard to case', () async {
    final results = await repository.searchItems('CONCRETE');

    expect(results.map((item) => item.name), containsAll(['Concrete Mix', 'concrete block']));
    expect(results, hasLength(2));
    expect(await repository.searchItems('not found'), isEmpty);
    expect(await repository.searchItems('  '), isEmpty);
  });
}
