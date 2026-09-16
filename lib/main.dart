import 'package:flutter/material.dart';
import 'package:project/welcom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'resetpass.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://krhsvdzgpfhhjxspcmxk.supabase.co',
    anonKey: 'sb_publishable_fPlB3tmEJomUu_Jba0XAgg_ydYZZIU2',

    // PKCE
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,

      builder: (context, darkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Expense Tracker',

          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.light,
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          themeMode:
          darkMode ? ThemeMode.dark : ThemeMode.light,

          // Detect reset password URL
          home: Uri.base.path == '/reset-password'
              ? const ResetPassword()
              : const WelcomePage(),
        );
      },
    );
  }
}