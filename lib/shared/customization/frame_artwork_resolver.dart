import 'asset_resolver.dart';

class FrameArtworkResolver implements AssetResolver {
  FrameArtworkResolver._();
  static final FrameArtworkResolver instance = FrameArtworkResolver._();

  static const Map<String, String> _mapping = {};

  static const Map<String, String> _directMapping = {};

  @override
  String? resolve(String? semanticId) =>
      semanticId != null ? _mapping[semanticId] : null;

  @override
  String? resolveByName(String? assetName) =>
      assetName != null ? _directMapping[assetName] : null;

  @override
  bool hasArtwork(String? semanticId) =>
      semanticId != null && _mapping.containsKey(semanticId);

  @override
  Map<String, String> get mapping => Map.unmodifiable(_mapping);
}
