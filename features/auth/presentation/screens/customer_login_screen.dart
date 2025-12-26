import 'package:flutter/material.dart';
import 'phone_login_screen.dart';

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.blue,
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'سجّل دخولك بسهولة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Google Sign-In Button
              _SocialButton(
                icon: 'assets/icons/google.svg', // أضف الأيقونة
                label: 'المتابعة بحساب Google',
                onPressed: () {
                  // TODO: Implement Google Sign-In
                },
              ),
              
              const SizedBox(height: 16),
              
              // Apple Sign-In Button (iOS only)
              if (Theme.of(context).platform == TargetPlatform.iOS)
                _SocialButton(
                  icon: 'assets/icons/apple.svg',
                  label: 'المتابعة بحساب Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Implement Apple Sign-In
                  },
                ),
              
              if (Theme.of(context).platform == TargetPlatform.iOS)
                const SizedBox(height: 16),
              
              // Phone Sign-In Button
              _SocialButton(
                icon: 'assets/icons/phone.svg',
                label: 'المتابعة برقم الهاتف',
                backgroundColor: Colors.green,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhoneLoginScreen(),
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // Privacy Policy
              Text(
                'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: backgroundColor == Colors.white
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon would go here - use flutter_svg
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}