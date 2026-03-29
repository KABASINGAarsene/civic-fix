import 'package:flutter/material.dart';
import 'package:district_direct/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderCard(scheme),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSettingsGrid(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 40), // Padding for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeaderCard(ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final name = _userData?['name'] ?? 'Citizen';
    final email = _userData?['email'] ?? 'No email';
    final phone = _userData?['phone'] ?? 'No phone number';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(Icons.person, size: 50, color: scheme.onSurface),
                ),
              ),
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, size: 14, color: scheme.onTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${l10n.telPrefix} $phone',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGrid() {
    final appSettings = context.watch<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final languageNames = {
      'en': l10n.english,
      'fr': l10n.french,
      'rw': l10n.kinyarwanda,
    };

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildGridOption(
          icon: appSettings.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
          title: l10n.citizenAppTheme,
          subtitle: appSettings.isDarkMode ? l10n.citizenDarkMode : l10n.citizenLightMode,
          color: scheme.secondary,
          onTap: () {
            appSettings.toggleThemeMode();
          },
        ),
        _buildGridOption(
          icon: Icons.notifications_active,
          title: l10n.citizenNotifications,
          subtitle: appSettings.notificationsEnabled ? l10n.enabled : l10n.disabled,
          color: scheme.tertiary,
          onTap: () {
            appSettings.setNotificationsEnabled(
              !appSettings.notificationsEnabled,
            );
          },
        ),
        _buildGridOption(
          icon: Icons.language,
          title: l10n.language,
          subtitle: languageNames[appSettings.languageCode] ?? l10n.english,
          color: scheme.primary,
          onTap: _showLanguagePicker,
        ),
        _buildGridOption(
          icon: Icons.shield,
          title: l10n.citizenSecurity,
          subtitle: l10n.citizenSecuritySubtitle,
          color: scheme.error,
          onTap: _showChangePasswordConfirmation,
        ),
      ],
    );
  }

  Future<void> _showLanguagePicker() async {
    final appSettings = context.read<AppSettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    final languageNames = {
      'en': l10n.english,
      'fr': l10n.french,
      'rw': l10n.kinyarwanda,
    };
    final languageCodes = AppSettingsProvider.supportedLanguageCodes;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '',
              ),
              Text(
                l10n.selectLanguage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...languageCodes.map(
                (code) => ListTile(
                  title: Text(languageNames[code] ?? code),
                    trailing: appSettings.languageCode == code
                      ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                      : null,
                  onTap: () {
                    appSettings.setLanguageCode(code);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _userData?['name']);
    final phoneController = TextEditingController(text: _userData?['phone']);
    bool isSaving = false;
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.editProfile),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.fullName,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumber,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final user =
                                fb_auth.FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                    'name': nameController.text.trim(),
                                    'phone': phoneController.text.trim(),
                                  });

                              await _fetchUserData();

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.profileUpdated),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${AppLocalizations.of(context)!.failedToSubmit}: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangePasswordConfirmation() async {
    final email = _userData?['email'] as String?;
    if (email == null || email.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailNotFound),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isSending = false;
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changePassword),
              content: Text(
                l10n.passwordResetPrompt,
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          setDialogState(() => isSending = true);
                          try {
                            await fb_auth.FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.passwordResetSent),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${AppLocalizations.of(context)!.failedToSendEmail}: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.sendLink,
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGridOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(
          AppLocalizations.of(context)!.logOut,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 3, // Profile is index 3
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/citizen-home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/my-reports');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/citizen-chats');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.homeLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context)!.reportsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            label: AppLocalizations.of(context)!.chatsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profileLabel,
          ),
        ],
      ),
    );
  }
}
