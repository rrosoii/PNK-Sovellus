// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'article_service.dart';
import 'article_model.dart';
import 'article_view.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final ArticleService _service = ArticleService();
  String selectedCategory = "Kaikki";

  final List<String> categories = [
    "Kaikki",
    "Uni",
    "Työ",
    "Mieli",
    "Ruoka",
    "Stressi",
  ];

  Future<List<Article>> _loadArticles() {
    if (selectedCategory == "Kaikki") {
      return _service.getArticles();
    }
    return _service.getArticlesByCategory(selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text("Artikkelit", style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              icon: Icon(Icons.filter_list, color: Colors.black54),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
              },
            ),
          ),
        ],
      ),

      body: FutureBuilder(
        future: _loadArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Virhe: ${snapshot.error}"),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text("Yritä uudelleen"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Ei artikkeleita löytynyt"));
          }

          final articles = snapshot.data as List<Article>;

          return ListView.separated(
            itemCount: articles.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (context, i) {
              final a = articles[i];

              return ListTile(
                title: Text(
                  a.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${a.author}\n${a.date}"),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleViewPage(article: a),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
