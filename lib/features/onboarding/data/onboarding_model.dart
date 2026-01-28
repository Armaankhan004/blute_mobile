class ProfileRequest {
  final String firstName;
  final String lastName;
  final String dob; // YYYY-MM-DD
  final String address;
  final String locality;
  final String email;
  final String educationQualification;

  ProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.address,
    required this.locality,
    required this.email,
    required this.educationQualification,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'dob': dob,
    'address': address,
    'locality': locality,
    'education_qualification': educationQualification,
    'email': email,
  };
}

class BankRequest {
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String? upiId;

  BankRequest({
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    this.upiId,
  });

  Map<String, dynamic> toJson() => {
    'account_number': accountNumber,
    'bank_name': bankName,
    'branch_name': branchName,
    'ifsc_code': ifscCode,
    'upi_id': upiId,
  };
}
