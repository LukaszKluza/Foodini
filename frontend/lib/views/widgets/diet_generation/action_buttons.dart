import 'package:flutter/material.dart';

Center customCenterButton(
  Key buttonKey,
  VoidCallback onPressed,
  ButtonStyle buttonStyle,
  Widget buttonChild,
) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        key: buttonKey,
        onPressed: () {
          onPressed.call();
        },
        style: buttonStyle,
        child: buttonChild,
      ),
    ),
  );
}

Center customSubmitButton(
  Key buttonKey,
  VoidCallback onPressed,
  Widget buttonChild,
) {
  return customCenterButton(
    buttonKey,
    onPressed,
    ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFB2F2BB),
      minimumSize: const Size.fromHeight(48),
    ),
    buttonChild,
  );
}

Center customRetryButton(
    Key buttonKey,
    VoidCallback onPressed,
    Widget buttonChild,
    ) {
  return customCenterButton(
    buttonKey,
    onPressed,
    ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFDD9E74),
      minimumSize: const Size.fromHeight(48),
    ),
    buttonChild,
  );
}

Center customRedirectButton(
    Key buttonKey,
    VoidCallback onPressed,
    Widget buttonChild,
    ) {
  return customCenterButton(
    buttonKey,
    onPressed,
    ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF2D8B2),
      minimumSize: const Size.fromHeight(48),
    ),
    buttonChild,
  );
}
