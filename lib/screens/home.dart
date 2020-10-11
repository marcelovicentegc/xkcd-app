import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/api/xkcd.dart';
import 'package:xkcd/widgets/button.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Comic> latestComic;

  @override
  void initState() {
    super.initState();
    latestComic = fetchLatestComic();
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
      body: Center(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Button(
                                onPressed: () {
                                  print('Navigate to first one');
                                },
                                label: "|<",
                              ),
                              Button(
                                onPressed: () {
                                  print('Navigate to previous one');
                                },
                                label: "< Prev",
                              ),
                              Button(
                                onPressed: () {
                                  print('Navigate to random one');
                                },
                                label: "Random",
                              ),
                              Button(
                                onPressed: () {
                                  print('Navigate to next one');
                                },
                                label: "Next >",
                              ),
                              Button(
                                onPressed: () {
                                  print('Navigate to last one');
                                },
                                label: ">|",
                              )
                            ],
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
