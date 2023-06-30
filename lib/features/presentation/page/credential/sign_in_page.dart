import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/const.dart';
import 'package:instagram_clone/features/presentation/cubit/credential/credential_cubit.dart';
import 'package:instagram_clone/features/presentation/page/credential/sign_up_page.dart';
import 'package:instagram_clone/features/presentation/widget/button_container_widget.dart';
import 'package:instagram_clone/features/presentation/widget/form_container_widget.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../main_screen/main_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGroundColor,
        body: BlocConsumer<CredentialCubit, CredentialState>(
          listener: (context, credentialState) {
            if (credentialState is CredentialSuccess) {
              BlocProvider.of<AuthCubit>(context).loggedIn();
            }
            if (credentialState is CredentialFailure) {
              toast("Invalid Email & Password");
            }
          },
          builder: (context, credentialState) {

            if (credentialState is CredentialSuccess) {
              return BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is Authenticated) {
                      return MainScreen(uid: authState.uid);
                    } else {
                      return _bodyWidget();
                    }
                  }
              );
            }
            return _bodyWidget();
          },
        ),
    );
  }

  _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(),
            flex: 2,
          ),
          Center(
              child: SvgPicture.asset("assets/holygram.svg",
                  color: primaryColor)),
          sizeVer(30),
          FormContainerWidget(
            controller: _emailController,
            hintText: 'email',
          ),
          sizeVer(15),
          FormContainerWidget(
            controller: _passwordController,
            hintText: 'password',
            isPasswordField: true,
          ),
          sizeVer(15),
          ButtonContainerWidget(
              color: blueColor,
              text: "サインイン",
              onTapListener: () {
                _signInUser();
              }),
          sizeVer(10),
          _isSigningIn == true?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("少々お待ちください", style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w400),),
              sizeHor(10),
              CircularProgressIndicator()
            ],
          ) : Container(width: 0, height: 0,),
          Flexible(
            child: Container(),
            flex: 2,
          ),
          Divider(
            color: secondaryColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "アカウントをまだ作成していない ?",
                style: TextStyle(color: primaryColor),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, PageConst.signUpPage, (route) => false);
                  //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignUpPage()), (route) => false);
                },
                child: Text(
                  "登録",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _signInUser() {
    setState(() {
      _isSigningIn = true;
    });
    BlocProvider.of<CredentialCubit>(context).signInUser(
      email: _emailController.text,
      password: _passwordController.text,
    ).then((value) => _clear());
  }

  _clear() {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _isSigningIn = false;
    });
  }
}
