abstract class AssetResolver {
  String? resolve(String? semanticId);
  String? resolveByName(String? assetName);
  bool hasArtwork(String? semanticId);
  Map<String, String> get mapping;
}
