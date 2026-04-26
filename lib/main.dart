import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/diet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load API keys from .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const GainiqApp());
}

class GainiqApp extends StatelessWidget {
  const GainiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DietProvider()..loadMockDietPlan()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()..loadMockPlans()),
        ChangeNotifierProxyProvider<DietProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, dietProvider, userProvider) {
            userProvider!.setDietProvider(dietProvider);
            return userProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Gainiq',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: child,
            ),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
