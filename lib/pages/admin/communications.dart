import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/communications_provider.dart';
import 'package:intl/intl.dart'; // For formatting the date

class CommunicationsScreen extends StatelessWidget {
  const CommunicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communications Center'),
      ),
      body: Consumer<CommunicationsProvider>(
        builder: (context, provider, _) {
          return provider.articles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: provider.articles.length,
                  itemBuilder: (context, index) {
                    final article = provider.articles[index];
                    return ListTile(
                      title: Text(article.title),
                      subtitle: Text(article.body),
                      trailing: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(article.date))),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddArticleDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Article'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;
                final date = DateTime.now().toIso8601String();

                if (title.isNotEmpty && content.isNotEmpty) {
                  final newArticle = Article(
                    title: title,
                    body: content,
                    date: date,
                  );
                  Provider.of<CommunicationsProvider>(context, listen: false)
                      .addArticle(newArticle);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
