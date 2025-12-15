import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  static const String keyLanguage = 'language_code';
  static const String keyRecordLanguage = 'record_language_code';
  static const String keyFirstTime = 'is_first_time';

  static String languageCode = 'en';
  static String recordLanguageCode = 'en-US';
  static bool isFirstTime = true;
  
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString(keyLanguage) ?? 'en';
    recordLanguageCode = prefs.getString(keyRecordLanguage) ?? 'en-US';
    isFirstTime = prefs.getBool(keyFirstTime) ?? true;
    languageNotifier.value = languageCode;
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, code);
    languageCode = code;
    languageNotifier.value = code;
  }

  static Future<void> setRecordLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRecordLanguage, code);
    recordLanguageCode = code;
  }

  static Future<void> setFirstTimeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyFirstTime, false);
    isFirstTime = false;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'ScriptAI',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'add': 'Add',
      'delete': 'Delete',
      'rename': 'Rename',
      'deleteAccount': 'Delete Account',
      'deleteAccountConfirm': 'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.',
      'accountDeleted': 'Account deleted successfully',
      'error': 'Error',
      'success': 'Success',
      'unexpectedError': 'An unexpected error occurred',
      'tryAgain': 'Try again',
      'login': 'LOGIN',
      'signup': 'SIGN-UP',
      'email': 'Email address',
      'password': 'Password',
      'fullName': 'Full Name',
      'forgotPassword': 'Forgot Password?',
      'enterEmailPassword': 'Please enter email and password',
      'loginError': 'Login failed',
      'signupError': 'Signup failed',
      'fillFields': 'Please fill all fields',
      'accountCreatedVerify': 'Account created! Please verify your email.',
      'resetPassword': 'Reset Password',
      'resetPasswordDesc': 'Enter your email address and we will send you a link to reset your password.',
      'sendResetLink': 'Send Reset Link',
      'checkEmail': 'Check your email',
      'resetLinkSent': 'We have sent a password reset link to your email. Please check your inbox (and spam folder).',
      'enterEmail': 'Please enter your email address',
      'homeTitle': 'My Recordings',
      'newCollection': 'New Collection',
      'enterName': 'Enter name',
      'search': 'Search...',
      'noCollections': 'No collections yet',
      'settings': 'Settings',
      'profile': 'My Profile',
      'logout': 'Logout',
      'confirmDelete': 'Are you sure you want to delete this?',
      'restartApp': 'Restart app for full effect',
      'recording': 'Recording...',
      'paused': 'Paused',
      'processing': 'Processing...',
      'summary': 'Summary',
      'transcript': 'Transcript',
      'summarizeBtn': 'Summarize with AI',
      'exportPdf': 'Export PDF',
      'appLang': 'App Language',
      'recordLang': 'Recording Language',
      'getStarted': 'Get Started',
      'speedLearning': 'Speed your learning process',
      'meetings': 'Meetings',
      'processDone': 'Process Done',
      'backHome': 'Home Page',
      'generatingSummary': 'Generating Summary...',
      'noRecordings': 'No recordings yet',
      'noAudioDetected': 'No audio detected',
      'uploadAudio': 'Upload Audio',
      'recordAudio': 'Record Audio',
      'chooseOption': 'Choose Option',
      'transcribing': 'Transcribing Audio...',
      'myProfileTitle': 'My profile',
      'editProfile': 'Edit Profile',
      'nameLabel': 'Name',
      'emailLabel': 'Email',
      'phoneLabel': 'Phone',
      'contactSupport': 'Contact support to change email',
      'profileUpdated': 'Profile updated successfully!',
      'errorLoadingProfile': 'Error loading profile',
      'errorUpdatingProfile': 'Error updating profile',
      'noInternetTitle': 'No Internet Connection',
      'noInternetDesc': 'Your internet connection is currently not available please check or try again.',
      'aboutUs': 'About Us',
      'ourMission': 'Our Mission',
      'missionText': 'ScriptAI helps you transcribe and summarize your meetings effortlessly using advanced AI technology. We aim to make productivity accessible to everyone.',
      'version': 'Version',
      'contactUs': 'Contact Us',
      'rights': '© 2025 ScriptAI. All rights reserved.',
      'renameMeeting': 'Rename Meeting',
      'options': 'Options',
      'confirmDeleteAccount': 'Warning: This will permanently delete your account and all associated data.',
    },
    'ar': {
      'welcome': 'ScriptAI',
      'ok': 'حسناً',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'add': 'إضافة',
      'delete': 'حذف',
      'rename': 'إعادة تسمية',
      'deleteAccount': 'حذف الحساب',
      'deleteAccountConfirm': 'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه وسيتم فقد جميع بياناتك.',
      'accountDeleted': 'تم حذف الحساب بنجاح',
      'error': 'خطأ',
      'success': 'نجاح',
      'unexpectedError': 'حدث خطأ غير متوقع',
      'tryAgain': 'حاول مرة أخرى',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'fullName': 'الاسم الكامل',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'enterEmailPassword': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      'loginError': 'فشل تسجيل الدخول',
      'signupError': 'فشل إنشاء الحساب',
      'fillFields': 'يرجى ملء جميع الحقول',
      'accountCreatedVerify': 'تم إنشاء الحساب! يرجى التحقق من بريدك الإلكتروني.',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'resetPasswordDesc': 'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
      'sendResetLink': 'إرسال الرابط',
      'checkEmail': 'تحقق من بريدك',
      'resetLinkSent': 'لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يرجى التحقق من صندوق الوارد (والبريد العشوائي).',
      'enterEmail': 'يرجى إدخال عنوان بريدك الإلكتروني',
      'homeTitle': 'تسجيلاتي',
      'newCollection': 'مجموعة جديدة',
      'enterName': 'أدخل الاسم',
      'search': 'بحث...',
      'noCollections': 'لا توجد مجموعات بعد',
      'settings': 'الإعدادات',
      'profile': 'ملفي الشخصي',
      'logout': 'تسجيل خروج',
      'confirmDelete': 'هل أنت متأكد من الحذف؟',
      'restartApp': 'يرجى إعادة تشغيل التطبيق لتطبيق التغييرات بالكامل',
      'recording': 'جاري التسجيل...',
      'paused': 'مؤقت',
      'processing': 'جاري المعالجة...',
      'summary': 'التلخيص',
      'transcript': 'النص الكامل',
      'summarizeBtn': 'تلخيص بالذكاء الاصطناعي',
      'exportPdf': 'تصدير PDF',
      'appLang': 'لغة التطبيق',
      'recordLang': 'لغة التسجيل',
      'getStarted': 'ابدأ الآن',
      'speedLearning': 'سرع عملية تعلمك',
      'meetings': 'الاجتماعات',
      'processDone': 'تمت المعالجة بنجاح',
      'backHome': 'الرئيسية',
      'generatingSummary': 'جاري التلخيص...',
      'noRecordings': 'لا يوجد تسجيلات بعد',
      'noAudioDetected': 'لم يتم اكتشاف صوت',
      'uploadAudio': 'رفع ملف صوتي',
      'recordAudio': 'تسجيل صوتي',
      'chooseOption': 'اختر طريقة',
      'transcribing': 'جاري تحويل الصوت...',
      'myProfileTitle': 'ملفي الشخصي',
      'editProfile': 'تعديل الملف الشخصي',
      'nameLabel': 'الاسم',
      'emailLabel': 'البريد الإلكتروني',
      'phoneLabel': 'الهاتف',
      'contactSupport': 'تواصل مع الدعم لتغيير البريد الإلكتروني',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح!',
      'errorLoadingProfile': 'خطأ في تحميل الملف الشخصي',
      'errorUpdatingProfile': 'خطأ في تحديث الملف الشخصي',
      'noInternetTitle': 'لا يوجد اتصال بالإنترنت',
      'noInternetDesc': 'اتصال الإنترنت غير متوفر حالياً، يرجى التحقق والمحاولة مرة أخرى.',
      'aboutUs': 'من نحن',
      'ourMission': 'مهمتنا',
      'missionText': 'يساعدك ScriptAI على نسخ وتلخيص اجتماعاتك بسهولة باستخدام تقنيات الذكاء الاصطناعي المتقدمة. نهدف إلى جعل الإنتاجية متاحة للجميع.',
      'version': 'الإصدار',
      'contactUs': 'اتصل بنا',
      'rights': '© 2025 ScriptAI. جميع الحقوق محفوظة.',
      'renameMeeting': 'إعادة تسمية الاجتماع',
      'options': 'خيارات',
      'confirmDeleteAccount': 'تنبيه: سيؤدي هذا إلى حذف حسابك وجميع بياناتك نهائياً.',
    },
  };

  static String get(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  static bool get isArabic => languageCode == 'ar';
}