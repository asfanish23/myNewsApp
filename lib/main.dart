// lib/main.dart
import 'package:flutter/material.dart';
import 'article.dart';
import 'news_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'article_webview.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App Lab',

      // 🌙 DARK MODE ENABLE
      themeMode: ThemeMode.system,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
      ),

      home: const NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final NewsApiService newsApiService = NewsApiService();

  List<Article> allArticles = [];
  List<Article> filteredArticles = [];

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final newArticles =
      await newsApiService.fetchTopHeadlines(page: page);

      setState(() {
        page++;
        isLoading = false;

        if (newArticles.isEmpty) {
          hasMore = false;
        } else {
          allArticles.addAll(newArticles);
          filteredArticles = allArticles;
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterNews(String query) {
    setState(() {
      filteredArticles = allArticles
          .where((a) =>
          a.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterNews,
              decoration: const InputDecoration(
                hintText: "Search news...",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
            loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: filteredArticles.length + 1,
          itemBuilder: (context, index) {
            if (index < filteredArticles.length) {
              return NewsArticleTile(
                  article: filteredArticles[index]);
            } else {
              if (!hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No more news")),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

class NewsArticleTile extends StatelessWidget {
  final Article article;

  const NewsArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor, // 🌙 support dark mode
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: article.urlToImage,
          width: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            width: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) =>
          const Icon(Icons.error, color: Colors.red),
        ),
        title: Text(
          article.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(article.description),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleWebView(url: article.url),
            ),
          );
        },
      ),
    );
  }
}