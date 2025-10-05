// features/expenses/presentation/cubit/expense_events.dart

import 'package:new_wedding_hall/features/expenses/domain/entities/expense_entity.dart';

import 'expense_cubit.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ExpenseEvent {}

class LoadExpensesEvent extends ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseEntity expense;

  AddExpenseEvent(this.expense);
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;

  DeleteExpenseEvent(this.expenseId);
}

class ApplyFiltersEvent extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  ApplyFiltersEvent({this.startDate, this.endDate, this.category});
}

class ResetFiltersEvent extends ExpenseEvent {}

class SearchExpensesEvent extends ExpenseEvent {
  final String query;

  SearchExpensesEvent(this.query);
}

class GeneratePdfReportEvent extends ExpenseEvent {}

class UpdateProfitCalculationEvent extends ExpenseEvent {
  final double newTotalRevenue;

  UpdateProfitCalculationEvent(this.newTotalRevenue);
}
