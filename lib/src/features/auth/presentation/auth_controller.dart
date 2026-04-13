import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signInWithEmail(
            email,
            password,
          ),
    );
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String currency,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signUpWithEmail(
            email,
            password,
            name,
            currency,
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signOut(),
    );
  }
}
