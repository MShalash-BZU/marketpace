import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://qsperqoeifiuovqnqgjq.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_5d7uru0XA__ENqzaVz68vg_ZlzmBcbD';

  // Google Sign-In Configuration
  static final GoogleSignIn googleSignIn = GoogleSignIn(
    // احصل على Web Client ID من Google Cloud Console
    clientId:
        '33685611762-m2d3drrltj1asca9lnhjebf1iv1kcq5d.apps.googleusercontent.com.apps.googleusercontent.com',
    serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
  }
}
