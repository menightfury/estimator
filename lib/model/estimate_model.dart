// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/rate_model.dart';

class Estimate extends Equatable {
  const Estimate({required this.id, required this.number, required this.name, this.items = const []});

  final String id;
  final String number;
  final String name;
  final List<EstimateItem> items;

  @override
  List<Object?> get props => [id, number, name, items];
}

class EstimateItem extends Equatable {
  const EstimateItem({
    required this.id,
    required this.item,
    required this.description,
    required this.quantity,
    required this.rates,
  });

  final String id; // ItemInDb id
  final EstimatorItem item;
  final String description; // User can update description during preparation of estimate
  final double quantity;
  final List<EstimatorRate> rates;

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, item, description, quantity, rates];
}
