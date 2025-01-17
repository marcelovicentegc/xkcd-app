import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/db.dart';
import 'package:xkcd/api/xkcd.dart';
import 'package:xkcd/screens/favorites.dart';
import 'package:xkcd/utils/consts.dart';
import 'package:xkcd/utils/dialogs.dart';
import 'package:xkcd/utils/random.dart';
import 'package:xkcd/widgets/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xkcd/widgets/zoom_overlay.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Comic> _currentComic;
  Future<List<Widget>> _randomComics;
  bool _isCurrentComicOnFavorites;
  XkcdClient _client;
  Db _db;

  @override
  void initState() {
    super.initState();
    _client = new XkcdClient();
    _db = new Db();
    _isCurrentComicOnFavorites = false;
    _currentComic = _client.fetchLatestComic();
    _randomComics = _renderRandomComics();
  }

  void _checkIfCurrentComicIsOnFavorites() async {
    Comic comic = await _currentComic;
    bool isSaved = await _isSavedOnFavorites(comicId: comic.id);
    setState(() {
      _isCurrentComicOnFavorites = isSaved;
    });
  }

  void _handleOnPressedFirst() async {
    setState(() {
      _currentComic = _client.fetchComic(id: 1);
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  void _handleOnPressedLast() async {
    setState(() {
      _currentComic = _client.fetchLatestComic();
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  void _handleOnPressedNext() async {
    Comic latestComic = await _client.fetchLatestComic();
    var comic = await _currentComic;

    if (latestComic.id == comic.id) {
      return;
    }

    setState(() {
      _currentComic = _client.fetchComic(id: comic.id + 1);
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  void _handleOnPressedPrevious() async {
    Comic comic = await _currentComic;

    if (comic.id == 1) {
      return;
    }

    setState(() {
      _currentComic = _client.fetchComic(id: comic.id - 1);
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  void _handleOnPressedRandom() async {
    Utils utils = new Utils();
    Comic latestComic = await _client.fetchLatestComic();

    int randomId = utils.generateRandomNumber(latestComicId: latestComic.id);

    setState(() {
      _currentComic = _client.fetchComic(id: randomId);
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  void _handleOnTapRandomComic({id: int}) async {
    setState(() {
      _currentComic = _client.fetchComic(id: id);
    });

    _checkIfCurrentComicIsOnFavorites();
  }

  Future<List<Widget>> _renderRandomComics() async {
    Utils utils = new Utils();
    List<Comic> comics = List<Comic>();
    Comic latestComic = await _client.fetchLatestComic();

    for (int i = 0; i < 6; i++) {
      int randomId = utils.generateRandomNumber(latestComicId: latestComic.id);
      Comic comic = await _client.fetchComic(id: randomId);
      comics.add(comic);
    }

    List<Widget> randomComicsWidgets = comics?.map(
          (randomComic) {
            return GestureDetector(
              onTap: () {
                _handleOnTapRandomComic(id: randomComic.id);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Container(
                    child: Image.network(
                      randomComic.img,
                      width: (MediaQuery.of(context).size.width / 2) - 36,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        )?.toList() ??
        [];

    return randomComicsWidgets;
  }

  void _saveToFavorites({id: int}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = FAVORITES;
    final value = prefs.getStringList(key) ?? [];
    value.add(id.toString());
    prefs.setStringList(key, value);
  }

  Future<bool> _isSavedOnFavorites({comicId: int}) async {
    final ids = await _db.readFromFavorites();
    return ids.any((id) => id == comicId.toString());
  }

  Future<SnackBar> _handleOnDoubleTap({comicId: int}) async {
    SnackBar snackBar;
    bool isSaved = await _isSavedOnFavorites(comicId: comicId);
    if (isSaved) {
      _db.removeFromFavorites(id: comicId);
      snackBar = SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(REMOVED_FROM_FAVS));
    } else {
      snackBar = SnackBar(
          duration: const Duration(seconds: 1), content: Text(ADDED_ON_FAVS));
      _saveToFavorites(id: comicId);
    }

    setState(() {
      _isCurrentComicOnFavorites = !isSaved;
    });

    return snackBar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Image.network(HOME_URL),
                      ),
                      Expanded(
                        child: Text(
                          TAGLINE.toUpperCase(),
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: FutureBuilder<Comic>(
                    future: _currentComic,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "${snapshot.data.title}",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Icon(Icons.star,
                                    color: _isCurrentComicOnFavorites
                                        ? Colors.yellow.shade900
                                        : Colors.grey),
                              ],
                            ),
                            Navigation(
                              onPressedFirst: () {
                                _handleOnPressedFirst();
                              },
                              onPressedLast: () {
                                _handleOnPressedLast();
                              },
                              onPressedNext: () {
                                _handleOnPressedNext();
                              },
                              onPressedPrevious: () {
                                _handleOnPressedPrevious();
                              },
                              onPressedRandom: () {
                                _handleOnPressedRandom();
                              },
                            ),
                            Material(
                              child: InkWell(
                                onDoubleTap: () async {
                                  Scaffold.of(context).showSnackBar(
                                      await _handleOnDoubleTap(
                                          comicId: snapshot.data.id));
                                },
                                onTap: () {
                                  displayAltContent(
                                      ctx: context,
                                      title: snapshot.data.title,
                                      alt: snapshot.data.alt);
                                },
                                child: Container(
                                  // height: ,
                                  alignment: Alignment.center,
                                  child: ZoomOverlay(
                                    twoTouchOnly: true,
                                    child: Image.network(snapshot.data.img),
                                  ),
                                ),
                              ),
                            ),
                            Navigation(
                              onPressedFirst: () {
                                _handleOnPressedFirst();
                              },
                              onPressedLast: () {
                                _handleOnPressedLast();
                              },
                              onPressedNext: () {
                                _handleOnPressedNext();
                              },
                              onPressedPrevious: () {
                                _handleOnPressedPrevious();
                              },
                              onPressedRandom: () {
                                _handleOnPressedRandom();
                              },
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return Container(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator());
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 48.0),
                  child: FutureBuilder<List<Widget>>(
                    future: _randomComics,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        return Column(children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              RANDOM_COMICS,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Row(children: snapshot.data.sublist(0, 2)),
                          Row(children: snapshot.data.sublist(2, 4)),
                          Row(children: snapshot.data.sublist(4, 6)),
                        ]);
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
