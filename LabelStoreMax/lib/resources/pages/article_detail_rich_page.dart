import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ArticleDetailRichPage extends StatefulWidget {
  static const String path = "/article-rich";

  const ArticleDetailRichPage({super.key});

  @override
  State<ArticleDetailRichPage> createState() => _ArticleDetailRichPageState();
}

class _ArticleDetailRichPageState extends State<ArticleDetailRichPage> {
  late final String articleId;
  bool bookmarked = false;
  bool solved = false;
  bool offlineSaved = false;
  String? html;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    articleId = (args?['id'] ?? 'demo-article') as String;
    html = args?['html'] as String?;
  }

  Future<void> _saveOffline() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'articles', '$articleId.html'));
    await file.create(recursive: true);
    await file.writeAsString(html ?? '<p></p>');
    setState(() => offlineSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Article".tr()),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_outline),
            onPressed: () => setState(() => bookmarked = !bookmarked),
          ),
          IconButton(
            icon: Icon(offlineSaved ? Icons.download_done : Icons.download),
            onPressed: _saveOffline,
          ),
          IconButton(
            icon: Icon(solved ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () => setState(() => solved = !solved),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (html != null) HtmlWidget(html!),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _saveOffline,
                  icon: const Icon(Icons.offline_bolt),
                  label: Text("Save offline".tr()),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => bookmarked = !bookmarked),
                  icon: const Icon(Icons.bookmark),
                  label: Text("Bookmark".tr()),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => solved = !solved),
                  icon: const Icon(Icons.check),
                  label: Text("Mark as solved".tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

