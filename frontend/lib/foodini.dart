import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'blocs/account_bloc.dart';

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
        BlocProvider(
          create: (context) => AccountBloc(
            Provider.of<AuthRepository>(context, listen: false),
            Provider.of<TokenStorageRepository>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
