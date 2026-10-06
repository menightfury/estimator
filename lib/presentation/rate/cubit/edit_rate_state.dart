// // ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_rate_cubit.dart';

enum EditRateStatus { initial, edited, error, saving, saved, failed }

class EditRateState extends Equatable {
  const EditRateState({
    this.status = EditRateStatus.initial,
    this.id,
    //     this.accountId,
    //     this.accountError,
    //     this.qnty,
    //     this.qntyError,
    //     this.rate,
    //     this.rateError,
    //     required this.totalAmount,
    //     this.totalAmountError,
    //     this.autoAmount = true,
    //     this.type = RateType.invested,
    //     this.genre = AmcGenre.mf,
    //     this.date,
    //     this.dateError,
    //     this.amc,
    //     this.amcError,
    //     this.notes,
  });

  final EditRateStatus status;
  final String? id;
  //   final int? accountId;
  //   final String? accountError;
  //   final double? qnty;
  //   final String? qntyError;
  //   final double? rate;
  //   final String? rateError;
  //   final double? totalAmount;
  //   final String? totalAmountError;
  //   final bool autoAmount;
  //   final RateType type;
  //   final AmcGenre genre;
  //   final DateTime? date;
  //   final String? dateError;
  //   final InveslyAmc? amc;
  //   final String? amcError;
  //   final String? notes;

  bool get isNewRate => id == null;

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
    int? accountId,
    //     String? Function()? accountError,
    //     double? qnty,
    //     String? Function()? qntyError,
    //     double? rate,
    //     String? Function()? rateError,
    //     double? totalAmount,
    //     String? Function()? totalAmountError,
    //     bool? autoAmount,
    //     RateType? type,
    //     AmcGenre? genre,
    //     DateTime? date,
    //     String? Function()? dateError,
    //     InveslyAmc? Function()? amc,
    //     String? Function()? amcError,
    //     String? notes,
  }) {
    return EditRateState(
      status: status ?? this.status,
      id: id,
      //       accountId: accountId ?? this.accountId,
      //       accountError: accountError != null ? accountError() : this.accountError, // Allows resetting to null
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
      //       date: date ?? this.date,
      //       dateError: dateError != null ? dateError() : this.dateError, // Allows resetting to null
      //       amc: amc != null ? amc() : this.amc, // Allows resetting to null
      //       amcError: amcError != null ? amcError() : this.amcError, // Allows resetting to null
      //       notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    //     accountId,
    //     accountError,
    //     qnty,
    //     qntyError,
    //     rate,
    //     rateError,
    //     totalAmount,
    //     totalAmountError,
    //     autoAmount,
    //     type,
    //     genre,
    //     date,
    //     dateError,
    //     amc,
    //     amcError,
    //     notes,
  ];
}

extension EditRateStateX on EditRateState {
  bool get isError => status == EditRateStatus.error;
  bool get isEdited => [EditRateStatus.edited, EditRateStatus.error].contains(status);
  bool get isLoadingOrSuccess => [EditRateStatus.saving, EditRateStatus.saved].contains(status);
  bool get isFailureOrSuccess => [EditRateStatus.failed, EditRateStatus.saved].contains(status);
}
