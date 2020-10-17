import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/db.dart';
import 'package:xkcd/api/xkcd.dart';
import 'package:xkcd/utils/consts.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteComicsIds = new List<String>();
  List<Comic> favoriteComics = List<Comic>();
  XkcdClient client;
  bool isLoading;
  Db db;

  @override
  void initState() {
    super.initState();
    db = new Db();
    client = new XkcdClient();
    _getFavorites();
  }

  void _getFavorites() async {
    setState(() {
      isLoading = true;
    });
    List<String> ids = await db.readFromFavorites();
    List<Comic> comics = List<Comic>();

    comics = await Future.wait(ids.map((id) => client.fetchComic(id: id)));

    setState(() {
      favoriteComicsIds = ids;
      favoriteComics = comics;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FAVORITES),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Column(
              children: isLoading
                  ? [CircularProgressIndicator()]
                  : favoriteComics
                      .map((favoriteComic) =>
                          Container(child: Text(favoriteComic.title)))
                      .toList()),
        ),
      ),
    );
  }
}
