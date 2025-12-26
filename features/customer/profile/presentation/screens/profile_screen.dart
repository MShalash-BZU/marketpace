import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/widgets/common/app_button.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/screens/login_screen.dart';
import '../../../../auth/domain/entities/user.dart' as auth_user;
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    ref.listenManual(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && next.isAuthenticated == false && mounted) {
        // User logged out, navigate to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Center(child: Text('لم يتم العثور على المستخدم'));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, user, ref),
              
              const SizedBox(height: AppDimensions.paddingXLarge),

              // Profile Info Card
              _buildProfileInfoCard(context, user),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Action Buttons
              _buildActionButtons(context, ref),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Settings Section
              _buildSettingsSection(context, ref, user),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Logout Button
              _buildLogoutButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, WidgetRef ref) {
    return Column(
      children: [
        // Profile Image
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: user.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.profileImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.white,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 20, color: AppColors.white),
                  onPressed: () {
                    // TODO: Add image picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً: تغيير الصورة الشخصية')),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (user.email != null) ...[
          const SizedBox(height: AppDimensions.paddingTiny),
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
        ],
        const SizedBox(height: AppDimensions.paddingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role).withAlpha(26),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: _getRoleColor(user.role).withAlpha(77),
            ),
          ),
          child: Text(
            _getRoleText(user.role),
            style: TextStyle(
              color: _getRoleColor(user.role),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: Icons.phone,
              label: 'رقم الجوال',
              value: Formatters.formatPhoneNumber(user.phone),
            ),
            const Divider(height: AppDimensions.paddingXLarge),
            _buildInfoRow(
              context,
              icon: Icons.email,
              label: 'البريد الإلكتروني',
              value: user.email ?? 'غير متوفر',
            ),
            const Divider(height: AppDimensions.paddingXLarge),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: 'تاريخ الإنشاء',
              value: Formatters.formatFullDate(user.createdAt),
            ),
            if (user.lastLoginAt != null) ...[
              const Divider(height: AppDimensions.paddingXLarge),
              _buildInfoRow(
                context,
                icon: Icons.access_time,
                label: 'آخر تسجيل دخول',
                value: Formatters.formatRelativeDate(user.lastLoginAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppButton(
          text: 'تعديل الملف الشخصي',
          icon: Icons.edit,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            );
          },
          isFullWidth: true,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        AppButton(
          text: 'تغيير كلمة المرور',
          icon: Icons.lock,
          type: AppButtonType.outline,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen(),
              ),
            );
          },
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.primary),
            title: const Text('الإشعارات'),
            trailing: Switch(
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Save settings
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('اللغة'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('العربية'),
                SizedBox(width: AppDimensions.paddingSmall),
                Icon(Icons.chevron_left, color: AppColors.grey400),
              ],
            ),
            onTap: () {
              // TODO: Language picker
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.primary),
            title: const Text('الوضع الليلي'),
            trailing: Switch(
              value: false, // TODO: Get from theme provider
              onChanged: (value) {
                // TODO: Toggle dark mode
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('مساعدة ودعم'),
            trailing: const Icon(Icons.chevron_left, color: AppColors.grey400),
            onTap: () {
              // TODO: Help screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('حول التطبيق'),
            trailing: const Icon(Icons.chevron_left, color: AppColors.grey400),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Marketplace',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.shopping_bag, size: 48),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return AppButton(
      text: 'تسجيل الخروج',
      icon: Icons.logout,
      type: AppButtonType.danger,
      onPressed: () {
        _showLogoutDialog(context, ref);
      },
      isFullWidth: true,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              // Navigation will be handled by the listener in initState
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(auth_user.UserRole role) {
    switch (role) {
      case auth_user.UserRole.customer:
        return AppColors.primary;
      case auth_user.UserRole.storeOwner:
        return AppColors.success;
      case auth_user.UserRole.courier:
        return AppColors.warning;
      case auth_user.UserRole.admin:
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  String _getRoleText(auth_user.UserRole role) {
    switch (role) {
      case auth_user.UserRole.customer:
        return 'عميل';
      case auth_user.UserRole.storeOwner:
        return 'صاحب محل';
      case auth_user.UserRole.courier:
        return 'سائق توصيل';
      case auth_user.UserRole.admin:
        return 'مدير';
      default:
        return 'مستخدم';
    }
  }
}

