// // ignore_for_file: prefer_const_constructors

// import 'package:chat_app/models/UIHelper.dart';
// import 'package:chat_app/pages/CompleteProfilePage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import '../models/UserModel.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController cPasswordController = TextEditingController();
//   bool isLoading = false;

//   void checkValues() {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//     String cPassword = cPasswordController.text.trim();

//     if (email == "" || password == "" || cPassword == "") {
//       UIHelper.showAlertDialog(
//           context, "Incomplete Data", "please fill all the fields");
//     } else if (password != cPassword) {
//       UIHelper.showAlertDialog(
//           context, "Password Mimatch", "The Password you entered do not match");
//     } else {
//       signUp(email, password);
//     }
//   }

//   void signUp(String email, String password) async {
//     // setState(() {
//     //   isLoading = true;
//     // });

//     UIHelper.showAlertDialog(context, "Creating new account..");

//     try {
//       UserCredential credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       String uid = credential.user!.uid;
//       UserModel newUser =
//           UserModel(uid: uid, email: email, fullname: "", profilepic: "");

//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(uid)
//           .set(newUser.toMap())
//           .then(
//         (value) {
//           showSnackBar("New User Created!");
//           Navigator.popUntil(context, (route) => route.isFirst);
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) {
//                 return CompleteProfilePage(
//                     userModel: newUser, firebaseUser: credential.user!);
//               },
//             ),
//           );
//         },
//       );
//     } on FirebaseAuthException catch (ex) {
//       showSnackBar(ex.message ?? "An error occurred. Please try again.");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void showSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Text(
//                     "Chat App",
//                     style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   TextField(
//                     controller: emailController,
//                     decoration: InputDecoration(labelText: "Email Address"),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   TextField(
//                     controller: passwordController,
//                     obscureText: true,
//                     decoration: InputDecoration(labelText: "Password"),
//                   ),
//                   TextField(
//                     controller: cPasswordController,
//                     obscureText: true,
//                     decoration: InputDecoration(labelText: "Confirm Password"),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   isLoading
//                       ? CircularProgressIndicator()
//                       : CupertinoButton(
//                           child: Text('Sign Up'),
//                           onPressed: checkValues,
//                           color: Colors.blue,
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Already have an account?",
//               style: TextStyle(fontSize: 16),
//             ),
//             CupertinoButton(
//                 child: Text(
//                   "Log In",
//                   style: TextStyle(fontSize: 16, color: Colors.blue),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:chat_app/pages/CompleteProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UIHelper.dart';
import '../models/UserModel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The passwords you entered do not match!");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingdialog(context, "Creating new account..");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CompleteProfilePage(
                userModel: newUser, firebaseUser: credential!.user!);
          }),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email Address"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Confirm Password"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Log In",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
