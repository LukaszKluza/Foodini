import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';

import 'Blocs/login_bloc.dart';
import 'app_router.dart';
import 'repository/auth_repository.dart';

class Foodini extends StatelessWidget {
  const Foodini({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<TokenStorageRepository>(create: (_) => TokenStorageRepository()),

        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, apiClient, __) => AuthRepository(apiClient),
        ),

        // BlocProvider<LoginBloc>(
        //   create: (context) => LoginBloc(context.read<AuthRepository>()),
        // ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
