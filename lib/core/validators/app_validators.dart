class AppValidators {
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 200;
  static const int maxPostLength = 1000;
  static const int maxCommentLength = 500;
  static const int minUsernameLength = 1;
  static const int maxCurrencyAmount = 999999;
  static const int maxTransactionAmount = 10000;

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength character';
    }
    if (value.trim().length > maxUsernameLength) {
      return 'Username must be less than $maxUsernameLength characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value != null && value.length > maxBioLength) {
      return 'Bio must be less than $maxBioLength characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[/w-\.]+@([/w-]+\.)+[/w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Post content is required';
    }
    if (value.trim().length < 1) {
      return 'Post cannot be empty';
    }
    if (value.length > maxPostLength) {
      return 'Post must be less than $maxPostLength characters';
    }
    return null;
  }

  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Comment cannot be empty';
    }
    if (value.length > maxCommentLength) {
      return 'Comment must be less than $maxCommentLength characters';
    }
    return null;
  }

  static bool isValidCurrencyAmount(int amount) {
    return amount > 0 && amount <= maxTransactionAmount;
  }

  static bool isValidPrice(int price) {
    return price > 0 && price <= maxCurrencyAmount;
  }

  static String? validateCurrencyAmount(int? amount, String currency) {
    if (amount == null || amount <= 0) {
      return '$currency amount must be greater than zero';
    }
    if (amount > maxTransactionAmount) {
      return '$currency amount cannot exceed $maxTransactionAmount';
    }
    return null;
  }

  static String? validateStorePrice(int? price) {
    if (price == null || price <= 0) {
      return 'Price must be greater than zero';
    }
    if (price > maxCurrencyAmount) {
      return 'Price cannot exceed $maxCurrencyAmount';
    }
    return null;
  }

  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
