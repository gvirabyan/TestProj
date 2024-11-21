class UserInfoModel {
  final String name;
  final String username;
  final String phoneNumber;
  final String companyName;
  final String car;
  final String registrationDate;
  final String driverLicenseNumber;

  UserInfoModel({
    required this.name,
    required this.username,
    required this.phoneNumber,
    required this.companyName,
    required this.car,
    required this.registrationDate,
    required this.driverLicenseNumber,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
        name: json['name'],
        username: json['username'],
        phoneNumber: json['phone_number'],
        companyName: json['company_name'],
        car: json['car'],
        registrationDate: json['registration_date'],
        driverLicenseNumber: json['driver_license_number']);
  }

  @override
  String toString() {
    return 'UserInfoModel{name: $name, username: $username, phone_number: $phoneNumber, company_name: $companyName, car: $car, registration_date: $registrationDate, driver_license_number: $driverLicenseNumber}';
  }
}
