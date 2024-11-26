import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bin/controllers/authentication/authentication_bloc.dart';
import 'package:smart_bin/views/login.dart';
import 'package:smart_bin/widgets/custom_button.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Login()));
          } else if (state is LogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Sign Out Failed please try again"),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: SafeArea(
          child: Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/recycle-bin.png",
                    width: 150,
                  ),
                  Text(
                    "Smart Bin",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "Smart Bin is a recycle bin mobile app the locate bins on a specific area with their id and their volume which helps user to easly find nearby containers ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  CustomButton(
                    text: "Sign Out",
                    onPressed: () =>
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(SignOutUser()),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
