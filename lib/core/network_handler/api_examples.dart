// Example: How to use all HTTP methods in your repository/datasource

import 'package:loan_poc/core/network_handler/base_api_service.dart';

class ExampleApiRepository {
  final BaseApiService _apiService;

  ExampleApiRepository(this._apiService);

  /// Example 1: GET - Fetch list of users
  /// Request: GET /users?page=1&limit=10
  /// Response: List of users
  Future<List<dynamic>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/users',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Example 2: POST - Create new resource
  /// Request: POST /users
  /// Body: { "name": "John", "email": "john@example.com" }
  /// Response: Created user object
  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        '/users',
        body: {'name': name, 'email': email},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Example 3: PUT - Replace entire resource
  /// Request: PUT /users/{id}
  /// Body: { "name": "Jane", "email": "jane@example.com" }
  /// Response: Updated user object
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiService.put(
        '/users/$userId',
        body: {'name': name, 'email': email},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Example 4: PATCH - Partial update to resource
  /// Request: PATCH /users/{id}
  /// Body: { "email": "newemail@example.com" }
  /// Response: Updated user object
  Future<Map<String, dynamic>> updateUserEmail({
    required String userId,
    required String email,
  }) async {
    try {
      final response = await _apiService.patch(
        '/users/$userId',
        body: {'email': email},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Example 5: DELETE - Remove resource
  /// Request: DELETE /users/{id}
  /// Response: Success message or empty
  Future<void> deleteUser({required String userId}) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Example 6: HEAD - Get headers only (no body)
  /// Request: HEAD /users/{id}
  /// Response: Headers only (useful for checking if resource exists)
  Future<bool> userExists({required String userId}) async {
    try {
      await _apiService.head('/users/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Key Differences:

/// GET - Retrieve data
/// - Used for: Fetching data
/// - Has body: No
/// - Idempotent: Yes
/// - Safe: Yes
/// - Cacheable: Yes
///
/// POST - Create new resource
/// - Used for: Creating new data
/// - Has body: Yes
/// - Idempotent: No
/// - Safe: No
/// - Cacheable: No
///
/// PUT - Replace entire resource
/// - Used for: Replacing entire resource
/// - Has body: Yes
/// - Idempotent: Yes
/// - Safe: No
/// - Cacheable: No
/// - Note: If resource doesn't exist, it may create it
///
/// PATCH - Partial update
/// - Used for: Partial updates
/// - Has body: Yes
/// - Idempotent: Depends on implementation
/// - Safe: No
/// - Cacheable: No
///
/// DELETE - Remove resource
/// - Used for: Deleting data
/// - Has body: Usually no (but can have)
/// - Idempotent: Yes
/// - Safe: No
/// - Cacheable: No
///
/// HEAD - Like GET but no response body
/// - Used for: Checking if resource exists, getting headers
/// - Has body: No
/// - Idempotent: Yes
/// - Safe: Yes
/// - Cacheable: Yes
