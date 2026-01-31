import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final appRouter = AppRouter();
  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Postify',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: appRouter.router,
    );
  }
}
