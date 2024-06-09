class User{
  final int id;
  final String username;
  final String emailAddress;
  final String password;

  const User({
    required this.id,
    required this.username,
    required this.emailAddress,
    required this.password
  });

  toJson(){
    return{
      "id": id,
      "username": username,
      "emailAddress": emailAddress,
      "password": password
    };
  }
}