import 'package:expense_tracker/src/injector.dart' as di;
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controller/cubit.dart';
import '../widgets/add_expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  static const routeName = '/add-expense';

  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AddExpenseCubit>()..loadSupportedCurrencies(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Add Expense',
            style: TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<AddExpenseCubit, AddExpenseState>(
          listener: (context, state) {
            if (state is AddExpenseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense added successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true); // Return true to indicate success
            } else if (state is AddExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const SafeArea(
            child: AddExpenseForm(),
          ),
        ),
      ),
    );
  }
}
