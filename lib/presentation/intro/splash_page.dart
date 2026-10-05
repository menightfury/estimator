import 'dart:async';

import 'package:estimator/common_libs.dart';
import 'package:estimator/main.dart';
import 'package:estimator/presentation/estimate/create_estimate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final Timer _timer;
  late final Completer<void> _completer;

  @override
  void initState() {
    super.initState();
    _completer = Completer<void>();
    // show splash screen for at least 2 seconds
    _timer = Timer(2.seconds, () => _completer.complete());

    Future.wait<void>([_completer.future, Bootstrap.instance.api.initializeDatabase()]).then((_) async {
      if (!mounted) return;

      context.go(const CreateEstimatePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colors;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ~ Branding
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PhysicalModel(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8.0),
                      clipBehavior: Clip.hardEdge,
                      color: colorScheme.primaryContainer,
                      child: SizedBox(
                        height: 120.0,
                        width: 120.0,
                        child: Image.asset('assets/images/icon/icon.png', fit: BoxFit.cover),
                      ),
                    ),
                    const Gap(24.0),
                    Text(
                      'Estimator',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Gap(8.0),
                    Text(
                      'Your personal estimation manager',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
