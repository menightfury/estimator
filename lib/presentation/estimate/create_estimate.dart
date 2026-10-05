import 'package:estimator/common/utils/debouncer.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

part 'widgets/item_picker.dart';

class CreateEstimatePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 16.0,
          children: <Widget>[
            Text('Header Display Bar'),
            Expanded(
              child: Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _LeftSection(
                      // items: _items,
                      // isSearching: _isSearching,
                      // hasQuery: _query.isNotEmpty,
                      // error: _searchError,
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
  const _LeftSection(
    // {required this.items, required this.isSearching, required this.hasQuery, this.error}
  );

  // final List<ItemInDb> items;
  // final bool isSearching;
  // final bool hasQuery;
  // final String? error;

  @override
  Widget build(BuildContext context) {
    // if (error != null) {
    //   return Center(child: Text(error!, textAlign: TextAlign.center));
    // }
    // if (isSearching) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (items.isEmpty) {
    //   return Center(child: Text(hasQuery ? 'No matching items' : 'Type to search items'));
    // }

    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Items'),
          subtitle: Text('12 items'),
          trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Padding(padding: const EdgeInsets.all(8.0), child: _ItemSearch()),
                  );
                },
              );
            },
            icon: Icon(Icons.add_rounded),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: 5,
            itemBuilder: (context, index) {
              final item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                subtitle: Text(item),
                tileColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              );
            },
            separatorBuilder: (_, _) => SizedBox(height: 8.0),
          ),
        ),
      ],
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
