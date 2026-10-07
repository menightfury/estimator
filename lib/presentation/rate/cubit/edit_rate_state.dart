// // ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_rate_cubit.dart';

enum EditRateStatus { initial, loading, loaded, errorLoading, edited, saving, saved, errorSaving }

class EditRateState extends Equatable {
  const EditRateState({
    this.status = EditRateStatus.initial,
    this.loaId,
    this.loaNumber,
    //     this.qnty,
    //     this.qntyError,
    //     this.rate,
    //     this.rateError,
    //     required this.totalAmount,
    //     this.totalAmountError,
    //     this.autoAmount = true,
    //     this.type = RateType.invested,
    //     this.genre = AmcGenre.mf,
    this.date,
    this.rebate,
    //     this.dateError,
    //     this.amc,
    //     this.amcError,
    //     this.notes,
  });

  final EditRateStatus status;
  // final String? id;
  final String? loaId;
  final String? loaNumber;
  //   final double? qnty;
  //   final String? qntyError;
  //   final double? rate;
  //   final String? rateError;
  //   final double? totalAmount;
  //   final String? totalAmountError;
  //   final bool autoAmount;
  //   final RateType type;
  //   final AmcGenre genre;
  final DateTime? date;
  final double? rebate;
  //   final String? dateError;
  //   final InveslyAmc? amc;
  //   final String? amcError;
  //   final String? notes;

  bool get isNewRate => loaId == null;

  //   bool get isAccountValid {
  //     if (accountId == null || accountError != null) return false;
  //     return !(accountId!.isNegative || accountId!.isInfinite || accountId!.isNaN);
  //   }

  //   bool get isDateValid => date != null && dateError == null;

  //   bool get isAmcValid => amc != null && amcError == null;

  //   bool get isRateValid => rate != null && rateError == null;

  //   bool get isQntyValid => qnty != null && qntyError == null;

  //   bool get isTotalAmountValid => totalAmount != null && totalAmountError == null;

  //   // Check if all required fields are filled and valid
  //   bool get isFormValid {
  //     return isAccountValid && isQntyValid && isRateValid && isDateValid && isAmcValid && isTotalAmountValid;
  //   }

  //   // check if unit rate and quantity fields can be edited
  //   bool get canEditRateAndQnty => [AmcGenre.stock, AmcGenre.mf].contains(genre);

  //   // check if total amount field can be edited
  //   bool get canEditAmount => !autoAmount || !canEditRateAndQnty;

  EditRateState copyWith({
    EditRateStatus? status,
    String? loaId,
    String? loaNumber,
    //     double? qnty,
    //     String? Function()? qntyError,
    //     double? rate,
    //     String? Function()? rateError,
    //     double? totalAmount,
    //     String? Function()? totalAmountError,
    //     bool? autoAmount,
    //     RateType? type,
    //     AmcGenre? genre,
    DateTime? date,
    double? Function()? rebate,
    //     String? Function()? dateError,
    //     InveslyAmc? Function()? amc,
    //     String? Function()? amcError,
    //     String? notes,
  }) {
    return EditRateState(
      status: status ?? this.status,
      // id: id,
      loaId: loaId ?? this.loaId,
      loaNumber: loaNumber ?? this.loaNumber,
      //       qnty: qnty ?? this.qnty,
      //       qntyError: qntyError != null ? qntyError() : this.qntyError, // Allows resetting to null
      //       rate: rate ?? this.rate,
      //       rateError: rateError != null ? rateError() : this.rateError, // Allows resetting to null
      //       totalAmount: totalAmount ?? this.totalAmount,
      //       totalAmountError: totalAmountError != null
      //           ? totalAmountError()
      //           : this.totalAmountError, // Allows resetting to null
      //       autoAmount: autoAmount ?? this.autoAmount,
      //       type: type ?? this.type,
      //       genre: genre ?? this.genre,
      date: date ?? this.date,
      rebate: rebate != null ? rebate() : this.rebate, // Allows resetting to null
      //       dateError: dateError != null ? dateError() : this.dateError, // Allows resetting to null
      //       amc: amc != null ? amc() : this.amc, // Allows resetting to null
      //       amcError: amcError != null ? amcError() : this.amcError, // Allows resetting to null
      //       notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    // id,
    loaId,
    loaNumber,
    //     qnty,
    //     qntyError,
    //     rate,
    //     rateError,
    //     totalAmount,
    //     totalAmountError,
    //     autoAmount,
    //     type,
    //     genre,
    date,
    rebate,
    //     dateError,
    //     amc,
    //     amcError,
    //     notes,
  ];
}

extension EditRateStateX on EditRateState {
  bool get isError => status == EditRateStatus.errorLoading;
  bool get isEdited => [EditRateStatus.edited, EditRateStatus.errorLoading].contains(status);
  bool get isLoadingOrSuccess => [EditRateStatus.saving, EditRateStatus.saved].contains(status);
  bool get isFailureOrSuccess => [EditRateStatus.errorSaving, EditRateStatus.saved].contains(status);
}
