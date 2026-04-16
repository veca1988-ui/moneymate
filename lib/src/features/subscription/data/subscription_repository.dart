import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository.g.dart';

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  return SubscriptionRepository();
}

@riverpod
Future<bool> isPremium(IsPremiumRef ref) async {
  // TODO(veka): Re-enable with RevenueCat after Xcode update
  return false;
}

class SubscriptionRepository {
  Future<bool> isPremium() async {
    // TODO(veka): Re-enable with RevenueCat after Xcode update
    return false;
  }
}
