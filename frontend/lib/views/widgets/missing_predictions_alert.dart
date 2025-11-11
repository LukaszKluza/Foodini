import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:go_router/go_router.dart';

class MissingPredictionsAlert extends StatelessWidget {
  const MissingPredictionsAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.fillFormToSeePredictions,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.sp.clamp(20.0, 40.0),
                color: Colors.orangeAccent,
              ),
            ),
          ),
        ),
        Center(
          child: customRedirectButton(
            const Key('redirect_to_profile_details_button'),
            () => context.go('/profile-details'),
            Text(AppLocalizations.of(context)!.redirectToProfileDetails),
          ),
        ),
      ],
    );
  }
}
