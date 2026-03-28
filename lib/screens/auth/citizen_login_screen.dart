import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/validators.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Citizen Login Screen
/// Login page for regular citizens with Rwanda landscape background

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({Key? key}) : super(key: key);

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nidController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<AuthProvider>().loginCitizen(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/citizen-home',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception:", "").trim()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<AuthProvider>().signUpCitizen(
          phone: _phoneController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created! Please check your spam folder for the link to verify your sign up.',
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 5),
            ),
          );
          // Switch back to login mode
          setState(() {
            _isLoginMode = true;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _nidController.clear();
            _formKey.currentState?.reset();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception:", "").trim()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await context.read<AuthProvider>().signInWithGoogle();
      if (credential != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/citizen-home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user,
              color: AppColors.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zero-Trip Guarantee',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save time. No more traveling to the office.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          validator: Validators.validateRwandaPhone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
            _PhoneNumberFormatter(),
          ],
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '78 XXX XXXX',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇷🇼', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          '+250',
                          style: AppTextStyles.inputText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            errorStyle: AppTextStyles.inputError,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Name', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            if (value.trim().length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: AppTextStyles.inputHint,
            errorStyle: AppTextStyles.inputError,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: AppTextStyles.inputHint,
            errorStyle: AppTextStyles.inputError,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          obscureText: _obscurePassword,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: AppTextStyles.inputHint,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            errorStyle: AppTextStyles.inputError,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
        if (_isLoginMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Forgot Password?',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    bool isSending = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we will send you a link to reset your password.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'your@email.com',
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          if (emailController.text.trim().isEmpty) return;
                          setDialogState(() => isSending = true);
                          try {
                            await context
                                .read<AuthProvider>()
                                .sendPasswordResetEmail(
                                  emailController.text.trim(),
                                );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password reset email sent! Check your inbox (and spam).',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to send email. Check if the address is correct.',
                                  ),
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
                      : const Text(
                          'Send Link',
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

  Widget _buildNationalIDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('National ID', style: AppTextStyles.inputLabel),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nidController,
          validator: (value) =>
              Validators.validateNationalID(value, isOptional: true),
          keyboardType: TextInputType.number,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'Enter your 16-digit NID',
            hintStyle: AppTextStyles.inputHint,
            counterText: '',
            errorStyle: AppTextStyles.inputError,
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_isLoginMode ? _handleLogin : _handleSignup),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.inputBorder,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textWhite,
                  ),
                ),
              )
            : Text(
                _isLoginMode ? 'Login' : 'Create Account',
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          // Header with Logo
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.backgroundWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: AppColors.textWhite,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'DistrictDirect',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image section with greeting - Rounded corners with margin
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/images/citizen.png'),
                          fit: BoxFit.cover,
                          onError: (error, stackTrace) {
                            print('Error loading image: $error');
                          },
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Hello! Muraho!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Form section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          'Access your district services directly',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join thousands of citizens saving time daily.',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 32),
                        // Form
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Phone Number Field
                              _buildPhoneField(),
                              const SizedBox(height: 20),
                              // Name Field (Signup mode only)
                              if (!_isLoginMode) _buildNameField(),
                              if (!_isLoginMode) const SizedBox(height: 20),
                              // Email Field (Signup mode only)
                              if (!_isLoginMode) _buildEmailField(),
                              if (!_isLoginMode) const SizedBox(height: 20),
                              // Password Field
                              _buildPasswordField(),
                              const SizedBox(height: 20),
                              // National ID Field (Signup mode only)
                              if (!_isLoginMode) _buildNationalIDField(),
                              if (!_isLoginMode) const SizedBox(height: 24),
                              // Login/Signup Button
                              _buildLoginButton(),
                              const SizedBox(height: 16),
                              // Mode Toggle Link
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLoginMode
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLoginMode = !_isLoginMode;
                                          // Clear form when switching modes
                                          _nameController.clear();
                                          _emailController.clear();
                                          _passwordController.clear();
                                          _nidController.clear();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        _isLoginMode ? 'Sign Up' : 'Login',
                                        style: AppTextStyles.link,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // OR Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppColors.inputBorder)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('OR', style: AppTextStyles.caption),
                                  ),
                                  Expanded(child: Divider(color: AppColors.inputBorder)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Google Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.inputBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: SvgPicture.string(
                                    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>''',
                                    height: 24,
                                    width: 24,
                                  ),
                                  label: const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Info Card
                              _buildInfoCard(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Footer
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Privacy Shield: Your data is protected',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'DISTRICTDIRECT RWANDA\n© 2026 Government Service Portal',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone Number Formatter
/// Formats phone input as: 78 XXX XXXX
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Remove any existing spaces
    final digitsOnly = text.replaceAll(' ', '');

    // Format as: 78 123 4567
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
