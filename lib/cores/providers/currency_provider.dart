import 'package:flutter/material.dart';
import 'package:expense_personal/cores/services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();
  String _currency = 'VND';
  double _exchangeRate = 1.0;
  Map<String, double>? _rates;

  String get currency => _currency;
  double get exchangeRate => _exchangeRate;
  Map<String, double>? get rates => _rates;

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _updateExchangeRate();
    notifyListeners();
  }

  Future<void> _updateExchangeRate() async {
    try {
      final rates = await _currencyService.getExchangeRates('VND');

      _rates = (rates['conversion_rates'] as Map<String, dynamic>)
          .map<String, double>((key, value) => MapEntry(key.toString(), (value as num).toDouble()));

      _exchangeRate = _rates?[_currency] ?? 1.0;
    } catch (e) {
      print('Error updating exchange rate: $e');
      _exchangeRate = 1.0;
    }
  }

  double convert(double amount) {
    return amount * _exchangeRate;
  }

  Future<void> initialize() async {
    await _updateExchangeRate();
  }
}
