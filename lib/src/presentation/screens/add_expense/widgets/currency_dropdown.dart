import 'package:flutter/material.dart';
import '../../../../core/constants/currency_constants.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final Function(String) onCurrencySelected;

  const CurrencyDropdown({
    Key? key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCurrency,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF718096),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => CurrencyPickerSheet(
          selectedCurrency: selectedCurrency,
          currencies: currencies,
          onCurrencySelected: (currency) {
            onCurrencySelected(currency);
            Navigator.of(context).pop();
          },
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class CurrencyPickerSheet extends StatefulWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final Function(String) onCurrencySelected;
  final ScrollController scrollController;

  const CurrencyPickerSheet({
    Key? key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = widget.currencies;
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCurrencies);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = widget.currencies;
      } else {
        _filteredCurrencies = widget.currencies.where((currency) {
          final currencyName = CurrencyConstants.getCurrencyName(currency).toLowerCase();
          return currency.toLowerCase().contains(query) ||
                 currencyName.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group currencies: popular first, then others
    final popularCurrencies = CurrencyConstants.popularCurrencies
        .where((currency) => _filteredCurrencies.contains(currency))
        .toList();
    
    final otherCurrencies = _filteredCurrencies
        .where((currency) => !CurrencyConstants.popularCurrencies.contains(currency))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Select Currency',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search currencies...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF718096)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Currency List
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // Popular Currencies
                if (popularCurrencies.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Popular Currencies',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                  ...popularCurrencies.map((currency) => _buildCurrencyItem(currency)),
                  const SizedBox(height: 20),
                ],
                
                // Other Currencies
                if (otherCurrencies.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'All Currencies',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                  ...otherCurrencies.map((currency) => _buildCurrencyItem(currency)),
                ],
                
                // No Results
                if (_filteredCurrencies.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Color(0xFFCBD5E0),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(String currency) {
    final isSelected = currency == widget.selectedCurrency;
    final symbol = CurrencyConstants.getCurrencySymbol(currency);
    final name = CurrencyConstants.getCurrencyName(currency);
    
    return GestureDetector(
      onTap: () => widget.onCurrencySelected(currency),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6C5CE7).withOpacity(0.1) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6C5CE7) 
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Currency Symbol
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF6C5CE7) 
                    : const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? const Color(0xFF6C5CE7) 
                          : const Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selected Indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}