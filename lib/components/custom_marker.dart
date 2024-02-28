import 'package:flutter/material.dart';

class WidgetMarker extends StatelessWidget {
  final Widget child;

  const WidgetMarker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _CustomMarkerOverlay(child: child);
  }
}

class _CustomMarkerOverlay extends StatelessWidget {
  final Widget child;

  const _CustomMarkerOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}