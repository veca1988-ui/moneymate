import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/firebase_options.dart';
import 'package:moneymate/src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO(veka): Initialize RevenueCat after updating Xcode
  // await Purchases.setLogLevel(LogLevel.debug);
  // final apiKey = Platform.isIOS ? 'APPLE_KEY' : 'GOOGLE_KEY';
  // await Purchases.configure(PurchasesConfiguration(apiKey));

  runApp(
    const ProviderScope(
      child: MoneyMateApp(),
    ),
  );
}
