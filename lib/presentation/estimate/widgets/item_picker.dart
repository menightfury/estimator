part of '../create_estimate_page.dart';

class _ItemPicker extends StatefulWidget {
  const _ItemPicker({super.key});

  @override
  State<_ItemPicker> createState() => _ItemPickerState();
}

class _ItemPickerState extends State<_ItemPicker> {
  @override
  Widget build(BuildContext context) {
    final searchNotifier = ItemSearchNotifier();

    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Type to search',
            prefixIcon: Icon(Icons.search_rounded),
            suffix: IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
          ),
          onChanged: (value) => searchNotifier.search(value),
        ),
        EstimatorDivider(),
        Expanded(
          child: ListenableBuilder(
            listenable: searchNotifier,
            builder: (context, _) {
              $logger.d(searchNotifier);
              if (searchNotifier.status == ItemSearchStateStatus.error) {
                return Center(child: Text('Some error occurred! Try again later.', textAlign: TextAlign.center));
              }

              if (searchNotifier.status == ItemSearchStateStatus.initial ||
                  searchNotifier.status == ItemSearchStateStatus.empty) {
                return Center(child: Text('Type to search items'));
              }

              if (searchNotifier.status == ItemSearchStateStatus.success) {
                if (searchNotifier.results.isEmpty) {
                  return Center(child: Text('No matching items'));
                }

                final results = searchNotifier.results;
                return ListView.separated(
                  itemBuilder: ((context, index) {
                    final item = results[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    );
                  }),
                  separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                  itemCount: results.length,
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

enum ItemSearchStateStatus { initial, empty, loading, success, error }

class ItemSearchNotifier extends ChangeNotifier {
  ItemSearchNotifier()
    : _amcCache = {},
      _debouncer = Debouncer(2.seconds),
      _status = ItemSearchStateStatus.initial,
      _results = const [];

  final Map<String, List<ItemInDb>> _amcCache;
  final Debouncer _debouncer;

  ItemSearchStateStatus _status;
  ItemSearchStateStatus get status => _status;

  List<ItemInDb> _results;
  List<ItemInDb> get results => _results;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      _status = ItemSearchStateStatus.empty;
      _results = const [];
      notifyListeners();
      return;
    }

    final key = q.toLowerCase();
    final cachedResult = _amcCache[key];
    if (cachedResult != null) {
      _status = ItemSearchStateStatus.success;
      _results = cachedResult;
      notifyListeners();
      return;
    }

    _status = ItemSearchStateStatus.loading;
    _results = const [];
    notifyListeners();

    try {
      await _debouncer.wait();
      final results = await EstimatorRepository.instance.searchItems(query);
      $logger.d(results);
      _status = ItemSearchStateStatus.success;
      _results = results;
      _amcCache[key] = results;
    } on Exception catch (_) {
      _status = ItemSearchStateStatus.error;
      _results = const [];
    }
    notifyListeners();
  }

  @override
  String toString() => 'status: $_status, results: $_results';
}
