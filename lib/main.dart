import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'constants/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DistrictDirectApp());
}

class DistrictDirectApp extends StatelessWidget {
  const DistrictDirectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'DistrictDirect Rwanda',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryBlue,
          scaffoldBackgroundColor: AppColors.backgroundWhite,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            primary: AppColors.primaryBlue,
            secondary: AppColors.teal,
          ),
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e), // Dark blue
              Color(0xFF0d47a1), // Medium dark blue
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
                      color: AppColors.textWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: 56,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'DistrictDirect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Government Service Portal',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textWhite,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Citizen Login Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Citizen Login',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Access your local district services',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                                color: AppColors.teal,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Admin Login',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.teal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'For empowering local district officials portal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
                  const Text(
                    '© 2026 Government of Rwanda',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textWhite,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
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
