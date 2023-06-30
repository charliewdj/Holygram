import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/const.dart';
import 'package:instagram_clone/features/domain/entities/user/user_entity.dart';
import 'package:instagram_clone/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:instagram_clone/features/presentation/cubit/credential/credential_cubit.dart';
import 'package:instagram_clone/features/presentation/page/credential/sign_in_page.dart';
import 'package:instagram_clone/features/presentation/page/main_screen/main_screen.dart';
import 'package:instagram_clone/features/presentation/widget/button_container_widget.dart';
import 'package:instagram_clone/features/presentation/widget/form_container_widget.dart';
import 'package:instagram_clone/profile_widget.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({Key? key}) : super(key:key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  File? _image;

  Future selectImage() async {
    try {
      final pickedFile = await ImagePicker.platform.getImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("no image has been selected");
        }
      });

    } catch(e) {
      toast("some error occured $e");
    }
  }

  @override
  Widget build(BuildContext context){
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
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10 ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(),
            flex: 2,
          ),
          Center(child: SvgPicture.asset("assets/holygram.svg" , color:primaryColor)),
          sizeVer(15),
          Center(
              child: Stack(
                children: [
                  Container(
                    width:60,
                    height:60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(30), child: profileWidget(image: _image, ),),
                  ),
                  Positioned(
                      right: -10,
                      bottom: -15,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(Icons.add_a_photo, color: blueColor,),
                      )
                  )
                ],
              )
          ),
          sizeVer(30),
          FormContainerWidget(
            controller: _usernameController,
            hintText: 'Username',
          ),
          sizeVer(15),
          FormContainerWidget(
            controller: _emailController,
            hintText: 'Email',
          ),
          sizeVer(15),
          FormContainerWidget(
            controller: _passwordController,
            hintText: 'Password',
            isPasswordField: true,
          ),
          sizeVer(15),
          FormContainerWidget(
            controller: _bioController,
            hintText: 'Bio',
            isPasswordField: true,
          ),
          sizeVer(15),
          ButtonContainerWidget(
              color: blueColor,
              text: "登録",
              onTapListener: () {
                _signUpUser();
              }
          ),
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
              Text("既にアカウントを作成した方? ", style: TextStyle(color: primaryColor),),
              InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, PageConst.signInPage, (route) => false);
                  //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInPage()), (route) => false);
                },
                child:  Text(
                  "サインイン",
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }



  void _signUpUser() {
    setState(() {
      _isSigningIn = true;
    });
    BlocProvider.of<CredentialCubit>(context).signUpUser(
      user: UserEntity(
        email: _emailController.text,
        password: _passwordController.text,
        bio: _bioController.text,
        username: _usernameController.text,
        totalPosts: 0,
        totalFollowing: 0,
        followers: [],
        totalFollowers: 0,
        profileUrl: "",
        following: [],
        name: "",
        imageFile: _image,
      ),
    ).then((value) => _clear());
  }

  _clear() {
    setState(() {
      _usernameController.clear();
      _bioController.clear();
      _emailController.clear();
      _passwordController.clear();
      _isSigningIn = false;
    });
  }
}