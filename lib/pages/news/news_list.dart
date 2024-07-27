import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/communications_provider.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All News'),
      ),
      body: Consumer<CommunicationsProvider>(
        builder: (context, provider, child) {
          final articles = provider.articles;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text(article.body),
              );
            },
          );
        },
      ),
    );
  }
}
