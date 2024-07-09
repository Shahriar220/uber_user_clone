import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_user_app/authentication/signup_screen.dart';
import 'package:uber_user_app/global/global_var.dart';

import '../methods/common.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  CommonMethods methods = CommonMethods();

  checkIfNetworkIsAvailable() {
    methods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      methods.displaySnackBar("enter a valid email", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      methods.displaySnackBar(
          "password must be more that 5 characters", context);
    } else {
      logInUser();
    }
  }

  logInUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Login to Your Account"));

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError((errorMessage) {
      Navigator.pop(context);
      methods.displaySnackBar(errorMessage, context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userFirebase.uid);

      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const HomePage()));
          } else {
            FirebaseAuth.instance.signOut();
            methods.displaySnackBar(
                "You are not authorised, contact support", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          methods.displaySnackBar("No User Found", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              Text(
                "Log in to account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //text fields + button
              Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "User Email",
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      TextField(
                        controller: passwordTextEditingController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "User password",
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 10)),
                        child: const Text("LogIn"),
                      )
                    ],
                  )),
              const SizedBox(
                height: 12,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const SignUpScreen()));
                },
                child: const Text(
                  "No account Here? SignUp Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//AIzaSyCC1PBvMcq3Xj3hQF-WiPwuHqFqGFWrP1c
//AIzaSyCqWolz3UkTu44xWaEA_vnAd3sH6hZn3lI
