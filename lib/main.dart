import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth/citizen_login_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/citizen/district_feed_screen.dart';
import 'screens/citizen/create_report_screen.dart';
import 'screens/citizen/report_incident_screen.dart';
import 'screens/citizen/my_reports_screen.dart';
import 'screens/shared/case_verification_screen.dart';
import 'screens/citizen/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/issues_management_screen.dart';
import 'screens/admin/ticket_detail_screen.dart';
import 'screens/admin/district_map_screen.dart';
import 'screens/admin/admin_chats_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/citizen/citizen_chats_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final appSettingsProvider = await AppSettingsProvider.create();
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(DistrictDirectApp(appSettingsProvider: appSettingsProvider));
}

class DistrictDirectApp extends StatelessWidget {
  const DistrictDirectApp({
    Key? key,
    required this.appSettingsProvider,
  }) : super(key: key);

  final AppSettingsProvider appSettingsProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: appSettingsProvider,
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, appSettings, _) {
          return MaterialApp(
            title: 'DistrictDirect Rwanda',
            debugShowCheckedModeBanner: false,
            themeMode: appSettings.themeMode,
            locale: appSettings.locale,
            supportedLocales: AppSettingsProvider.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0A4DDE),
                onPrimary: Color(0xFFFFFFFF),
                primaryContainer: Color(0xFFEFF6FF),
                onPrimaryContainer: Color(0xFF1D4ED8),
                secondary: Color(0xFF2563EB),
                onSecondary: Color(0xFFFFFFFF),
                tertiary: Color(0xFF10B981),
                onTertiary: Color(0xFFFFFFFF),
                error: Color(0xFFEF4444),
                onError: Color(0xFFFFFFFF),
                surface: Color(0xFFFFFFFF),
                onSurface: Color(0xFF111827),
                surfaceContainerHighest: Color(0xFFF3F4F6),
                onSurfaceVariant: Color(0xFF6B7280),
                outline: Color(0xFFE5E7EB),
                shadow: Color(0x1A111827),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF3B82F6),
                onPrimary: Color(0xFFFFFFFF),
                primaryContainer: Color(0xFF1E3A8A),
                onPrimaryContainer: Color(0xFFBFDBFE),
                secondary: Color(0xFF60A5FA),
                onSecondary: Color(0xFFFFFFFF),
                tertiary: Color(0xFF10B981),
                onTertiary: Color(0xFFFFFFFF),
                error: Color(0xFFEF4444),
                onError: Color(0xFFFFFFFF),
                surface: Color(0xFF1F2937),
                onSurface: Color(0xFFFFFFFF),
                surfaceContainerHighest: Color(0xFF374151),
                onSurfaceVariant: Color(0xFF9CA3AF),
                outline: Color(0xFF374151),
                shadow: Color(0x66000000),
              ),
              scaffoldBackgroundColor: const Color(0xFF111827),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            // Initial route
            initialRoute: '/',
            // Define routes
            routes: {
              '/': (context) => const RoleSelectionScreen(),
              '/citizen-login': (context) => const CitizenLoginScreen(),
              '/admin-login': (context) => const AdminLoginScreen(),
              '/citizen-home': (context) => const DistrictFeedScreen(),
              '/capture-evidence': (context) => const CreateReportScreen(),
              '/report-incident': (context) => const ReportIncidentScreen(),
              '/my-reports': (context) => const MyReportsScreen(),
              '/chats': (context) => const CaseVerificationScreen(),
              '/citizen-chats': (context) => const CitizenChatsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/admin-issues': (context) => const IssuesManagementScreen(),
              '/admin-ticket-detail': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return TicketDetailScreen(
                  data: args?['data'],
                  ticketId: args?['ticketId'],
                );
              },
              '/admin-map': (context) => const DistrictMapScreen(),
              '/admin-chats': (context) => const AdminChatsScreen(),
              '/admin-profile': (context) => const AdminProfileScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Role Selection Screen
/// Allows user to choose between Citizen and Admin login
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF060C18) : const Color(0xFF1E3A8A),
              isDark ? const Color(0xFF111B2D) : const Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_city,
                      size: 56,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'DistrictDirect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Government Service Portal',
                    style: TextStyle(
                      fontSize: 15,
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Citizen Login Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/citizen-login');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 16.0,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                size: 42,
                                color: scheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Citizen Login',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Access your local district services',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Admin Login Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/admin-login');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 16.0,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 42,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Admin Login',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.tertiary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'For empowering local district officials portal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Footer
                  Text(
                    '© 2026 Government of Rwanda',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
