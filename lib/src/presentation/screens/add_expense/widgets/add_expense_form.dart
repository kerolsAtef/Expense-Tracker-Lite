import 'dart:io';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/cubit.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/state.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/widgets/receipt_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/ategory_constants.dart';
import 'category_selection_grid.dart';
import 'currency_dropdown.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({Key? key}) : super(key: key);

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'groceries';
  String _selectedCategoryIcon = CategoryConstants.getCategoryIcon('groceries');
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  File? _receiptFile;

  bool _showConvertedAmount = false;
  double? _convertedAmount;
  bool _isConvertingCurrency = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onCategorySelected(String category, String icon) {
    setState(() {
      _selectedCategory = category;
      _selectedCategoryIcon = icon;
    });
  }

  void _onCurrencySelected(String currency) {
    setState(() {
      _selectedCurrency = currency;
      _showConvertedAmount = currency != 'USD';
      _convertedAmount = null;
    });
    _calculateConversion();
  }

  void _calculateConversion() async {
    if (_selectedCurrency == 'USD' || _amountController.text.isEmpty) {
      setState(() {
        _showConvertedAmount = false;
        _convertedAmount = null;
        _isConvertingCurrency = false;
      });
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _convertedAmount = null;
        _isConvertingCurrency = false;
      });
      return;
    }

    setState(() {
      _isConvertingCurrency = true;
      _showConvertedAmount = true;
    });

    try {
      // Use the AddExpenseCubit to convert currency using real exchange rates
      final convertedAmount = await context.read<AddExpenseCubit>().convertCurrency(
        amount: amount,
        fromCurrency: _selectedCurrency,
        toCurrency: 'USD',
      );

      if (mounted) {
        setState(() {
          _convertedAmount = convertedAmount;
          _isConvertingCurrency = false;
        });
      }
    } catch (e) {
      print('❌ Currency conversion failed: $e');
      if (mounted) {
        setState(() {
          _convertedAmount = null;
          _isConvertingCurrency = false;
          _showConvertedAmount = false;
        });

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency conversion failed: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _pickReceipt() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Receipt Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickFromCamera(),
                  ),
                  _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickFromGallery(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _pickFromCamera() async {
    Navigator.of(context).pop();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _receiptFile = File(image.path);
      });
    }
  }

  void _pickFromGallery() async {
    Navigator.of(context).pop();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _receiptFile = File(image.path);
      });
    }
  }

  void _removeReceipt() {
    setState(() {
      _receiptFile = null;
    });
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    context.read<AddExpenseCubit>().addExpense(
      category: _selectedCategory,
      amount: amount,
      currency: _selectedCurrency,
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      receiptPath: _receiptFile?.path,
      categoryIcon: _selectedCategoryIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            CategorySelectionGrid(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            const SizedBox(height: 24),

            // Amount Section
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Currency Dropdown
                SizedBox(
                  width: 120,
                  child: BlocBuilder<AddExpenseCubit, AddExpenseState>(
                    builder: (context, state) {
                      List<String> currencies = ['USD', 'EUR', 'GBP'];
                      if (state is CurrencyLoaded) {
                        currencies = state.currencies;
                      }

                      return CurrencyDropdown(
                        selectedCurrency: _selectedCurrency,
                        currencies: currencies,
                        onCurrencySelected: _onCurrencySelected,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Amount Input
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: (_) => _calculateConversion(),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // Converted Amount Display
            if (_showConvertedAmount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (_isConvertingCurrency)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                          ),
                        )
                      else
                        const Icon(
                          Icons.swap_horiz,
                          color: Color(0xFF6C5CE7),
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isConvertingCurrency
                            ? 'Converting...'
                            : _convertedAmount != null
                            ? 'USD ${_convertedAmount!.toStringAsFixed(2)}'
                            : 'Conversion failed',
                        style: TextStyle(
                          color: _convertedAmount != null && !_isConvertingCurrency
                              ? const Color(0xFF6C5CE7)
                              : const Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Date Section
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Attach Receipt Section
            const Text(
              'Attach Receipt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            ReceiptUploadWidget(
              receiptFile: _receiptFile,
              onPickReceipt: _pickReceipt,
              onRemoveReceipt: _removeReceipt,
            ),
            const SizedBox(height: 24),

            // Description Section (Optional)
            const Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Add a note about this expense...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<AddExpenseCubit, AddExpenseState>(
                builder: (context, state) {
                  final isLoading = state is AddExpenseLoading;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}