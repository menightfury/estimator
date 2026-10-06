import 'package:estimator/common/utils/debouncer.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/loa_model.dart';

class LoaPicker extends StatefulWidget {
  const LoaPicker({super.key});

  @override
  State<LoaPicker> createState() => _LoaPickerState();
}

class _LoaPickerState extends State<LoaPicker> {
  @override
  Widget build(BuildContext context) {
    final searchNotifier = ItemSearchNotifier();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(hintText: 'Type to search'),
          onChanged: (value) => searchNotifier.search(value),
        ),
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
                    final loa = results[index];
                    return ListTile(
                      title: Text('${loa.number} dated ${loa.date.toReadable()}'),
                      subtitle: Text(loa.rebate?.toString() ?? '0.0%', maxLines: 2, overflow: TextOverflow.ellipsis),
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

  final Map<String, List<EstimatorLoa>> _amcCache;
  final Debouncer _debouncer;

  ItemSearchStateStatus _status;
  ItemSearchStateStatus get status => _status;

  List<EstimatorLoa> _results;
  List<EstimatorLoa> get results => _results;

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
      final results = await EstimatorRepository.instance.searchLoas(query);
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
