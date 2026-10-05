import 'package:estimator/common_libs.dart';

class DashboardPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 16.0,
          children: <Widget>[
            TextField(decoration: InputDecoration(hintText: 'Search')),
            Expanded(
              child: Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(flex: 2, child: _LeftSection()),
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
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      itemBuilder: (context, index) {
        final item = 'Item $index';
        return ListTile(
          title: Text(item),
          subtitle: Text(item),
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
