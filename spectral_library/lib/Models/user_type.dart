enum UserType {
  admin,
  moderator,
  user,
}
extension UserTypeExtension on UserType {
  /// Converts a string to a UserType enum value
  static UserType fromString(String type) {
    return UserType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => throw ArgumentError('Invalid user type: $type'),
    );
  }

  /// Converts a UserType enum value to its string representation
  String toStringValue() {
    return name; // name returns the string representation of the enum
  }
}