import 'package:frontend/models/user_details/gender.dart';

class ProfileDetails {
  final Gender gender;
  final double height;
  final double weight;
  final DateTime dateOfBirth;

  ProfileDetails({
    required this.gender,
    required this.height,
    required this.weight,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
    'gender': gender,
    'height': height,
    'weight': weight,
    'date_of_birth': dateOfBirth,
  };
}
