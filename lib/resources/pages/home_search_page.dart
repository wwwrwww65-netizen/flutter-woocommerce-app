//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/store_logo_widget.dart';
import '/resources/pages/browse_search_page.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class HomeSearchPage extends NyStatefulWidget {
  static RouteView path = ("/home-search", (_) => HomeSearchPage());

  HomeSearchPage({super.key}) : super(child: () => _HomeSearchPageState());
}

class _HomeSearchPageState extends NyPage<HomeSearchPage> {
  final TextEditingController _txtSearchController = TextEditingController();
  Database? _db;
  List<Map<String, Object?>> _results = [];

  @override
  void initState() {
    super.initState();
    _initDb();
    _txtSearchController.addListener(_onSearchChanged);
  }

  Future<void> _initDb() async {
    final String dbPath = p.join(await getDatabasesPath(), 'content.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute('CREATE VIRTUAL TABLE IF NOT EXISTS articles USING fts5(id UNINDEXED, title, body, tokenize = "porter");');
      await db.insert('articles', {'id': 'demo-1', 'title': 'Getting started', 'body': 'Welcome guide'});
      await db.insert('articles', {'id': 'demo-2', 'title': 'Battery issues', 'body': 'Troubleshooting battery drain'});
    });
  }

  void _onSearchChanged() async {
    final String q = _txtSearchController.text.trim();
    if (_db == null) return;
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final rows = await _db!.rawQuery('SELECT id, title, snippet(articles, 1, "<b>", "</b>", "…", 10) AS snippet FROM articles WHERE articles MATCH ? LIMIT 25;', [q + '*']);
    setState(() => _results = rows);
  }

  _actionSearch() {
    routeTo(BrowseSearchPage.path, data: _txtSearchController.text,
        onPop: (value) {
      if (["notic", "compo"].contains(AppHelper.instance.appConfig!.theme) ==
          false) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StoreLogo(height: 55),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NyTextField.compact(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: _txtSearchController,
              style: Theme.of(context).textTheme.displaySmall,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            PrimaryButton(
              title: trans("Search"),
              action: _actionSearch,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final row = _results[index];
                  return ListTile(
                    title: Text((row['title'] ?? '') as String),
                    subtitle: Text(((row['snippet'] ?? '') as String).replaceAll(RegExp(r'<[^>]+>'), '')),
                    onTap: () => routeTo('/article-rich', data: {
                      'id': row['id'],
                      'html': '<h2>${row['title']}</h2><p>${row['snippet']}</p>'
                    }),
                  );
                },
              ),
            )
          ],
        ).withGap(20),
      ),
    );
  }
}