import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/loa_model.dart';

part 'edit_rate_state.dart';

class EditRateCubit extends Cubit<EditRateState> {
  EditRateCubit({
    required this._repository,
    //     InveslyRate? initialRate,
    //     int? initialAccountId,
    //     InveslyAmc? initialAmc,
  }) : super(
         EditRateState(
           //  id: initialRate?.id,
           //            accountId: initialRate?.accountId ?? initialAccountId,
           //            qnty: initialRate?.quantity,
           //            rate: initialRate?.rate,
           //            totalAmount: initialRate?.totalAmount,
           //            autoAmount: [AmcGenre.mf, AmcGenre.stock].contains(initialRate?.amc.genre ?? AmcGenre.mf),
           //            type: (initialRate?.totalAmount.isNegative ?? false)
           //                ? (initialRate?.quantity?.isZero ?? true)
           //                      ? RateType.dividend
           //                      : RateType.redeemed
           //                : RateType.invested,
           //            genre: initialRate?.amc.genre ?? AmcGenre.mf,
           //            date: initialRate?.investedOn ?? DateTime.now().startOfDay,
           //            amc: initialRate?.amc ?? initialAmc,
           //            notes: initialRate?.note,
         ),
       );

  final EstimatorRepository _repository;

  void getRatesOfLoa(EstimatorLoa loa) async {
    emit(state.copyWith(status: EditRateStatus.loading));

    try {
      final rates = await _repository.getRatesOfLoa(loa.id);

      emit(
        state.copyWith(
          status: EditRateStatus.loaded,
          loaId: loa.id,
          loaNumber: loa.number,
          date: loa.date,
          rebate: () => loa.rebate,
        ),
      );
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditRateStatus.errorLoading));
    }
  }

  //   void updateAccount(int accountId) {
  //     if (accountId.isNegative || accountId.isInfinite || accountId.isNaN) {
  //       emit(state.copyWith(accountError: () => 'Invalid account'));
  //       return;
  //     }

  //     emit(state.copyWith(status: EditRateStatus.edited, accountId: accountId, accountError: () => null));
  //   }

  //   void updateAmc(InveslyAmc amc) {
  //     emit(state.copyWith(status: EditRateStatus.edited, amc: () => amc, amcError: () => null));
  //   }

  //   void resetAmc() {
  //     emit(state.copyWith(status: EditRateStatus.edited, amc: () => null));
  //   }

  //   void updateRateType(RateType type) {
  //     emit(state.copyWith(type: type));
  //   }

  //   // void updateGenre(AmcGenre genre) {
  //   //   emit(state.copyWith(genre: genre));
  //   // }

  //   void updateDate(DateTime date) {
  //     emit(state.copyWith(status: EditRateStatus.edited, date: date));
  //   }

  //   void updateRate(double rate) {
  //     if (rate.isNegative || rate.isInfinite || rate.isNaN) {
  //       emit(state.copyWith(rateError: () => 'Invalid rate', totalAmountError: () => 'Invalid amount'));
  //       return;
  //     }

  //     emit(
  //       state.copyWith(
  //         status: EditRateStatus.edited,
  //         rate: rate,
  //         totalAmount: state.canEditAmount ? null : rate * (state.qnty ?? 0.0),
  //         rateError: () => null,
  //         totalAmountError: () => null,
  //       ),
  //     );
  //   }

  //   void updateQuantity(double qnty) {
  //     if (qnty.isNegative || qnty.isInfinite || qnty.isNaN) {
  //       emit(state.copyWith(qntyError: () => 'Invalid quantity', totalAmountError: () => 'Invalid amount'));
  //       return;
  //     }

  //     emit(
  //       state.copyWith(
  //         status: EditRateStatus.edited,
  //         qnty: qnty,
  //         totalAmount: state.canEditAmount ? null : qnty * (state.rate ?? 0.0),
  //         qntyError: () => null,
  //         totalAmountError: () => null,
  //       ),
  //     );
  //   }

  //   void updateAmount(double amount) {
  //     if (amount.isNegative || amount.isInfinite || amount.isNaN) {
  //       emit(state.copyWith(totalAmountError: () => 'Invalid amount'));
  //       return;
  //     }

  //     if (amount.isZero) {
  //       emit(state.copyWith(totalAmountError: () => 'Amount can\'t be zero'));
  //       return;
  //     }

  //     emit(state.copyWith(status: EditRateStatus.edited, totalAmount: amount, totalAmountError: () => null));
  //   }

  //   void updateAutoAmountMode(bool value) {
  //     emit(state.copyWith(autoAmount: value, totalAmount: value ? (state.rate ?? 0.0) * (state.qnty ?? 0.0) : null));
  //   }

  //   void updateNotes(String notes) {
  //     emit(state.copyWith(status: EditRateStatus.edited, notes: notes));
  //   }

  //   Future<void> save() async {
  //     emit(state.copyWith(status: EditRateStatus.saving));

  //     final accountError = state.isAccountValid ? null : state.accountError ?? 'Valid account is required';
  //     final amcError = state.isAmcValid ? null : state.amcError ?? 'AMC is required';
  //     final rateError = state.isRateValid ? null : state.rateError ?? 'Rate is required';
  //     final qntyError = state.isQntyValid ? null : state.qntyError ?? 'Quantity is required';
  //     final totalAmountError = state.isTotalAmountValid ? null : state.totalAmountError ?? 'Amount is required';

  //     if (!state.isFormValid) {
  //       emit(
  //         state.copyWith(
  //           status: EditRateStatus.error,
  //           accountError: () => accountError,
  //           amcError: () => amcError,
  //           rateError: () => rateError,
  //           qntyError: () => qntyError,
  //           totalAmountError: () => totalAmountError,
  //         ),
  //       );
  //       return;
  //     }

  //     final trn = RateInDb(
  //       id: state.id ?? 0,
  //       accountId: state.accountId!,
  //       amcId: state.amc!.id,
  //       quantity: state.canEditRateAndQnty ? state.qnty ?? 0.0 : 0.0,
  //       rate: state.canEditRateAndQnty ? state.rate ?? 0.0 : 0.0,
  //       totalAmount: state.type == RateType.invested ? state.totalAmount!.abs() : -state.totalAmount!.abs(),
  //       date: (state.date ?? DateTime.now().startOfDay).millisecondsSinceEpoch,
  //       note: state.notes,
  //     );

  //     try {
  //       await _repository.saveRate(trn, state.isNewRate);
  //       emit(state.copyWith(status: EditRateStatus.saved));
  //     } on Exception catch (e) {
  //       $logger.e(e);
  //       emit(state.copyWith(status: EditRateStatus.failed));
  //     }
  //   }
}
