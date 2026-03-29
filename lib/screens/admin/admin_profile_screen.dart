import 'package:flutter/material.dart';
import 'package:district_direct/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  int _bottomNavIndex = 4; // Profile is index 4

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
    final appSettings = context.watch<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.adminProfileTitle,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 32),

            _buildSettingsGroup(
              title: l10n.preferences,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: l10n.pushNotifications,
                  value: appSettings.notificationsEnabled,
                  onChanged: (val) {
                    appSettings.setNotificationsEnabled(val);
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: l10n.darkTheme,
                  value: appSettings.isDarkMode,
                  onChanged: (val) {
                    appSettings.setThemeMode(
                      val ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                _buildLanguageDropdownTile(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsGroup(
              title: l10n.security,
              children: [
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: l10n.changePassword,
                  onTap: _showChangePasswordConfirmation,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileHeader() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: scheme.primary),
      );
    }

    final name = _userData?['name'] ?? l10n.adminUserFallback;
    final district = _userData?['district'] ?? l10n.unknownDistrict;
    final email = _userData?['email'] ?? l10n.noEmailAvailable;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: scheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.secondaryContainer,
              child: Icon(Icons.person, size: 50, color: scheme.onSecondaryContainer),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.districtAdmin,
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: scheme.onPrimary.withValues(alpha: 0.85),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      district,
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: scheme.onPrimary.withValues(alpha: 0.85),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: scheme.onPrimary),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: scheme.onSurfaceVariant, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: scheme.onSurfaceVariant, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      activeColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      onChanged: onChanged,
    );
  }

  Widget _buildLanguageDropdownTile() {
    final appSettings = context.watch<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final languageNames = {
      'en': l10n.english,
      'fr': l10n.french,
      'rw': l10n.kinyarwanda,
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.language, color: scheme.onSurfaceVariant, size: 18),
      ),
      title: Text(
        l10n.language,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: appSettings.languageCode,
        dropdownColor: scheme.surface,
        icon: Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
        underline: const SizedBox(),
        style: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        onChanged: (String? newValue) {
          if (newValue != null) {
            appSettings.setLanguageCode(newValue);
          }
        },
        items: AppSettingsProvider.supportedLanguageCodes
            .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(languageNames[value] ?? value),
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
        icon: Icon(Icons.logout, color: scheme.error),
        label: Text(
          l10n.logOut,
          style: TextStyle(
            color: scheme.error,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _userData?['name']);
    final emailController = TextEditingController(text: _userData?['email']);
    bool isSaving = false;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: scheme.surface,
              title: Text(
                l10n.editProfile,
                style: TextStyle(color: scheme.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: scheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.fullName,
                      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: scheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.emailAddress,
                      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final user =
                                fb_auth.FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              // Update Firestore users collection
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                    'name': nameController.text.trim(),
                                    'email': emailController.text.trim(),
                                  });

                              // Refresh local data
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
                                  content: Text('Error updating profile: $e'),
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
                          style: TextStyle(color: scheme.onPrimary),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Cannot reset password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isSending = false;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: scheme.surface,
              title: Text(
                l10n.changePassword,
                style: TextStyle(color: scheme.onSurface),
              ),
              content: Text(
                l10n.passwordResetPrompt,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
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
                                  content: Text('Failed to send link: $e'),
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
                          style: TextStyle(color: scheme.onPrimary),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.35))),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-issues');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-map');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/admin-chats');
          } else if (index == 4) {
            // Already here
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
            icon: const Icon(Icons.dashboard),
            label: l10n.adminDashboardLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: l10n.adminIssuesLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n.adminMapLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: l10n.chatsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.profileLabel,
          ),
        ],
      ),
    );
  }
}
