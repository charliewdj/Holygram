import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/const.dart';
import 'package:instagram_clone/features/domain/entities/posts/post_entity.dart';
import 'package:instagram_clone/features/presentation/cubit/post/post_cubit.dart';
import 'package:instagram_clone/features/presentation/page/home/widgets/single_post_card_widget.dart';
import 'package:instagram_clone/features/presentation/page/post/comment/comment_page.dart';
import 'package:instagram_clone/features/presentation/page/post/update_post_page.dart';
import 'package:instagram_clone/injection_container.dart' as di;

import '../../../domain/usecases/firebase_usecases/user/get_current_uid_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: backGroundColor,
        title: SvgPicture.asset(
          "assets/holygram.svg", color: primaryColor, height: 32,),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              MaterialCommunityIcons.facebook_messenger, color: primaryColor,),
          )
        ],
      ),
      body: BlocProvider<PostCubit>(
        create: (context) => di.sl<PostCubit>()..getPosts(post: PostEntity()),
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, postState) {
            if (postState is PostLoading) {
              return Center(child: CircularProgressIndicator(),);
            }
            if (postState is PostFailure) {
              toast("Some Failure occured while creating the post");
            }
            if (postState is PostLoaded) {
              return ListView.builder(
                  itemCount: postState.posts.length,
                  itemBuilder: (context, index) {
                    final post = postState.posts[index];
                    return SinglePostCardWidget(post: post);
                  }
              );
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      ),
    );
  }
}