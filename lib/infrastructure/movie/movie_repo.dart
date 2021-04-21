import 'package:flutter_app_demo/domain/movie/i_movie_repo.dart';
import 'package:flutter_app_demo/domain/movie/imdb_id.dart';
import 'package:flutter_app_demo/domain/movie/movie.dart';
import 'package:flutter_app_demo/infrastructure/core/converter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieRepoImpl implements IMovieRepo{
  @override
  Future<List<MovieEntity>> getMovieListOnline(String searchString) async {
    List<MovieEntity> _movies = [];
    searchString = searchStringConverter(searchString);
    try {
      var url = Uri.parse('https://fake-movie-database-api.herokuapp.com/api?s=$searchString');
      var response = await http.get(url);

      addToMovieListFromResponse(_movies, response);
    } catch (e) {
      print("Unexpected Error occurred in Get request to https://fake-movie-database-api.herokuapp.com/api?s=$searchString");
    }
    //print(_movies.length);
    return _movies;
  }

  void addToMovieListFromResponse(List<MovieEntity> movies, http.Response response) {
    try {
      if (response.statusCode == 200) {
        var responseBodyMap = json.decode(response.body)['Search'];
        for (var map in responseBodyMap) {
          final ImdbID id = ImdbID(id: map['imdbID']);
          final String title = map['Title'];
          final String imageUrl = map['Poster'];
          final MovieEntity movie = MovieEntity(id: id, title: title, imageURL: imageUrl);
          movies.add(movie);
        }
      }
    } catch (e) {
      print("Unexpected Error occurred in Response object");
    }
  }
}