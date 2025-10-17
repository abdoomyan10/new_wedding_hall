import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final String? backgroundImage;
  final double opacity;

  const BackgroundWidget({
    Key? key,
    required this.child,
    this.backgroundImage,
    this.opacity = 0.4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage ?? 'assets/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(opacity),
            BlendMode.darken,
          ),
        ),
      ),
      child: child,
    );
  }
}
