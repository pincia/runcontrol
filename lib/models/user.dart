class User {
  String id;
  String fullName;
  String gender;
  String address;
  String weight;
  String height;
  String email;
  String userRole;
  String profileImagePath;
  String backgroundImagePath;

  User.empty();
  User(this.id, this.fullName,this.gender, this.email, this.userRole,this.weight,this.height,this.address,this.profileImagePath,this.backgroundImagePath);
  
  User.fromData(Map<String, dynamic> data)
      : id = data['id'],
        fullName = data['fullName'],
        gender = data['gender'],
        email = data['email'],
        userRole = data['userRole'],
        weight = data['weight'],
        height = data['height'],
        address = data['address'],
        profileImagePath = data['profileImagePath'],
        backgroundImagePath = data['backgroundImagePath'];
        

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'email': email,
      'userRole': userRole,
      'weight': weight,
      'height':height,
      'address':address,
      'profileImagePath':profileImagePath,
      'backgroundImagePath':backgroundImagePath,
    };
  }

  static cloneUser(User toClone){
    return User(toClone.id, toClone.fullName,toClone.gender, toClone.email, toClone.userRole,toClone.weight,toClone.height,toClone.address,toClone.profileImagePath,toClone.backgroundImagePath);
  }
}