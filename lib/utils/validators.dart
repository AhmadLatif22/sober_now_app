class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least two lowercase letters
    if (RegExp(r'[a-z]').allMatches(password).length < 2) {
      return 'Password must contain at least two lowercase letters';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    
    // Check for sequential numbers
    if (_hasSequentialNumbers(password)) {
      return 'Password cannot contain sequential numbers';
    }
    
    return null;
  }
  
  static bool _hasSequentialNumbers(String password) {
    final sequences = [
      '012', '123', '234', '345', '456', '567', '678', '789',
      '210', '321', '432', '543', '654', '765', '876', '987'
    ];
    
    for (var sequence in sequences) {
      if (password.contains(sequence)) {
        return true;
      }
    }
    
    return false;
  }
}
