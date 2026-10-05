import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

class DashboardPage extends StatefulWidget {
  const new({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<ItemInDb> _items = const [];
  String _query = '';
  String? _searchError;
  bool _isSearching = false;
  int _searchRequest = 0;

  Future<void> _searchItems(String query) async {
    final request = ++_searchRequest;
    _query = query.trim();
    if (_query.isEmpty) {
      setState(() {
        _items = const [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchError = null;
      _isSearching = true;
    });

    try {
      final items = await EstimatorRepository.instance.searchItems(query);
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _items = items;
        _isSearching = false;
      });
    } on Exception catch (error) {
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _searchError = 'Search failed: $error';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 16.0,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(hintText: 'Search'),
              onChanged: _searchItems,
            ),
            Expanded(
              child: Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _LeftSection(
                      items: _items,
                      isSearching: _isSearching,
                      hasQuery: _query.isNotEmpty,
                      error: _searchError,
                    ),
                  ),
                  Expanded(flex: 3, child: _RightSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftSection extends StatelessWidget {
  const _LeftSection({
    required this.items,
    required this.isSearching,
    required this.hasQuery,
    this.error,
  });

  final List<ItemInDb> items;
  final bool isSearching;
  final bool hasQuery;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text(error!, textAlign: TextAlign.center));
    }
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(child: Text(hasQuery ? 'No matching items' : 'Type to search items'));
    }

    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('${item.description} • ${item.unit}'),
          tileColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        );
      },
      separatorBuilder: (_, _) => SizedBox(height: 8.0),
    );
  }
}

class _RightSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            spacing: 8.0,
            children: <Widget>[
              TextField(decoration: InputDecoration(hintText: 'Description'), maxLines: 10),
              Row(
                spacing: 8.0,
                children: <Widget>[
                  Expanded(
                    child: TextField(decoration: InputDecoration(hintText: 'Quantity')),
                  ),
                  Expanded(
                    child: TextField(decoration: InputDecoration(hintText: 'Unit')),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(flex: 3, child: _RateSection()),
      ],
    );
  }
}

class _RateSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      itemBuilder: (context, index) {
        final item = 'Rate $index';
        return CheckboxListTile(
          value: false,
          onChanged: (value) {},
          title: Text(item),
          subtitle: Text(item),
          tileColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
      separatorBuilder: (_, _) => SizedBox(height: 8.0),
    );
  }
}
