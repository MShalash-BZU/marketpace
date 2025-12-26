import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/common/app_button.dart';
import '../../../../shared/widgets/common/app_text_field.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.customer;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    // Ensure customer is selected by default
    _selectedRole = UserRole.customer;
  }

  void _onRoleSelected(UserRole role) {
    if (role != UserRole.customer) {
      // Show confirmation dialog for non-customer roles
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد نوع الحساب'),
          content: Text(
            role == UserRole.storeOwner
                ? 'سيتم إنشاء حساب صاحب محل. ستحتاج إلى إضافة معلومات محلك لاحقاً.'
                : 'سيتم إنشاء حساب سائق. ستحتاج إلى إضافة معلومات السيارة والرخصة لاحقاً.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedRole = role;
                });
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _selectedRole = role;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate to home or pop
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: const Text('إنشاء حساب جديد'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Message
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'انضم إلينا الآن',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'أنشئ حسابك وابدأ رحلتك معنا',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Account Type Selection
                  Text(
                    'اختر نوع حسابك',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'يمكنك تغيير نوع الحساب لاحقاً من إعدادات الملف الشخصي',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleChip(
                                label: 'عميل',
                                subtitle: 'تسوق واطلب',
                                role: UserRole.customer,
                                icon: Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Expanded(
                              child: _buildRoleChip(
                                label: 'صاحب محل',
                                subtitle: 'أدر محلك',
                                role: UserRole.storeOwner,
                                icon: Icons.store,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleChip(
                                label: 'سائق',
                                subtitle: 'توصيل الطلبات',
                                role: UserRole.courier,
                                icon: Icons.delivery_dining,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            // Empty space for future roles
                            const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_selectedRole != UserRole.customer)
                    Container(
                      margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        border: Border.all(color: AppColors.info.withAlpha(77)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedRole == UserRole.storeOwner ? Icons.store : Icons.delivery_dining,
                            color: AppColors.info,
                            size: 16,
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Expanded(
                            child: Text(
                              _selectedRole == UserRole.storeOwner
                                  ? 'سيتم إنشاء حساب صاحب محل. يمكنك إدارة محلك من التطبيق.'
                                  : 'سيتم إنشاء حساب سائق. يمكنك استقبال طلبات التوصيل.',
                              style: const TextStyle(
                                color: AppColors.info,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Full Name
                  AppTextField(
                    label: 'الاسم الكامل',
                    hint: 'أدخل اسمك الكامل',
                    controller: _fullNameController,
                    textInputAction: TextInputAction.next,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.grey500,
                    ),
                    validator: (value) => Validators.required(value, 'الاسم'),
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Phone
                  AppTextField(
                    label: 'رقم الجوال',
                    hint: '05xxxxxxxx',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.grey500,
                    ),
                    validator: Validators.phone,
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Email
                  AppTextField(
                    label: 'البريد الإلكتروني',
                    hint: 'example@email.com',
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

                  // Password
                  AppTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة مرور قوية',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.grey500,
                    ),
                    validator: Validators.password,
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Confirm Password
                  AppTextField(
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !authState.isLoading,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.grey500,
                    ),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    onSubmitted: (_) => _handleRegister(),
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Terms & Conditions
                  CheckboxListTile(
                    value: _acceptTerms,
                    onChanged: authState.isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        const Text('أوافق على '),
                        GestureDetector(
                          onTap: () {
                            // Show terms
                          },
                          child: const Text(
                            'الشروط والأحكام',
                            style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Register Button
                  AppButton(
                    text: 'إنشاء الحساب',
                    onPressed: authState.isLoading ? null : _handleRegister,
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('سجّل دخولك'),
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

  Widget _buildRoleChip({
    required String label,
    required String subtitle,
    required UserRole role,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        _onRoleSelected(role);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.grey600,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.grey700,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? color.withAlpha(204) : AppColors.grey500,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}