class AppConstants {
  AppConstants._();

  static const String appName     = 'ScanVerse AI';
  static const String appVersion  = '1.0.0';
  static const String dbName      = 'scanverse.db';
  static const int    dbVersion   = 1;

  // Tables
  static const String tableScans  = 'scans';
  static const String tablePdfs   = 'pdfs';

  // Assets
  static const String animScan    = 'assets/animations/scan_anim.json';
  static const String animProcess = 'assets/animations/processing.json';
  static const String imgOnboard1 = 'assets/images/onboard1.png';

  // Shared Prefs Keys
  static const String keyThemeMode     = 'theme_mode';
  static const String keyOnboardDone   = 'onboard_done';
  static const String keyPremium       = 'is_premium';
}
