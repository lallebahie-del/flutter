class AppStrings {
  static String get(String key, String lang) {
    final Map<String, Map<String, String>> values = {
      'login': {
        'fr': 'Connexion',
        'ar': 'تسجيل الدخول',
      },
      'register': {
        'fr': 'Inscription',
        'ar': 'إنشاء حساب',
      },
      'email': {
        'fr': 'Email',
        'ar': 'البريد الإلكتروني',
      },
      'password': {
        'fr': 'Mot de passe',
        'ar': 'كلمة المرور',
      },
      'logout': {
        'fr': 'Déconnexion',
        'ar': 'تسجيل الخروج',
      },
      'user_space': {
        'fr': 'Espace Citoyen',
        'ar': 'فضاء المواطن',
      },
      'admin_space': {
        'fr': 'Espace Admin',
        'ar': 'فضاء الإدارة',
      },
      'welcome_user': {
        'fr': 'Bienvenue citoyen',
        'ar': 'مرحبا بك',
      },
      'welcome_admin': {
        'fr': 'Bienvenue administrateur',
        'ar': 'مرحبا أيها المشرف',
      },
      'forgot_password': {
        'fr': 'Mot de passe oublié ?',
        'ar': 'نسيت كلمة المرور؟',
      },
      'first_name': {
        'fr': 'Prénom',
        'ar': 'الاسم',
      },
      'last_name': {
        'fr': 'Nom',
        'ar': 'اللقب',
      },
      'phone': {
        'fr': 'Téléphone',
        'ar': 'الهاتف',
      },
      'confirm_password': {
        'fr': 'Confirmer le mot de passe',
        'ar': 'تأكيد كلمة المرور',
      },
      'password_mismatch': {
        'fr': 'Les mots de passe ne correspondent pas',
        'ar': 'كلمتا المرور غير متطابقتين',
      },
      'email_used': {
        'fr': 'Email déjà utilisé',
        'ar': 'البريد الإلكتروني مستخدم',
      },
      'weak_password': {
        'fr': 'Mot de passe trop faible',
        'ar': 'كلمة المرور ضعيفة',
      },
      'email_invalid': {
        'fr': 'Email invalide',
        'ar': 'بريد غير صالح',
      },
      'wrong_password': {
        'fr': 'Mot de passe incorrect',
        'ar': 'كلمة المرور غير صحيحة',
      },
      'user_not_found': {
        'fr': 'Compte introuvable',
        'ar': 'الحساب غير موجود',
      },
      'email_not_verified': {
        'fr': 'Email non vérifié',
        'ar': 'البريد غير مفعل',
      },
      'verify_email': {
        'fr': 'Vérifier par email',
        'ar': 'التحقق عبر البريد',
      },
      'verify_phone': {
        'fr': 'Vérifier par téléphone',
        'ar': 'التحقق عبر الهاتف',
      },
      'enter_sms_code': {
        'fr': 'Code SMS',
        'ar': 'رمز الرسالة',
      },
      'verify': {
        'fr': 'Vérifier',
        'ar': 'تحقق',
      },
      'welcome': {
        'fr': 'Bienvenue',
        'ar': 'مرحبا',
      },


    };


    return values[key]?[lang] ?? key;
  }
}
