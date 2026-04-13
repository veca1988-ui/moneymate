import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required String userId,
    required String visibility,
    required DateTime createdAt,
    @Default('') String note,
    @Default('') String userName,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  factory Expense.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Expense.fromJson({
      'id': doc.id,
      ...data,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

extension ExpenseFirestore on Expense {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['date'] = Timestamp.fromDate(date);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
