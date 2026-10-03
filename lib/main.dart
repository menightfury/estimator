import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc_observer.dart';
import 'cubit/app/app_cubit.dart';
import 'common/presentations/styles/theme.dart';
import 'common_libs.dart';
import 'database/api.dart';
import 'presentation/intro/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     systemNavigationBarColor: Colors.transparent, // Make bar transparent
  //     systemNavigationBarDividerColor: Colors.transparent,
  //   ),
  // );
  Bloc.observer = EstimatorBlocObserver();
  // await Bootstrap.initialize();

  runApp(const EstimatorApp());
}

class EstimatorApp extends StatelessWidget {
  const EstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final api = Bootstrap.instance.api;
    // initialize all repositories here
    // final accountRepository = AccountRepository.initialize(api);
    // AmcRepository.initialize(api);
    // TransactionRepository.initialize(api);

    return MultiBlocProvider(
      providers: [BlocProvider<AppCubit>(create: (_) => AppCubit())],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({super.key});

  @override
  Widget build(BuildContext context) {
    $logger.e('Material app rebuilds 😟.');

    return MaterialApp(
      title: 'Estimator',
      debugShowCheckedModeBanner: false,
      theme: AppStyle.instance.getTheme(ColorScheme.light()),
      // darkTheme: AppStyle.instance.getTheme(darkScheme),
      // themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashPage(),
    );
  }
}

class Bootstrap {
  final EstimatorApi api;

  // preventing from calling the class
  const Bootstrap._(this.api);

  static Bootstrap? _instance;
  static Bootstrap get instance {
    assert(_instance != null, 'No instance found, please make sure to initialize before getting instance');
    return _instance!;
  }

  static Future<Bootstrap> initialize() async {
    if (_instance != null) return _instance!;

    // Default error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    // declare directory where both the databases will be stored
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    // Initialize hydrated storage (i.e. hive database) in that declared directory.
    // However, no need to specify hive db name separately, because `HydratedStorage` already
    // specified the name as `hydrated_box`
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb ? HydratedStorageDirectory.web : HydratedStorageDirectory(directory.path),
    );

    // Initialize local storage i.e. sqlite
    final api = EstimatorApi(directory);
    return _instance = Bootstrap._(api);
  }
}
