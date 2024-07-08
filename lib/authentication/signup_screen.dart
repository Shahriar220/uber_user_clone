import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_user_app/authentication/login_screen.dart';
import 'package:uber_user_app/methods/common.dart';
import 'package:uber_user_app/pages/home_page.dart';
import 'package:uber_user_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController =
      TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();

  CommonMethods methods = CommonMethods();

  checkIfNetworkIsAvailable() {
    methods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (nameTextEditingController.text.trim().length < 3) {
      methods.displaySnackBar("name must be more than 3 character", context);
    } else if (phoneNumberTextEditingController.text.trim().length < 11) {
      methods.displaySnackBar(
          "phone number must be more than 11 character", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      methods.displaySnackBar("enter a valid email", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      methods.displaySnackBar(
          "password must be more that 5 characters", context);
    } else {
      registerNewUser();
    }
  }

  registerNewUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Registering Your Account"));

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
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

    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap = {
      "name": nameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": phoneNumberTextEditingController.text.trim(),
      "id": userFirebase?.uid,
      "blockStatus": "no",
    };

    usersRef.set(userDataMap);
    Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
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
                "Create a User\'s account",
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
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "User Name",
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      TextField(
                        controller: phoneNumberTextEditingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
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
                        child: const Text("SignUp"),
                      )
                    ],
                  )),
              const SizedBox(
                height: 12,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Already Have an Account? Login Here",
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
