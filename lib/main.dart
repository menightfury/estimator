import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc_observer.dart';
import 'cubit/app/app_cubit.dart';
import 'common/presentations/styles/theme.dart';
import 'common_libs.dart';
import 'database/api.dart';
import 'database/repository.dart';
import 'presentation/intro/splash_page.dart';
import 'presentation/item/items/cubit/items_cubit.dart';

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
  await Bootstrap.initialize();

  runApp(const EstimatorApp());
}

class Bootstrap {
  // preventing from calling the class
  const Bootstrap._();

  static Future<void> initialize() async {
    // Default error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    // declare directory where both the databases will be stored
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getApplicationSupportDirectory();
    // debugPrint(directory.toString());
    // Initialize hydrated storage (i.e. hive database) in that declared directory.
    // However, no need to specify hive db name separately, because `HydratedStorage` already
    // specified the name as `hydrated_box`
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb ? HydratedStorageDirectory.web : HydratedStorageDirectory(directory.path),
    );

    // Initialize local storage i.e. sqlite
    await EstimatorSqliteApi.initialize(directory);
  }
}

class EstimatorApp extends StatelessWidget {
  const EstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = EstimatorSqliteApi.instance;
    final repository = EstimatorRepository(api);

    return RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppCubit>(create: (_) => AppCubit()),
          BlocProvider<ItemsCubit>(create: (_) => ItemsCubit(repository: repository)),
        ],
        child: const _AppView(),
      ),
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
      theme: AppStyle.instance.getTheme(AppStyle.lightColorScheme),
      // darkTheme: AppStyle.instance.getTheme(darkScheme),
      // themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashPage(),
    );
  }
}
