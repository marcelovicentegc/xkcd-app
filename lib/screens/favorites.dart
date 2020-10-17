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
  List<String> _favoriteComicsIds = new List<String>();
  List<Comic> _favoriteComics = List<Comic>();
  bool _displayComic = false;
  Comic _currentComic;
  XkcdClient _client;
  bool _isLoading;
  Db _db;

  @override
  void initState() {
    super.initState();
    _db = new Db();
    _client = new XkcdClient();
    _getFavorites();
  }

  void _getFavorites() async {
    setState(() {
      _isLoading = true;
    });
    List<String> ids = await _db.readFromFavorites();
    List<Comic> comics = List<Comic>();

    comics = await Future.wait(ids.map((id) => _client.fetchComic(id: id)));

    setState(() {
      _favoriteComicsIds = ids;
      _favoriteComics = comics;
      _isLoading = false;
    });
  }

  void handleOnPressed({comitToDisplay: Comic}) {
    if (_currentComic == null || !(_currentComic.id == comitToDisplay.id)) {
      setState(() {
        _displayComic = true;
        _currentComic = comitToDisplay;
      });
    } else {
      setState(() {
        _displayComic = false;
        _currentComic = null;
      });
    }
  }

  void _handleOnPressedOk({id: String}) async {
    _db.removeFromFavorites(id: id);
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
                children: _isLoading
                    ? [CircularProgressIndicator()]
                    : (_favoriteComics.length == 0)
                        ? [
                            Container(
                              child: Text(NO_FAVORITES,
                                  style: Theme.of(context).textTheme.headline6),
                            ),
                          ]
                        : _favoriteComics
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
                                    _displayComic &&
                                            (_currentComic.id ==
                                                favoriteComic.id)
                                        ? Container(
                                            alignment: Alignment.center,
                                            child: Material(
                                              child: InkWell(
                                                onTap: () {
                                                  displayAltContent(
                                                      ctx: context,
                                                      title:
                                                          _currentComic.title,
                                                      alt: _currentComic.alt);
                                                },
                                                child: Container(
                                                  // height: ,
                                                  alignment: Alignment.center,
                                                  child: ZoomOverlay(
                                                    twoTouchOnly: true,
                                                    child: Image.network(
                                                        _currentComic.img),
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
