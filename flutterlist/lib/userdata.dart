class UserData {
  String nama;
  int npm;
  String email;

  UserData(this.nama, this.npm, this.email);

  Map<String, dynamic> toJson() {
    return {
      "nama": this.nama,
      "npm": this.npm,
      "email": this.email
    };
  }
}
