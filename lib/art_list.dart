import 'package:art/art/isowave.dart';
import 'package:flutter/material.dart';

import 'art/isolife.dart';
import 'art_page.dart';

typedef ArtGenerator = Widget Function();

class ArtItem {
  final String title;
  final ArtGenerator artGenerator;

  ArtItem(this.title, this.artGenerator);
}

List<ArtItem> artItems = [
  ArtItem("I so Wave", () => IsometricWave()),
  ArtItem("Life", () => IsometricLife()),
  ArtItem("I so Wave", () => IsometricWave()),
];

class ArtList extends StatelessWidget {
  Widget buildItem(BuildContext context, int position) => ListTile(
        title: Text(artItems[position].title),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArtPage(
              title: artItems[position].title,
              child: artItems[position].artGenerator(),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, position) => Container(
        color: Colors.black12,
        height: 1,
      ),
      itemBuilder: buildItem,
      itemCount: artItems.length,
    );
  }
}
