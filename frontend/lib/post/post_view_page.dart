import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:week_3/models/chat.dart';
import 'package:week_3/post/google_map_fixed.dart';
import 'package:week_3/post/post_book_page.dart';
import 'package:week_3/post/post_card.dart';
import 'package:week_3/styles/theme.dart';
import 'package:week_3/utils/utils.dart';
import 'package:week_3/models/book.dart';
import 'dart:math' as math;
import 'package:week_3/models/post.dart';
import 'package:week_3/utils/dio.dart';
import 'package:week_3/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:week_3/post/post_shimmer_card.dart';
import 'package:week_3/chat/chat_view_page.dart';
import 'package:week_3/post/post_page.dart';

class PostViewPage extends StatefulWidget {
  final int postId;

  PostViewPage({@required this.postId});

  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  static const double horizontalPadding = 16.0;

  Post post;
  List<Post> relatedPosts;
  ScrollController scrollController;
  GlobalKey<LoadingWrapperState> _loadingWrapperKey =
      GlobalKey<LoadingWrapperState>();

  UserBloc _userBloc;
  int loggedUserId = 0;

  @override
  void initState() {
    super.initState();

    initPost();

    scrollController = ScrollController();

    _userBloc = BlocProvider.of<UserBloc>(context);
    final UserLoaded user = _userBloc.currentState;
    loggedUserId = user.id;
  }

  void initPost() async {
    var res = await dio.getUri(getUri('/api/posts/${widget.postId}'));
    Post p = Post.fromJson(res.data);
    relatedPosts = res.data['relatedPosts']
        .map((p) {
          return Post.fromJson(p);
        })
        .toList()
        .cast<Post>();
    await Future.delayed(Duration(milliseconds: 250));

    if (res.statusCode == 200) {
      if (mounted) {
        setState(() {
          post = p;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) {
      return PostShimmerCard();
    }
    return LoadingWrapper(
      key: _loadingWrapperKey,
      builder: (context, loading) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  SafeArea(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildImageCarousel(),
                          SizedBox(height: screenAwareSize(10.0, context)),
                          post.isBook
                              ? _buildBookPostHeader(context)
                              : _buildPostHeader(context),
                          _buildDivider(),
                          _buildPostContent(context),
                          _buildLocation(),
                          _buildDivider(),
                          _buildUserInfo(context),
                          _buildDivider(),
                          _buildRelatedPosts(context),
                          SizedBox(height: screenAwareSize(70.0, context)),
                        ],
                      ),
                    ),
                  ),
                  _buildAppBar(),
                  loggedUserId == post.user.id
                      ? _buildSellerBottomTab()
                      : _buildBottomTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final double opacityTween = math.max(
            math.min(
                scrollController.offset / screenAwareSize(350.0, context), 1),
            0);
        return Container(
          height: screenAwareSize(50.0, context) +
              MediaQuery.of(context).padding.top,
          child: AppBar(
            title: Opacity(
                opacity: opacityTween,
                child: Text(
                  post.title,
                  style: TextStyle(fontSize: 16.0),
                )),
            backgroundColor: Colors.white.withOpacity(opacityTween),
            bottomOpacity: 0.0,
            elevation: opacityTween >= 1.0 ? 2.0 : 0.0,
          ),
        );
      },
    );
  }

  Widget _buildRelatedPosts(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenAwareSize(10.0, context)),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenAwareSize(16.0, context),
              vertical: screenAwareSize(5.0, context)),
          child: Text(
            "같은 카테고리 상품",
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
        SizedBox(height: screenAwareSize(15.0, context)),
        for (int i = 0; i < relatedPosts.length; i++)
          PostCard(
            post: relatedPosts[i],
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      PostViewPage(postId: relatedPosts[i].id)));
            },
          )
      ],
    );
  }

  Widget _buildSellerBottomTab() {
    var _status = ['판매중', '예약중', '판매완료'];
    var _currentStatus;
    if (post.status == 0){
      _currentStatus = '판매중';
      final postBloc = BlocProvider.of<PostBloc>(context);
      postBloc.dispatch(StatusUpdate(postId: post.id, status: post.status));
    }
    else if (post.status == 1){
      _currentStatus = '예약중';
      final postBloc = BlocProvider.of<PostBloc>(context);
      postBloc.dispatch(StatusUpdate(postId: post.id, status: post.status));
    }
    else if (post.status == 2){
      _currentStatus = '판매완료';
      final postBloc = BlocProvider.of<PostBloc>(context);
      postBloc.dispatch(StatusUpdate(postId: post.id, status: post.status));
    }

    return Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Container(
            height: screenAwareSize(50.0, context),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3.0,
                    spreadRadius: -3.0,
                    offset: Offset(0, -3)),
              ],
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: post.isBook
                          ? () {
                              Book book = new Book(
                                title: post.title,
                                image: post.bookImage,
                                author: post.bookAuthor,
                                price: post.bookPrice,
                                pubdate: post.bookPubDate,
                                publisher: post.bookPublisher,
                              );
                              return Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostBookPage(
                                    book: book,
                                    post: post,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostPage(post: post),
                                ),
                              );
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: screenAwareSize(14.0, context),
                          ),
                          SizedBox(width: 7.0),
                          Text('수정하기',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenAwareSize(14.0, context))),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("삭제하기"),
                                content: new Text("정말로 삭제하시겠습니까?"),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Yes"),
                                    onPressed: () async {
                                      await dio.deleteUri(getUri(
                                          '/api/posts/' + post.id.toString()));
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      final postBloc =
                                          BlocProvider.of<PostBloc>(context);
                                      postBloc.dispatch(PostFetch());
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.remove,
                            color: Colors.grey,
                            size: screenAwareSize(14.5, context),
                          ),
                          SizedBox(width: 7.0),
                          Text('삭제하기',
                              style: TextStyle(
                                  fontSize: screenAwareSize(14.5, context),
                                  color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      buttonColor: Colors.amber,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: _status.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (String newValueSelected) {
                            setState(() {
                              int val;
                              if (newValueSelected == '판매중')
                                val = 0;
                              else if (newValueSelected == '예약중')
                                val = 1;
                              else if (newValueSelected == '판매완료') 
                                val = 2;
                              post.status = val;
                              
                              _currentStatus = newValueSelected;
                            });
                          },
                          value: _currentStatus,
                          isExpanded: true,
                          style: TextStyle(
                              fontSize: screenAwareSize(14.5, context),
                              color: Colors.grey),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ),
                ])));
  }

  Widget _buildBottomTab() {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        height: screenAwareSize(50.0, context),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
                spreadRadius: -3.0,
                offset: Offset(0, -3.0)),
          ],
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  post.isWish
                      ? Icon(
                          Icons.favorite,
                          color: Colors.amber[200],
                        )
                      : Icon(Icons.favorite_border, color: Colors.amber[200]),
                  SizedBox(width: 5.0),
                  Text('찜', style: TextStyle(color: ThemeColor.primary)),
                ],
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(
                    vertical: screenAwareSize(10.0, context)),
                color: ThemeColor.primary,
                textColor: Colors.white,
                splashColor: Theme.of(context).primaryColorLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed:
                    loggedUserId == post.user.id ? null : _onPressChatSeller,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 60.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: screenAwareSize(14.0, context),
                      ),
                      SizedBox(width: 10.0),
                      Text('채팅으로 연락하기', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onPressChatSeller() {
    _loadingWrapperKey.currentState.loadFuture(() async {
      var res = await dio.postUri(getUri('/api/chats'), data: {
        'postId': post.id,
        'sellerId': post.user.id,
      });

      if (res.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatViewPage(chatId: res.data)));
      }
    });
  }

  List<CachedNetworkImage> _getImages() {
    List<CachedNetworkImage> images = List<CachedNetworkImage>();
    for (int i = 0; i < post.images.length; i++) {
      images.add(
        CachedNetworkImage(
          imageUrl: post.images[i]['url'],
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[200],
            highlightColor: Colors.grey[300],
            child: Container(
              width: double.infinity,
              height: screenAwareSize(350.0, context),
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return images;
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: <Widget>[
        Container(
          height: screenAwareSize(350.0, context),
          child: Carousel(
            autoplay: false,
            boxFit: BoxFit.cover,
            images: _getImages(),
            dotSize: 6.0,
            dotSpacing: 12.0,
            dotIncreaseSize: 1.6,
            dotIncreasedColor: Colors.amber[200],
            dotColor: Colors.amber[100],
            indicatorBgPadding: 10.0,
            dotBgColor: Colors.transparent,
            animationCurve: Curves.fastOutSlowIn,
            animationDuration: Duration(microseconds: 2000),
          ),
        ),
        if (post.isSold)
          Container(
              height: screenAwareSize(350.0, context),
              decoration:
                  new BoxDecoration(color: Color.fromARGB(140, 0, 0, 0)),
              child: Center(
                child: Text(
                  "SOLD\nOUT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenAwareSize(60.0, context),
                    color: ThemeColor.primary,
                    letterSpacing: 10.0,
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildBookPostHeader(context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenAwareSize(10.0, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  getMoneyFormat(post.price) + " 원",
                  style: TextStyle(
                    fontSize: screenAwareSize(18.0, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: screenAwareSize(5.0, context)),
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: screenAwareSize(
                      14.0,
                      context,
                    ),
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: screenAwareSize(10.0, context)),
                // Text(
                //   "Aasdas",
                //   style: TextStyle(
                //     fontSize: screenAwareSize(
                //       14.0,
                //       context,
                //     ),
                //     color: Colors.grey[800],
                //   ),
                // ),
                // SizedBox(height: screenAwareSize(10.0, context)),
                Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.clock,
                      size: 12.0,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      post.updatedAt,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Icon(
                      FontAwesomeIcons.eye,
                      size: 12.0,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 3.0),
                    Text(
                      post.view.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Icon(
                      FontAwesomeIcons.heart,
                      size: 12.0,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 3.0),
                    Text(
                      post.wish.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        CachedNetworkImage(
          imageUrl: post.bookImage,
          width: screenAwareSize(100.0, context),
          height: screenAwareSize(90.0, context),
          fit: BoxFit.cover,
        ),
        SizedBox(
          width: screenAwareSize(7, context),
        )
      ],
    );
  }

  Widget _buildPostHeader(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                getMoneyFormat(post.price) + " 원",
                style: TextStyle(
                  fontSize: screenAwareSize(18.0, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(width: screenAwareSize(5.0, context)),
              if (post.status == 1)
             // if (post.isSold)
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                      width: screenAwareSize(50.0, context),
                      height: screenAwareSize(20.0, context),
                      color: Colors.amber[800],
                      child: Center(
                        child: Text(
                          "예약중",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenAwareSize(10.0, context),
                              color: Colors.white),
                        ),
                      )),
                )
              else if (post.status == 2)
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                      width: screenAwareSize(50.0, context),
                      height: screenAwareSize(20.0, context),
                      color: Colors.red[700],
                      child: Center(
                        child: Text(
                          "판매완료",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenAwareSize(10.0, context),
                              color: Colors.white),
                        ),
                      )),
                ),          
            ]
          ),
          SizedBox(height: screenAwareSize(5.0, context)),
          Text(
            post.title,
            style: TextStyle(
              fontSize: screenAwareSize(
                14.0,
                context,
              ),
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: screenAwareSize(10.0, context)),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.clock,
                size: 12.0,
                color: Colors.grey[400],
              ),
              SizedBox(width: 3.0),
              Text(
                post.updatedAt,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.0,
                ),
              ),
              SizedBox(width: 20.0),
              Icon(
                FontAwesomeIcons.eye,
                size: 12.0,
                color: Colors.grey[400],
              ),
              SizedBox(width: 3.0),
              Text(
                post.view.toString(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.0,
                ),
              ),
              SizedBox(width: 20.0),
              Icon(
                FontAwesomeIcons.heart,
                size: 12.0,
                color: Colors.grey[400],
              ),
              SizedBox(width: 3.0),
              Text(
                post.wish.toString(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPostContent(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "상품설명",
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: screenAwareSize(15.0, context)),
          Text(post.content, style: TextStyle(height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: screenAwareSize(10.0, context)),
    );
  }

  Widget _buildUserInfo(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(5.0, context)),
      child: Container(
        height: screenAwareSize(50.0, context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: screenAwareSize(50.0, context),
              height: screenAwareSize(50.0, context),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400], width: 1.0),
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image:
                      ExactAssetImage(getRandomAvatarUrlByPostId(post.user.id)),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.user.name,
                  style: TextStyle(
                    fontSize: screenAwareSize(14.0, context),
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "판매내역 : " + post.user.salesCount.toString() + "개",
                  style: TextStyle(
                    fontSize: screenAwareSize(10.0, context),
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '거래 선호 위치',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: screenAwareSize(10.0, context)),
          GoogleMapfixed(
            picked: LatLng(
              post.locationLat,
              post.locationLng,
            ),
          )
        ],
      ),
    );
  }
}
