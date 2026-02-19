/// Abstract base service for all API operations
/// Defines contract for HTTP methods: GET, POST, PUT, PATCH, DELETE
abstract class BaseApiService {
  /// GET request - retrieve resources
  /// [path] - API endpoint path
  /// [queryParameters] - optional URL query parameters
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });

  /// POST request - create new resources
  /// [path] - API endpoint path
  /// [body] - request payload
  /// [queryParameters] - optional URL query parameters
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  /// PUT request - replace entire resource
  /// [path] - API endpoint path
  /// [body] - request payload with complete data
  /// [queryParameters] - optional URL query parameters
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  /// PATCH request - partial update to resource
  /// [path] - API endpoint path
  /// [body] - request payload with partial data
  /// [queryParameters] - optional URL query parameters
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  /// DELETE request - remove resources
  /// [path] - API endpoint path
  /// [queryParameters] - optional URL query parameters
  /// [body] - optional request payload
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  });

  /// HEAD request - retrieve headers without body
  /// [path] - API endpoint path
  /// [queryParameters] - optional URL query parameters
  Future<dynamic> head(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}
