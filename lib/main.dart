import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bin/controllers/authentication/authentication_bloc.dart';
import 'package:smart_bin/controllers/container/container_bloc.dart';
import 'package:smart_bin/controllers/maps/maps_bloc.dart';
import 'package:smart_bin/services/api.dart';
import 'package:smart_bin/utils/init.dart';
import 'package:smart_bin/views/home.dart';
import 'package:smart_bin/views/login.dart';
import 'package:smart_bin/views/map.dart';
import 'package:smart_bin/views/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api().getNearbyContainers(33.847662, 10.094515);
  //await Api().getAllContainers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MapsBloc()),
        BlocProvider(
            create: (context) => AuthenticationBloc()..add(GetUSerEvent())),
        BlocProvider(create: (context) => ContainerBloc())
      ],
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: state is AuthenticationFailure ? Login() : Home(),
          );
        },
      ),
    );
  }
}
