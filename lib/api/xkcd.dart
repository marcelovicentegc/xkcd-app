import 'dart:convert';
import 'package:http/http.dart' as http;

class Comic {
  final String month;
  final int id;
  final String link;
  final String year;
  final String news;
  final String safeTitle;
  final String transcript;
  final String alt;
  final String img;
  final String title;
  final String day;

  Comic(
      {this.month,
      this.id,
      this.link,
      this.year,
      this.news,
      this.safeTitle,
      this.transcript,
      this.alt,
      this.img,
      this.title,
      this.day});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
        month: json['month'],
        id: json['num'],
        link: json['link'],
        year: json['year'],
        news: json['news'],
        safeTitle: json['safe_title'],
        transcript: json['transcript'],
        alt: json['alt'],
        img: json['img'],
        title: json['title'],
        day: json['day']);
  }
}

Future<Comic> fetchLatestComic() async {
  final response = await http.get('https://xkcd.com/info.0.json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Comic.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load comic');
  }
}
