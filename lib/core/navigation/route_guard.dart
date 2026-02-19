class RouteGuard {
  const RouteGuard._();

  static bool canNavigate({required bool isAuthenticated}) => isAuthenticated;
}
