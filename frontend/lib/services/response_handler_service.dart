import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/models/logged_user.dart';
import 'package:frontend/services/user_provider.dart';

class ResponseHandlerService {
  static void handleAuthResponse({
    required BuildContext context,
    required http.Response response,
    required String successMessage,
    required String route,
    void Function(String error)? onError,
  }) {
    if (response.statusCode == 200) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final responseBody = jsonDecode(response.body);
      final loggedUser = LoggedUser.fromJson(responseBody);

      userProvider.setUser(loggedUser);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(key: Key(successMessage), content: Text(successMessage)),
      );
      context.go(route);
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        final errorDetail = responseBody["detail"].toString();

        if (onError != null) {
          onError(errorDetail);
        } else if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorDetail)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppConfig.somethingWentWrong)),
          );
        }
      }
    }
  }

  static void handleRegisterResponse({
    required BuildContext context,
    required http.Response response,
    required String successMessage,
    required String route,
    required Function(String error) onError,
  }) {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), duration: Duration(seconds: 5)),
      );

      Future.delayed(Duration(seconds: 4), () {
        if (context.mounted) {
          context.go(route);
        }
      });
    } else {
      final error =
          responseBody["detail"]?.toString() ?? AppConfig.somethingWentWrong;
      onError(error);
    }
  }
}
