import 'package:flutter/material.dart';

class CardBanner extends StatelessWidget {
  final Widget child;
  final BannerLocation bannerLocation;
  final Color bannerColor;
  final bool showBanner;
  final String message;
  CardBanner({
    @required this.child,
    @required this.showBanner,
    this.bannerLocation = BannerLocation.bottomStart,
    this.bannerColor = Colors.green,
    @required this.message,
  });
  @override
  Widget build(BuildContext context) {
    if (this.showBanner) {
      return ClipRect(
        child: Banner(
          location: this.bannerLocation,
          message: message,
          color: this.bannerColor,
          child: this.child,
        ),
      );
    } else {
      return this.child;
    }
  }
}
