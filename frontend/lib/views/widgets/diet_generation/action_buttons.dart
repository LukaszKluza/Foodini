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
      backgroundColor: const Color(0xFF3B9B49),
      minimumSize: const Size.fromHeight(48),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
      backgroundColor: Colors.red,
      minimumSize: const Size.fromHeight(48),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
      backgroundColor: Colors.orange,
      minimumSize: const Size.fromHeight(48),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    buttonChild,
  );
}
