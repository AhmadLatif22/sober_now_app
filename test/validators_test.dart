import 'package:flutter_test/flutter_test.dart';
import 'package:sober_now/utils/validators.dart';

void main() {
  group('Password Validator Tests', () {
    test('Valid password passes all checks', () {
      expect(PasswordValidator.validate('Secure@123'), isNull);
      expect(PasswordValidator.validate('MyPass@45'), isNull);
      expect(PasswordValidator.validate('Test#99password'), isNull);
    });

    test('Password too short fails', () {
      expect(
        PasswordValidator.validate('Ab@1'),
        equals('Password must be at least 8 characters'),
      );
    });

    test('Password without uppercase fails', () {
      expect(
        PasswordValidator.validate('secure@123'),
        equals('Password must contain at least one uppercase letter'),
      );
    });

    test('Password without two lowercase fails', () {
      expect(
        PasswordValidator.validate('SECURE@123'),
        equals('Password must contain at least two lowercase letters'),
      );
    });

    test('Password without special character fails', () {
      expect(
        PasswordValidator.validate('Secure123'),
        equals('Password must contain at least one special character'),
      );
    });

    test('Password without number fails', () {
      expect(
        PasswordValidator.validate('Secure@pass'),
        equals('Password must contain at least one number'),
      );
    });

    test('Password with sequential numbers fails', () {
      expect(
        PasswordValidator.validate('Secure@123'),
        equals('Password cannot contain sequential numbers'),
      );
      expect(
        PasswordValidator.validate('Pass@234word'),
        equals('Password cannot contain sequential numbers'),
      );
    });

    test('Empty password fails', () {
      expect(
        PasswordValidator.validate(''),
        equals('Password is required'),
      );
    });

    test('Null password fails', () {
      expect(
        PasswordValidator.validate(null),
        equals('Password is required'),
      );
    });
  });
}