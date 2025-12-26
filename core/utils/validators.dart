class Validators {
  // Email Validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    return null;
  }

  // Password Validator
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    return null;
  }

  // Phone Validator (Saudi Arabia format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الجوال مطلوب';
    }
    
    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check Saudi phone format (05xxxxxxxx or +9665xxxxxxxx)
    final phoneRegex = RegExp(r'^(05|5|\+9665)[0-9]{8}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'رقم الجوال غير صحيح';
    }
    
    return null;
  }

  // Required Field Validator
  static String? required(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  // Min Length Validator
  static String? minLength(String? value, int min, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    
    if (value.length < min) {
      return '$fieldName يجب أن يكون $min أحرف على الأقل';
    }
    
    return null;
  }

  // Max Length Validator
  static String? maxLength(String? value, int max, [String fieldName = 'هذا الحقل']) {
    if (value != null && value.length > max) {
      return '$fieldName يجب ألا يتجاوز $max أحرف';
    }
    return null;
  }

  // Number Validator
  static String? number(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName يجب أن يكون رقماً';
    }
    
    return null;
  }

  // Positive Number Validator
  static String? positiveNumber(String? value, [String fieldName = 'هذا الحقل']) {
    final numError = number(value, fieldName);
    if (numError != null) return numError;
    
    final num = double.parse(value!);
    if (num <= 0) {
      return '$fieldName يجب أن يكون أكبر من صفر';
    }
    
    return null;
  }

  // Min Value Validator
  static String? minValue(String? value, double min, [String fieldName = 'هذا الحقل']) {
    final numError = number(value, fieldName);
    if (numError != null) return numError;
    
    final num = double.parse(value!);
    if (num < min) {
      return '$fieldName يجب أن يكون $min أو أكثر';
    }
    
    return null;
  }

  // Max Value Validator
  static String? maxValue(String? value, double max, [String fieldName = 'هذا الحقل']) {
    final numError = number(value, fieldName);
    if (numError != null) return numError;
    
    final num = double.parse(value!);
    if (num > max) {
      return '$fieldName يجب ألا يتجاوز $max';
    }
    
    return null;
  }

  // Confirm Password Validator
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  // URL Validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرابط مطلوب';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }
    
    return null;
  }

  // Compose multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}