import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtPage extends StatelessWidget {
  final Widget child;
  final String title;

  const ArtPage({Key key, this.title, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF2F2F2),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
              },
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back,
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(16),
              child: Text(
                title,
                textScaleFactor: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
