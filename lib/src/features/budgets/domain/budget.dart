import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String category,
    required double limit,
    required String month,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  factory Budget.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return Budget.fromJson({
      'id': id,
      ...data,
    });
  }
}
