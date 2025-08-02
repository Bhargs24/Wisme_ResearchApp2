import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import '../core/firebase_service.dart';
import '../core/research_metrics_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EnhancedAuthScreen extends StatefulWidget {
  const EnhancedAuthScreen({super.key});

  @override
  State<EnhancedAuthScreen> createState() => _EnhancedAuthScreenState();
}

class _EnhancedAuthScreenState extends State<EnhancedAuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLogin = true;
  AuthMethod _authMethod = AuthMethod.email;
  String? _errorMessage;
  bool _isLoading = false;
  bool _otpSent = false;
  bool _obscurePassword = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo and title
                _buildHeader(),
                const SizedBox(height: 40),
                
                // Auth method tabs
                _buildAuthMethodTabs(),
                const SizedBox(height: 24),
                
                // Auth form
                _buildAuthForm(),
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null) _buildErrorMessage(),
                
                // Action buttons
                _buildActionButtons(),
                const SizedBox(height: 32),
                
                // Divider
                _buildDivider(),
                const SizedBox(height: 24),
                
                // Social login options
                _buildSocialLogin(),
                const SizedBox(height: 24),
                
                // Switch between login/register
                _buildAuthModeSwitch(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 64,
          color: AppColors.accentGreen,
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? 'Welcome Back' : 'Join Wisme Research',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin 
            ? 'Continue your learning journey'
            : 'Help us validate the future of learning',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthMethodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _authMethod = AuthMethod.values[index];
            _errorMessage = null;
            _otpSent = false;
          });
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentGreen,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(
            icon: Icon(Icons.email_outlined),
            text: 'Email',
          ),
          Tab(
            icon: Icon(Icons.phone_outlined),
            text: 'Phone',
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_authMethod == AuthMethod.email) ..._buildEmailFields(),
          if (_authMethod == AuthMethod.phone) ..._buildPhoneFields(),
        ],
      ),
    );
  }

  List<Widget> _buildEmailFields() {
    return [
      // Name fields for registration only
      if (!_isLogin) ...[
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.person_outlined, color: AppColors.accentGreen),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
                  ),
                ),
                validator: (value) {
                  if (!_isLogin && (value == null || value.isEmpty)) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.accentGreen),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.lock_outlined, color: AppColors.accentGreen),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (!_isLogin && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildPhoneFields() {
    return [
      if (!_otpSent) ...[
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(Icons.phone_outlined, color: AppColors.accentGreen),
            hintText: '+91 9876543210',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(' ', ''))) {
              return 'Please enter a valid phone number with country code';
            }
            return null;
          },
        ),
      ] else ...[
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'OTP Code',
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(Icons.sms_outlined, color: AppColors.accentGreen),
            hintText: '123456',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentGreen, width: 2),
            ),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Didn't receive OTP?",
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: _isLoading ? null : _resendOTP,
                child: Text(
                  'Resend',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentGreen),
                ),
              ),
            ],
          ),
      ],
    ];
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(
                    _getPrimaryButtonText(),
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (_authMethod == AuthMethod.phone && _otpSent) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _otpSent = false;
                _otpController.clear();
                _errorMessage = null;
              });
            },
            child: Text(
              'Change Phone Number',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentGreen),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          Icons.login,
          color: AppColors.accentGreen,
          size: 24,
        ),
        label: Text(
          'Continue with Google',
          style: AppTextStyles.buttonText.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin 
            ? "Don't have an account? " 
            : "Already have an account? ",
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
              _errorMessage = null;
              _otpSent = false;
              _emailController.clear();
              _passwordController.clear();
              _phoneController.clear();
              _otpController.clear();
            });
          },
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getPrimaryButtonText() {
    switch (_authMethod) {
      case AuthMethod.email:
        return _isLogin ? 'Sign In' : 'Create Account';
      case AuthMethod.phone:
        if (_otpSent) {
          return 'Verify OTP';
        }
        return _isLogin ? 'Send OTP' : 'Send OTP';
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      switch (_authMethod) {
        case AuthMethod.email:
          if (_isLogin) {
            await authProvider.signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
          } else {
            await authProvider.registerWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
            
            // Store user name in research metrics for personalization
            if (authProvider.user != null) {
              final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
              research.setUserId(authProvider.user!.uid);
              
              // Store name data for research personalization
              final firstName = _firstNameController.text.trim();
              final lastName = _lastNameController.text.trim();
              if (firstName.isNotEmpty) {
                research.storeUserName(
                  firstName: firstName,
                  lastName: lastName,
                );
              }
            }
          }
          break;

        case AuthMethod.phone:
          if (!_otpSent) {
            await _sendOTP();
          } else {
            await authProvider.verifyPhoneOTP(_otpController.text);
          }
          break;
      }

      // Navigate to next screen if successful
      if (mounted && authProvider.user != null) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOTP() async {
    try {
      await FirebaseService.sendPhoneOTP(_phoneController.text.trim());
      setState(() {
        _otpSent = true;
      });
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseService.resendPhoneOTP(_phoneController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();

      // Navigate to next screen if successful
      if (mounted && authProvider.user != null) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('invalid-verification-code')) {
      return 'Invalid OTP. Please check and try again.';
    } else if (error.contains('session-expired')) {
      return 'OTP expired. Please request a new one.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}

enum AuthMethod {
  email,
  phone,
}
