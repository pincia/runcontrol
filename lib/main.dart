import 'package:RunControl/pages/Tabs.dart';
import 'package:RunControl/pages/activities.dart';
import 'package:RunControl/pages/edit-profile.dart';
import 'package:RunControl/pages/endrunpage.dart';
import 'package:RunControl/pages/itineraries.dart';
import 'package:RunControl/pages/map.dart';
import 'package:RunControl/pages/prerunpage.dart';
import 'package:RunControl/pages/stats.dart';
import 'package:RunControl/simple_bloc_delegate.dart';
import 'package:RunControl/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:RunControl/authentication_bloc/authentication_bloc.dart';
import 'package:RunControl/user_repository.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'login/login_screen.dart';
import 'models/appstate.dart';
import 'models/reducer.dart';
import 'models/run.dart';
import 'pages/run.dart';

void main() {
  final _initialState = AppState(user: null, runStatus: RunStatus(true));
  final Store<AppState> _store =
      Store<AppState>(reducer, initialState: _initialState);

  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) =>
          AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
      child: App(
        userRepository: userRepository,
        store: _store,
      ),
    ),
  );
}

class App extends StatefulWidget {
  final UserRepository _userRepository;
  final Store<AppState> _store;
  App(
      {Key key,
      @required UserRepository userRepository,
      @required Store<AppState> store})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _store = store,
        super(key: key);

  @override
  _AppState createState() => _AppState(_userRepository, _store);
}

class _AppState extends State<App> {
  var userRepository;
  Store<AppState> store;

  _AppState(this.userRepository, this.store);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return LoginScreen(userRepository: userRepository);
            }
            if (state is Authenticated) {
              StoreProvider.of<AppState>(context).dispatch(SetUser(state.user));
              return Tabs();
            }
            return SplashScreen();
          },
        ),
        routes: <String, WidgetBuilder>{
          '/itineraries': (context) => Itineraries(),
          '/stats': (context) => StatsPage(),
          '/run': (context) => RunPage(),
          '/map': (context) => MapPage(),
          '/prerun': (context) => PreRunPage(),
          '/editprofile': (context) => EditProfile(),
          '/endrun': (context) => EndRunPage(),
        '/activities': (context) => ActivitiesPage(),
        },
      ),
    );
  }
}


class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}