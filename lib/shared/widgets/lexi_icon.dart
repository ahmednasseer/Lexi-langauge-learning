import 'package:flutter/material.dart';

class LexiIcon extends StatelessWidget {
  final String? assetPath;
  final IconData? materialIcon;
  final double size;
  final String? semanticLabel;
  final Color? color;

  const LexiIcon({
    super.key,
    this.assetPath,
    this.materialIcon,
    this.size = 24,
    this.semanticLabel,
    this.color,
  }) : assert(assetPath != null || materialIcon != null,
            'Either assetPath or materialIcon must be provided');

  const LexiIcon.asset(
    String path, {
    super.key,
    this.size = 24,
    this.semanticLabel,
    this.color,
  })  : assetPath = path,
        materialIcon = null;

  const LexiIcon.material(
    IconData icon, {
    super.key,
    this.size = 24,
    this.semanticLabel,
    this.color,
  })  : assetPath = null,
        materialIcon = icon;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Semantics(
        label: semanticLabel ?? '',
        child: Image.asset(
          assetPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          color: color,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: size, color: color),
        ),
      );
    }

    return Semantics(
      label: semanticLabel ?? '',
      child: Icon(materialIcon, size: size, color: color),
    );
  }
}
