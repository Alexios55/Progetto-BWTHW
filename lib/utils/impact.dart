class ImpactConfig {
  const ImpactConfig._();

  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';

  static const String pingEndpoint = 'gate/v1/ping/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';

  // Username e password per ottenere il token
  // Qui devi mettere lo username dell'Excel, NON quello del paziente
  static String username = '5UJpUCxIUn';
  static String password = '12345678!';

  // Username del paziente da usare per prendere i dati
  static String patientUsername = 'Jpefaq6m58';

  static String distanceEndpoint = 'data/v1/distance/patients/';
  static String sleepEndpoint = 'data/v1/sleep/patients/';
  static String stepsEndpoint = 'data/v1/steps/patients/';
  static String caloriesEndpoint = 'data/v1/calories/patients/';
}