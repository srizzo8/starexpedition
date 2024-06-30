class User{
  final int id;
  final String username;
  final String emailAddress;
  final String password;
  final String usernameLowercased;

  const User({
    required this.id,
    required this.username,
    required this.emailAddress,
    required this.password,
    required this.usernameLowercased
  });

  toJson(){
    return{
      "id": id,
      "username": username,
      "emailAddress": emailAddress,
      "password": password,
      "usernameLowercased": usernameLowercased
    };
  }
}