import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/xkcd.dart';
import 'package:xkcd/utils/random.dart';
import 'package:xkcd/widgets/navigation.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Comic> currentComic;
  Future<List<Widget>> randomComics;
  int randomId = 0;
  XkcdClient client;

  @override
  void initState() {
    super.initState();
    client = new XkcdClient();
    currentComic = client.fetchLatestComic();
    randomComics = renderRandomComics();
  }

  void handleOnPressedFirst() {
    setState(() {
      currentComic = client.fetchComic(id: 1);
    });
  }

  void handleOnPressedLast() {
    setState(() {
      currentComic = client.fetchLatestComic();
    });
  }

  void handleOnPressedNext() async {
    Comic latestComic = await client.fetchLatestComic();
    Comic comic = await currentComic;

    if (latestComic.id == comic.id) {
      return;
    }

    setState(() {
      currentComic = client.fetchComic(id: comic.id + 1);
    });
  }

  void handleOnPressedPrevious() async {
    Comic comic = await currentComic;

    if (comic.id == 1) {
      return;
    }

    setState(() {
      currentComic = client.fetchComic(id: comic.id - 1);
    });
  }

  void handleOnPressedRandom() async {
    Utils utils = new Utils();
    Comic latestComic = await client.fetchLatestComic();

    int randomId = utils.generateRandomNumber(latestComicId: latestComic.id);

    setState(() {
      currentComic = client.fetchComic(id: randomId);
    });
  }

  void handleOnTapRandomComic({id: int}) {
    setState(() {
      currentComic = client.fetchComic(id: id);
    });
  }

  Future<List<Widget>> renderRandomComics() async {
    Utils utils = new Utils();
    List<Comic> comics = List<Comic>();
    Comic latestComic = await client.fetchLatestComic();

    for (int i = 0; i < 4; i++) {
      int randomId = utils.generateRandomNumber(latestComicId: latestComic.id);
      Comic comic = await client.fetchComic(id: randomId);
      comics.add(comic);
    }

    List<Widget> randomComicsWidgets = comics?.map(
          (randomComic) {
            return GestureDetector(
              onTap: () {
                handleOnTapRandomComic(id: randomComic.id);
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

  void _displayAltContent({title: String, alt: String}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text(alt),
              ],
            ),
          ),
          actions: [
            new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                        child: Image.network("https://xkcd.com/s/0b7742.png"),
                      ),
                      Expanded(
                        child: Text(
                          'A webcomic of romance, sarcasm, math, and language.'
                              .toUpperCase(),
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
                    future: currentComic,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            Text(
                              "${snapshot.data.title}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Navigation(
                              onPressedFirst: () {
                                handleOnPressedFirst();
                              },
                              onPressedLast: () {
                                handleOnPressedLast();
                              },
                              onPressedNext: () {
                                handleOnPressedNext();
                              },
                              onPressedPrevious: () {
                                handleOnPressedPrevious();
                              },
                              onPressedRandom: () {
                                handleOnPressedRandom();
                              },
                            ),
                            Material(
                              child: InkWell(
                                onTap: () {
                                  _displayAltContent(
                                      title: snapshot.data.title,
                                      alt: snapshot.data.alt);
                                },
                                child: Container(
                                  child: Image.network(snapshot.data.img),
                                ),
                              ),
                            ),
                            Navigation(
                              onPressedFirst: () {
                                handleOnPressedFirst();
                              },
                              onPressedLast: () {
                                handleOnPressedLast();
                              },
                              onPressedNext: () {
                                handleOnPressedNext();
                              },
                              onPressedPrevious: () {
                                handleOnPressedPrevious();
                              },
                              onPressedRandom: () {
                                handleOnPressedRandom();
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
                    future: randomComics,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        return Column(children: [
                          Row(children: snapshot.data.sublist(0, 2)),
                          Row(children: snapshot.data.sublist(2, 4)),
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
