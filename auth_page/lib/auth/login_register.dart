import 'package:auth_page/auth/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_page/auth/auth.dart';
import 'package:auth_page/auth/home_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auth_page/auth/google_sign_in.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInEmailAndPassword() async{
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
    } on FirebaseException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createWithEmailAndPassword() async{
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
      );
    } on FirebaseException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print(googleUser?.email);
    if(googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  void signIn() {
    signInWithGoogle();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }
  
  Widget _welcome() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Добро', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
                textAlign: TextAlign.start,
              ),
              Text('пожаловать,', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
                textAlign: TextAlign.start,
              ),
              Text('Авторизуйтесь', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
                textAlign: TextAlign.start,
              ),
            ],
          )
        ],
      )
    );
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      style: GoogleFonts.lato(color: Colors.white),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: title,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12.0)
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12.0)
        )
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Аккаунт жоқ па? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50),
        primary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)
        ),
      ),
        onPressed: isLogin ? signInEmailAndPassword : createWithEmailAndPassword,
        child: Text(isLogin ? 'Войти' : 'Зарегистрироваться', style: TextStyle(color: Colors.blue),),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Регистрация' : 'Есть аккаунт?', style: TextStyle(color: Colors.white),),
    );
  }

  Widget _googleSignIn() {
    return SignInButton(
        Buttons.Google,
        onPressed: signIn,
    );
  }

  @override
  Widget build(BuildContext context) {

    final isKeyboard = MediaQuery.of(context).viewInsets.bottom !=0;

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0x4271B5),
                    Color(0x5E94E1),
                  ]
              )
          ),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!isKeyboard) _welcome(),
                Padding(padding: EdgeInsets.only(bottom: 20.0)),
                _entryField('E-mail', _controllerEmail),
                Padding(padding: EdgeInsets.only(bottom: 10.0)),
                _entryField('Пароль', _controllerPassword),
                Padding(padding: EdgeInsets.only(bottom: 10.0)),
                _submitButton(),
                _errorMessage(),
                _loginOrRegisterButton(),
                _googleSignIn(),
              ],
            ),
          ),
        )
      )
    );
  }
}


