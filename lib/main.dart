import 'package:expense_tracker/src/injector.dart' as di;
import 'package:expense_tracker/src/presentation/screens/add_expense/screen/add_expense_screen.dart';
import 'package:expense_tracker/src/presentation/screens/dashboard/screen/dashboard_screen.dart';
import 'package:expense_tracker/src/presentation/screens/login/controller/cubit.dart';
import 'package:expense_tracker/src/presentation/screens/login/controller/state.dart';
import 'package:expense_tracker/src/presentation/screens/login/login_screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // This now handles both Hive initialization AND adapter registration
    await di.init();
    print('✅ App initialization completed');
  } catch (e) {
    print('❌ App initialization failed: $e');
    // You can show an error screen or handle this gracefully
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          return di.sl<AuthCubit>()..checkAuthStatus();
        } catch (e) {
          print('❌ Error creating AuthCubit: $e');
          // Return a fallback or handle the error
          rethrow;
        }
      },
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF6C5CE7),
          fontFamily: 'Inter',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        ),
        home: const AuthWrapper(),
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          DashboardScreen.routeName: (context) => const DashboardScreen(),
          AddExpenseScreen.routeName: (context) => const AddExpenseScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          try {
            di.sl.setCurrentUser(state.user.id);
            print('✅ Current user set: ${state.user.id}');
          } catch (e) {
            print('❌ Error setting current user: $e');
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C5CE7),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
