import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/common/app_button.dart';
import '../../../../../shared/widgets/common/app_text_field.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
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
          title: const Text('تغيير كلمة المرور'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  color: AppColors.info.withAlpha(26),
                  child: const Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: Text(
                            'يجب أن تكون كلمة المرور الجديدة قوية وتحتوي على 8 أحرف على الأقل',
                            style: TextStyle(color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXLarge),

                // Current Password
                AppTextField(
                  label: 'كلمة المرور الحالية',
                  hint: 'أدخل كلمة المرور الحالية',
                  controller: _currentPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: AppColors.grey500,
                  ),
                  validator: (value) => Validators.required(value, 'كلمة المرور الحالية'),
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                // New Password
                AppTextField(
                  label: 'كلمة المرور الجديدة',
                  hint: 'أدخل كلمة المرور الجديدة',
                  controller: _newPasswordController,
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
                  label: 'تأكيد كلمة المرور الجديدة',
                  hint: 'أعد إدخال كلمة المرور الجديدة',
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
                    _newPasswordController.text,
                  ),
                  onSubmitted: (_) => _handleChangePassword(),
                ),

                const SizedBox(height: AppDimensions.paddingXLarge),

                // Change Password Button
                AppButton(
                  text: 'تغيير كلمة المرور',
                  icon: Icons.lock,
                  onPressed: authState.isLoading ? null : _handleChangePassword,
                  isLoading: authState.isLoading,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

