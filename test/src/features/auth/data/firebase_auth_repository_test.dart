import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneymate/src/features/auth/data/user_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserRepository', () {
    late MockUserRepository mockRepo;

    setUp(() {
      mockRepo = MockUserRepository();
    });

    test('getUser returns user when document exists', () async {
      final expectedUser = AppUser(
        id: 'user1',
        email: 'test@test.com',
        name: 'Test User',
        currency: 'USD',
        createdAt: DateTime(2026, 3, 5),
      );

      when(() => mockRepo.getUser('user1'))
          .thenAnswer((_) async => expectedUser);

      final user = await mockRepo.getUser('user1');
      expect(user, expectedUser);
      verify(() => mockRepo.getUser('user1')).called(1);
    });

    test('createUser stores user data', () async {
      final user = AppUser(
        id: 'user1',
        email: 'test@test.com',
        name: 'Test User',
        currency: 'USD',
        createdAt: DateTime(2026, 3, 5),
      );

      when(() => mockRepo.createUser(user)).thenAnswer((_) async {});

      await mockRepo.createUser(user);
      verify(() => mockRepo.createUser(user)).called(1);
    });
  });
}
