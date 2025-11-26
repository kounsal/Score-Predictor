// API Configuration and Endpoints
class ApiConstants {
  // Base URL - Update this with your actual API URL
  static const String baseUrl = 'http://3.7.73.47:4000';
  
  // API Endpoints
  static const String home = '/';
  static const String records = '/api/records';
  static const String stats = '/api/records/stats';
  static const String trainModel = '/api/model/train';
  static const String modelInfo = '/api/model/info';
  static const String predict = '/api/predict';
  static const String predictBatch = '/api/predict/batch';
  
  // Full URLs
  static String get homeUrl => '$baseUrl$home';
  static String get recordsUrl => '$baseUrl$records';
  static String get statsUrl => '$baseUrl$stats';
  static String get trainModelUrl => '$baseUrl$trainModel';
  static String get modelInfoUrl => '$baseUrl$modelInfo';
  static String get predictUrl => '$baseUrl$predict';
  static String get predictBatchUrl => '$baseUrl$predictBatch';
  
  // HTTP Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}
