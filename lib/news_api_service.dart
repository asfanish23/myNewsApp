import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'article.dart';

class NewsApiService {
  final String apiKey = '9a2145a3c5ae4d55a7981a4ba3122586';
  final String baseUrl = 'https://newsapi.org/v2/';

  Future<List<Article>> fetchTopHeadlines({
    String country = 'us',
    int page = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final url =
          '${baseUrl}top-headlines?country=$country&page=$page&pageSize=10&apiKey=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // ✅ save each page separately
        await prefs.setString('cached_news_page_$page', response.body);

        final data = json.decode(response.body);
        final List articles = data['articles'];

        return articles.map((e) => Article.fromJson(e)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      // ❗ fallback to cached page
      final cachedData = prefs.getString('cached_news_page_$page');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        final List articles = data['articles'];

        return articles.map((e) => Article.fromJson(e)).toList();
      } else {
        throw Exception('No cached data for page $page');
      }
    }
  }
}