import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/firebase_options.dart';
import 'package:moneymate/src/app.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// TODO: Replace with your RevenueCat API keys from https://app.revenuecat.com
const _revenueCatAppleApiKey = 'YOUR_REVENUECAT_APPLE_API_KEY';
const _revenueCatGoogleApiKey = 'YOUR_REVENUECAT_GOOGLE_API_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize RevenueCat
  await Purchases.setLogLevel(LogLevel.debug);
  final apiKey =
      Platform.isIOS ? _revenueCatAppleApiKey : _revenueCatGoogleApiKey;
  await Purchases.configure(PurchasesConfiguration(apiKey));

  runApp(
    const ProviderScope(
      child: MoneyMateApp(),
    ),
  );
}
