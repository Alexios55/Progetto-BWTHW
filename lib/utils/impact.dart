class ImpactConfig {
  const ImpactConfig._();

  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String pingEndpoint = 'gate/v1/ping/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';
}

// Same values used in lesson_18-authentication/impact_authentication.
// Kept here as the central endpoint configuration for the IMPACT service.
