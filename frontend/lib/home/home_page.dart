import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:week_3/post/post_view_page.dart';
import 'package:week_3/styles/theme.dart';
import 'package:week_3/utils/base_height.dart';
import 'package:week_3/home/category_button.dart';
import 'package:week_3/utils/utils.dart';
import 'package:week_3/post/post_card.dart';
import 'package:week_3/models/category.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:week_3/models/post.dart';
import 'package:week_3/bloc/post_bloc.dart';
import 'package:week_3/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PostBloc _postBloc = PostBloc();

  int selectedCategory = 0;

  HomePageState() {
    _postBloc.dispatch(PostInit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              SizedBox(
                  height: MediaQuery.of(context).padding.top), //상단 상태바 높이 띄우기
              _buildSearchInput(context),
              _buildCategoryList(context),
              SizedBox(height: screenAwareSize(10.0, context)),
              BlocBuilder(
                  bloc: _postBloc,
                  builder: (BuildContext context, PostState state) {
                    if (state is PostUninitialized) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state is PostError) {
                      return Center(
                        child: Text('포스트를 불러오는데 실패했습니다.'),
                      );
                    }
                    if (state is PostLoaded) {
                      if (state.posts.isEmpty) {
                        return Center(
                          child: Text('게시글이 없어요!'),
                        );
                      }
                      return Expanded(
                          child: _buildSuggestions(context, state.posts));
                    }
                    if (state is PostSearched) {
                      log.i("검색");
                      if (state.searchedPosts.isEmpty) {
                        return Center(
                          child: Text('검색된 게시글이 없어요!'),
                        );
                      }
                      return Expanded(
                        child: _buildSuggestions(context, state.searchedPosts),
                      );
                    }
                    if (state is PostSelectedCategory) {
                      log.i("카테고리선택: $selectedCategory");
                      if (state.categoryPosts.isEmpty) {
                        return Center(
                          child: Text('해당 카테고리의 게시글이 없어요!'),
                        );
                      }
                      return Expanded(
                        child: _buildSuggestions(context, state.categoryPosts),
                      );
                    }
                  }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchInput(context) {
    final myController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: screenAwareSize(20.0, context),
        bottom: screenAwareSize(10.0, context),
      ),
      child: TextField(
        controller: myController,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () async => await _postBloc
                .dispatch(PostSearch(searchdata: myController.text)),
            child: Icon(Icons.search),
          ),
          hintText: "상품을 검색해보세요",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenAwareSize(15.0, context)),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.black.withOpacity(0.03),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
        ),
      ),
    );
  }

  Widget _buildCategoryList(context) {
    return Container(
      height: screenAwareSize(70, context),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (context, idx) {
          return HomeCategoryButton(
            active: selectedCategory == idx,
            icon: CategoryList[idx].icon,
            text: CategoryList[idx].name,
            onPressed: () {
              setState(() {
                selectedCategory = idx;
                _postBloc.dispatch(
                    PostSelectCategory(selectedcategory: selectedCategory));
              });
            },
          );
        },
        separatorBuilder: (context, idx) {
          return SizedBox(
            width: 10.0,
          );
        },
        itemCount: CategoryList.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildSuggestions(context, posts) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: screenAwareSize(50.0, context)),
      physics: BouncingScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int idx) {
        return _buildRow(context, posts[idx]);
      },
      separatorBuilder: (BuildContext context, int i) {
        return Divider();
      },
    );
  }

  Widget _buildRow(context, post) {
    return PostCard(
      post: post,
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PostViewPage(post: post)));
      },
    );
  }
}
