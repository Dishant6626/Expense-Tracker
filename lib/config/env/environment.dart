// lib/config/env/environment.dart

class Environment {
  static const String dev = 'dev';
  static const String prod = 'prod';

  static final Environment _instance = Environment._internal();
  factory Environment() => _instance;
  Environment._internal();

  late EnvConfig config;

  void initConfig(String environment) {
    config = environment == dev ? DevConfig() : ProdConfig();
  }
}

abstract class EnvConfig {
  String get apiHost;
  String get geminiApiKey;
  bool get useRestApi;
}

class DevConfig extends EnvConfig {
  @override
  String get apiHost => 'https://api.dev.example.com';

  @override
  // Replace with your actual Gemini API key
  String get geminiApiKey => 'YOUR_GEMINI_API_KEY';

  @override
  bool get useRestApi => true;
}

class ProdConfig extends EnvConfig {
  @override
  String get apiHost => 'https://api.example.com';

  @override
  String get geminiApiKey => 'YOUR_GEMINI_API_KEY';

  @override
  bool get useRestApi => true;
}
