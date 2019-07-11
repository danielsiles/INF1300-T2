import 'package:flutter/material.dart';

class CommentTextItem extends StatefulWidget {
    String username = "";
    String comment = "";


    CommentTextItem(String username, String comment) {
        this.username = username;
        this.comment = comment;
    }

    @override
    _CommentTextItemState createState() => _CommentTextItemState();
}

class _CommentTextItemState extends State<CommentTextItem> {


    @override
    Widget build(BuildContext context) {

        return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black12,
                    )
                ),
            ),
//            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Padding (
                        padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 0.0),
                        child: Text(widget.username),
                    ),
                    Row(
                        children: <Widget>[
                            SizedBox(width: 8.0),
                            Text(widget.comment),

                            SizedBox(width: 8.0),
                            Expanded(
                                child: Container()
                            ),

                            SizedBox(width: 8.0),
                        ],
                    ),
                ],
            )
        );
    }
}
