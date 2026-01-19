// Fichier : /lib/models/user_profile.dart

/// Modèle pour le profil utilisateur
class UserProfile {
  final String profileType;
  final String? dateOfBirth;
  final String city;
  final String country;
  final bool alertsEnabled;
  final int daysWithoutSymptoms;

  UserProfile({
    required this.profileType,
    this.dateOfBirth,
    required this.city,
    required this.country,
    required this.alertsEnabled,
    required this.daysWithoutSymptoms,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileType: json['profile_type'],
      dateOfBirth: json['date_of_birth'],
      city: json['city'],
      country: json['country'],
      alertsEnabled: json['alerts_enabled'] ?? true,
      daysWithoutSymptoms: json['days_without_symptoms'] ?? 0,
    );
  }

  /// Type de profil en français
  String get profileTypeFr {
    switch (profileType) {
      case 'ASTHMATIC':
        return 'Asthmatique';
      case 'PREVENTION':
        return 'Prévention';
      case 'REMISSION':
        return 'Rémission';
      default:
        return profileType;
    }
  }
}

/// Modèle pour l'utilisateur complet
class User {
  final int id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final UserProfile profile; // Add this line

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
    required this.profile, // Add this line
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profile: UserProfile.fromJson(json['profile']), // Add this line
    );
  }

  /// Nom complet de l'utilisateur
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  /// Prénom ou username
  String get displayName => firstName ?? username;

  get createdAt => null;
}