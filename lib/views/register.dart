import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bin/controllers/authentication/authentication_bloc.dart';
import 'package:smart_bin/views/home.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        } else if (state is AuthenticationFailure) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthenticationLoading) {
          showDialog(
              context: context,
              builder: (context) {
                return  AlertDialog(
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text("Loading..."),
                    ],
                  ),
                );
              });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SafeArea(
                    child: Image.asset(
                      "assets/images/recycle-bin.png",
                      width: 200,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Create Account",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: nameController,
                  hint: "username",
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  controller: emailController,
                  hint: "email",
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  controller: passwordController,
                  hint: "password",
                  obscured: true,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: CustomButton(
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context).add(
                        RegisterEvent(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                      );
                    },
                    text: "Register",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
