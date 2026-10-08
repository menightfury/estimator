import 'package:estimator/common_libs.dart';
import 'package:estimator/presentation/estimate/create_estimate.dart';
import 'package:estimator/presentation/estimate/create_estimate_page.dart';
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
              onPressed: () => context.push(const EstimatorDesktopPage()),
              child: const Text('Estimator Desktop Page'),
            ),
            ElevatedButton(
              onPressed: () => context.push(const CreateEstimatePage()),
              child: const Text('Create Estimate'),
            ),

            ElevatedButton(onPressed: () => context.push(const EditRatePage()), child: const Text('Edit Rate')),
          ],
        ),
      ),
    );
  }
}
