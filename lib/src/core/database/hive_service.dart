import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/expense_model.dart';

class HiveService {
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register manual adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
  }

  static Future<void> clearAllData() async {
    try {
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('auth');
      await Hive.deleteBoxFromDisk('expenses');
      await Hive.deleteBoxFromDisk('exchange_rates');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}