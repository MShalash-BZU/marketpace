import 'package:intl/intl.dart';

/// Formatters utility class for formatting different data types
class Formatters {
  // Currency Formatter
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'ر.س',
    decimalDigits: 2,
    locale: 'ar_SA',
  );

  /// Format number as currency (SAR)
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format number as currency without symbol
  static String formatCurrencyNoSymbol(double amount) {
    return NumberFormat('#,##0.00', 'ar_SA').format(amount);
  }

  // Date Formatters
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd', 'ar_SA');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'ar_SA');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm', 'ar_SA');
  static final DateFormat _fullDateFormat = DateFormat('EEEE، d MMMM yyyy', 'ar_SA');
  static final DateFormat _relativeDateFormat = DateFormat('yyyy-MM-dd', 'ar_SA');

  /// Format date as 'yyyy-MM-dd'
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time as 'HH:mm'
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format date and time as 'yyyy-MM-dd HH:mm'
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format date as full Arabic format 'EEEE، d MMMM yyyy'
  static String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format date as relative time (Today, Yesterday, or date)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'أمس';
    } else if (difference < 7) {
      return 'منذ $difference أيام';
    } else {
      return _relativeDateFormat.format(date);
    }
  }

  // Phone Formatter
  /// Format phone number as '05X XXX XXXX'
  static String formatPhoneNumber(String phone) {
    // Remove all non-digits
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 10 && digits.startsWith('05')) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    } else if (digits.length == 12 && digits.startsWith('966')) {
      final withoutCountry = digits.substring(3);
      return '${withoutCountry.substring(0, 3)} ${withoutCountry.substring(3, 6)} ${withoutCountry.substring(6)}';
    }
    return phone; // Return as is if format is unknown
  }

  // Number Formatters
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'ar_SA');

  /// Format number with thousand separators
  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }

  /// Format number with decimal places
  static String formatDecimal(num number, {int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'ar_SA');
    return formatter.format(number);
  }

  // Percentage Formatter
  /// Format number as percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // Duration Formatter
  /// Format duration as 'X دقيقة' or 'X ساعة و Y دقيقة'
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $remainingMinutes دقيقة';
      }
    }
  }

  // File Size Formatter
  /// Format file size in bytes to human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
    }
  }

  // Weight Formatter
  /// Format weight in grams to human readable format
  static String formatWeight(int grams) {
    if (grams < 1000) {
      return '$grams جم';
    } else {
      final kg = grams / 1000;
      return '${kg.toStringAsFixed(1)} كجم';
    }
  }
}

/// Extension on double for currency formatting
extension CurrencyExtension on double {
  String get formatCurrency => Formatters.formatCurrency(this);
  String get toCurrency => Formatters.formatCurrency(this);
  String get toCurrencyNoSymbol => Formatters.formatCurrencyNoSymbol(this);
}

/// Extension on int for currency formatting
extension IntCurrencyExtension on int {
  String get formatCurrency => Formatters.formatCurrency(toDouble());
  String get toCurrency => Formatters.formatCurrency(toDouble());
  String get toCurrencyNoSymbol => Formatters.formatCurrencyNoSymbol(toDouble());
}

/// Extension on num for number formatting
extension NumberFormatExtension on num {
  String get formatted => Formatters.formatNumber(this);
  String toFormattedDecimal([int decimals = 2]) => Formatters.formatDecimal(this, decimals: decimals);
}

/// Extension on DateTime for date formatting
extension DateFormatExtension on DateTime {
  String get formattedDate => Formatters.formatDate(this);
  String get formattedTime => Formatters.formatTime(this);
  String get formattedDateTime => Formatters.formatDateTime(this);
  String get formattedFullDate => Formatters.formatFullDate(this);
  String get formattedRelativeDate => Formatters.formatRelativeDate(this);
}

/// Extension on String for phone formatting
extension PhoneFormatExtension on String {
  String get formattedPhone => Formatters.formatPhoneNumber(this);
}

