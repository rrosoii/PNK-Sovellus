// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'article_model.dart';

class ArticleViewPage extends StatelessWidget {
  final Article article;

  const ArticleViewPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E5AAC)),
        centerTitle: true,
        title: const Text(
          'Artikkeli',
          style: TextStyle(color: Color(0xFF2E5AAC)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(article: article),
              const SizedBox(height: 14),
              _ContentCard(article: article),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Article article;

  const _HeaderCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E5AAC), Color(0xFF6CA7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaPill(
            author: article.author.isNotEmpty ? article.author : 'Tuntematon',
            date: article.date.isNotEmpty ? article.date : '',
            category: article.category,
          ),
          const SizedBox(height: 12),
          Text(
            article.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Article article;

  const _ContentCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        article.content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.55,
          color: Color(0xFF3C4A62),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String author;
  final String date;
  final String category;

  const _MetaPill({
    required this.author,
    required this.date,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (author.isNotEmpty) author,
      if (date.isNotEmpty) date,
      if (category.isNotEmpty) category,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        parts.join('  |  '),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
