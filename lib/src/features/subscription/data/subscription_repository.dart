import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository.g.dart';

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  return SubscriptionRepository();
}

@riverpod
Stream<CustomerInfo> customerInfo(CustomerInfoRef ref) {
  final controller = StreamController<CustomerInfo>();
  void listener(CustomerInfo info) => controller.add(info);
  Purchases.addCustomerInfoUpdateListener(listener);
  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });
  return controller.stream;
}

@riverpod
Future<bool> isPremium(IsPremiumRef ref) async {
  final info = await Purchases.getCustomerInfo();
  return info.entitlements.active.containsKey('premium');
}

class SubscriptionRepository {
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    return Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }

  Future<bool> isPremium() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey('premium');
  }
}
