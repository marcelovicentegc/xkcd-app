import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/db.dart';
import 'package:xkcd/api/xkcd.dart';
import 'package:xkcd/utils/consts.dart';
import 'package:xkcd/utils/dialogs.dart';
import 'package:xkcd/widgets/zoom_overlay.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteComicsIds = new List<String>();
  List<Comic> favoriteComics = List<Comic>();
  bool displayComic = false;
  Comic currentComic;
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

  void handleOnPressed({comitToDisplay: Comic}) {
    if (currentComic == null || !(currentComic.id == comitToDisplay.id)) {
      setState(() {
        displayComic = true;
        currentComic = comitToDisplay;
      });
    } else {
      setState(() {
        displayComic = false;
        currentComic = null;
      });
    }
  }

  void _handleOnPressedOk({id: String}) async {
    db.removeFromFavorites(id: id);
    _getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FAVORITES),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: isLoading
                    ? [CircularProgressIndicator()]
                    : (favoriteComics.length == 0)
                        ? [
                            Container(
                              child: Text(NO_FAVORITES,
                                  style: Theme.of(context).textTheme.headline6),
                            ),
                          ]
                        : favoriteComics
                            .map(
                              (favoriteComic) => Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        FlatButton(
                                          padding: EdgeInsets.all(8.0),
                                          onPressed: () => handleOnPressed(
                                              comitToDisplay: favoriteComic),
                                          child: Text(
                                            favoriteComic.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: (() {
                                            displayConfirmationModal(
                                                ctx: context,
                                                title: "Remove from favorites",
                                                content:
                                                    "Are you sure you want to remove this comic from favorites?",
                                                onPressedOk: () {
                                                  _handleOnPressedOk(
                                                      id: favoriteComic.id);
                                                });
                                          }),
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    displayComic &&
                                            (currentComic.id ==
                                                favoriteComic.id)
                                        ? Container(
                                            alignment: Alignment.center,
                                            child: Material(
                                              child: InkWell(
                                                onTap: () {
                                                  displayAltContent(
                                                      ctx: context,
                                                      title: currentComic.title,
                                                      alt: currentComic.alt);
                                                },
                                                child: Container(
                                                  // height: ,
                                                  alignment: Alignment.center,
                                                  child: ZoomOverlay(
                                                    twoTouchOnly: true,
                                                    child: Image.network(
                                                        currentComic.img),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                            )
                            .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
