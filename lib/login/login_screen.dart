import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:RunControl/user_repository.dart';
import 'package:RunControl/login/login.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(title: Text('Login')),
    backgroundColor:  Color(0xff212121),
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginForm(userRepository: _userRepository),
      ),
    );
  }
}
