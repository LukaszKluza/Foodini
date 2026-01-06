import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/widgets/menu_card.dart';
import 'package:go_router/go_router.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<MainPageScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = min(MediaQuery.of(context).size.width, 800.0);
    final screenHeight = MediaQuery.of(context).size.height;

    final date = DateTime.now();
    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    Constants.mainFoodiniIcon, width: 124,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.hey},',
                      style: Styles.kaushanScriptStyle(40).copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      UserStorage().getName!.toUpperCase(),
                      style: Styles.kaushanScriptStyle(48).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 0.9 * screenHeight ? 3 : 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.1,
                      children: [
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.dailySummary,
                          icon: Icons.analytics_outlined,
                          color: Colors.orange.shade600,
                          onTap: () => context.push('/daily-summary/$formattedDate'),
                        ),
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.dailyMeals,
                          icon: Icons.restaurant_menu,
                          color: Colors.orange.shade500,
                          onTap: () => context.push('/daily-meals/$formattedDate'),
                        ),
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.dietPreferences,
                          icon: Icons.tune_rounded,
                          color: Colors.orange.shade400,
                          onTap: () => context.push('/profile-details', extra: {'from': 'main-page'}),
                        ),
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.changeCaloriesPrediction,
                          icon: Icons.auto_graph,
                          color: Colors.orange.shade500,
                          onTap: () => context.push('/calories-result'),
                        ),
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.statistics,
                          icon: Icons.query_stats_rounded,
                          color: Colors.orange.shade600,
                          onTap: () => context.push('/statistics'),
                        ),
                        buildMenuCard(
                          context,
                          title: AppLocalizations.of(context)!.myAccount,
                          icon: Icons.person_outline_rounded,
                          color: Colors.orange.shade700,
                          onTap: () => context.push('/account'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}
