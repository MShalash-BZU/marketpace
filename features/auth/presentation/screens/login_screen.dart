import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/common/app_button.dart';
import '../../../../shared/widgets/common/app_text_field.dart';
import '../../../../core/router/navigation_helper.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous errors
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) {
      if (success) {
        // Navigate to home based on user role
        final user = ref.read(authProvider).user;
        if (user != null) {
          NavigationHelper.navigateToHome(context, user.role);
        }
      } else {
        // Error is already in state, will be shown by listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.paddingXLarge * 2),
                  
                  // Logo & Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLarge,
                            ),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 50,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Text(
                          'مرحباً بك',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'سجّل دخولك للمتابعة',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingXLarge * 2),
                  
                  // Email Field
                  AppTextField(
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل بريدك الإلكتروني',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.grey500,
                    ),
                    validator: Validators.email,
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Password Field
                  AppTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.grey500,
                    ),
                    validator: (value) => Validators.required(value, 'كلمة المرور'),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingSmall),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              // Navigate to forgot password screen
                            },
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingLarge),
                  
                  // Login Button
                  AppButton(
                    text: 'تسجيل الدخول',
                    onPressed: authState.isLoading ? null : _handleLogin,
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                        ),
                        child: Text(
                          'أو',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.grey500,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Social Login Buttons (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  // Google Sign In
                                },
                          icon: const Icon(Icons.g_mobiledata, size: 30),
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  // Apple Sign In
                                },
                          icon: const Icon(Icons.apple, size: 24),
                          label: const Text('Apple'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingXLarge),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text('سجّل الآن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}