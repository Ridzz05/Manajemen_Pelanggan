// Production configuration constants
class AppConfig {
  // Set to true for production builds
  static const bool isProduction = true;

  // App metadata
  static const String appName = 'CRM';
  static const String appVersion = '1.0.0';

  // Database configuration
  static const String databaseName = 'awb_management.db';
  static const int databaseVersion = 5;

  // Performance optimizations
  static const bool enablePerformanceOptimizations = true;

  // Security settings
  static const bool enableSecurityFeatures = true;

  // API configurations (if applicable)
  static const String apiBaseUrl = '';

  // Logging configuration
  static const bool enableLogging = false; // Disabled for production
  static const bool enableErrorReporting = true;

  // Feature flags
  static const bool enableAdvancedFeatures = true;
  static const bool enableAnalytics = false; // Disabled for privacy
}
