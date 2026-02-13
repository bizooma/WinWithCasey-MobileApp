class AppAuthUser {
  final String id;
  final String? email;
  final bool isEmailVerified;

  const AppAuthUser({required this.id, required this.email, required this.isEmailVerified});

  @override
  String toString() => 'AuthUser(id: $id, email: $email, verified: $isEmailVerified)';
}
