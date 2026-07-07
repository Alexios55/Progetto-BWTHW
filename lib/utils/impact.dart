class ImpactConfig {
  const ImpactConfig._();

  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String pingEndpoint = 'gate/v1/ping/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';

  static String username = '5UJpUCxIUn';
  static String password = '12345678!';
  static String patientUsername = 'IL_PAZIENTE_ASSOCIATO';

  static String heartrateEndpoint = 'data/v1/heartrate/patients/';
  static String sleepEndpoint = 'data/v1/sleep/patients/';
  
}

// Same values used in lesson_18-authentication/impact_authentication.
// Kept here as the central endpoint configuration for the IMPACT service.
