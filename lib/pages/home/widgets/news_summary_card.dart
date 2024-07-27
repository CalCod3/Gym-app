import 'package:flutter/material.dart';
import 'dart:async'; // Import the dart:async package for Timer
import 'package:provider/provider.dart';
import '../../../providers/communications_provider.dart';
import '../../news/news_list.dart';

class NewsSummaryCard extends StatefulWidget {
  const NewsSummaryCard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewsSummaryCardState createState() => _NewsSummaryCardState();
}

class _NewsSummaryCardState extends State<NewsSummaryCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fetch news articles and set up periodic refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndUpdateArticles();
      _setupPeriodicRefresh();
    });
  }

  void _fetchAndUpdateArticles() {
    // Fetch articles and update UI
    Provider.of<CommunicationsProvider>(context, listen: false).fetchArticles();
  }

  void _setupPeriodicRefresh() {
    // Refresh every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchAndUpdateArticles();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationsProvider>(
      builder: (context, provider, child) {
        final articles = provider.articles.take(5).toList();

        return SizedBox(
          width: double.infinity, // Ensures the card takes the full width of its parent
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsListScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest News',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...articles.map((article) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article.body,
                                maxLines: 2, // Adjust based on how much content you want to show
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
