import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatDateTime {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'ar');
    return formatter.format(this);
  }
}

extension DoubleExtensions on double {
  String get formatCurrency {
    final formatter = NumberFormat.currency(locale: 'ar_SA', symbol: 'ر.س');
    return formatter.format(this);
  }
}