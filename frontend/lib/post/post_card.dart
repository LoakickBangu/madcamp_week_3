import 'package:flutter/material.dart';
import 'package:week_3/utils/utils.dart';
import 'package:week_3/models/post.dart';

class PostCard extends StatelessWidget {
  final VoidCallback onTap;
  final Post post;

  PostCard({@required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: screenAwareSize(100.0, context),
            padding: EdgeInsets.symmetric(
                horizontal: 10.0, vertical: screenAwareSize(5.0, context)),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/0.jpg',
                    width: screenAwareSize(100.0, context),
                    height: screenAwareSize(90.0, context),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 15.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '통기타',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenAwareSize(14.0, context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Icon(Icons.favorite),
                              ),
                            ],
                          ),
                          SizedBox(height: screenAwareSize(5.0, context)),
                          Text(
                            '상태 좋고 흥정 가능해kjhkjhkhkdsada요1년 정도 사용했어요1년 정도 사용했어요1년 정도 사용했어요',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenAwareSize(10.0, context),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "3일 전",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: screenAwareSize(9.0, context),
                            ),
                          ),
                          Text(
                            "50,000원",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenAwareSize(11.0, context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenAwareSize(10, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}