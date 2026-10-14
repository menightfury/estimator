import 'package:estimator/common_libs.dart';
import 'package:estimator/presentation/estimate/create_estimate_page.dart';
import 'package:estimator/presentation/item/edit_item/edit_item.dart';
import 'package:estimator/presentation/item/items/items.dart';
import 'package:estimator/presentation/rate/edit_rate.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.push(const CreateEstimatePage()),
              child: const Text('Create Estimate'),
            ),

            ElevatedButton(onPressed: () => context.push(const EditRatePage()), child: const Text('Edit Rate')),

            ElevatedButton(onPressed: () => context.push(const EditItemPage()), child: const Text('Edit Item')),

            ElevatedButton(onPressed: () => context.push(const ItemsPage()), child: const Text('Items')),
          ],
        ),
      ),
    );
  }
}
