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
  Future<Comic> latestComic;
  List<Comic> _randomComics = List<Comic>();
  int randomId = 0;
  XkcdClient client;

  @override
  void initState() {
    super.initState();
    client = new XkcdClient();
    latestComic = client.fetchLatestComic();
  }

  Future<List<Widget>> _renderRandomComics() async {
    Utils utils = new Utils();
    Comic latestComic = await client.fetchLatestComic();

    for (int i = 0; i < 4; i++) {
      int randomId = utils.generateRandomNumber(latestComicId: latestComic.id);
      Comic comic = await client.fetchComic(id: randomId);
      _randomComics.add(comic);
    }

    List<Widget> comics = _randomComics?.map(
          (randomComic) {
            return Container(
              child: Image.network(
                randomComic.img,
                width: MediaQuery.of(context).size.width / 3,
              ),
            );
          },
        )?.toList() ??
        [];

    return comics;
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
                  child: Card(
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
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: FutureBuilder<Comic>(
                    future: latestComic,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            Text(
                              "${snapshot.data.title}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Navigation(),
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
                            Navigation(),
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
                  padding: EdgeInsets.all(48.0),
                  child: FutureBuilder<List<Widget>>(
                    future: _renderRandomComics(),
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
