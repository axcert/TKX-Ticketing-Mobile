import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/loading/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'services/storage_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService().init();

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  runApp(MyApp(connectivityService: connectivityService));
}

class MyApp extends StatelessWidget {
  final ConnectivityService connectivityService;

  const MyApp({super.key, required this.connectivityService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivityService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: 'TKX Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashToLoginWrapper(),
      ),
    );
  }
}

class SplashToLoginWrapper extends StatefulWidget {
  const SplashToLoginWrapper({super.key});

  @override
  State<SplashToLoginWrapper> createState() => _SplashToLoginWrapperState();
}

class _SplashToLoginWrapperState extends State<SplashToLoginWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is already logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Navigate based on authentication status
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // User is logged in, go to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not logged in, show login screen
      LoginScreen.showAsBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(
      duration: Duration(seconds: 2),
    );
  }
}
