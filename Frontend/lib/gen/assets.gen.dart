// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/b_black.png
  AssetGenImage get bBlack => const AssetGenImage('assets/images/b_black.png');

  /// File path: assets/images/b_white.png
  AssetGenImage get bWhite => const AssetGenImage('assets/images/b_white.png');

  /// File path: assets/images/chess_logo.png
  AssetGenImage get chessLogo =>
      const AssetGenImage('assets/images/chess_logo.png');

  /// File path: assets/images/k_black.png
  AssetGenImage get kBlack => const AssetGenImage('assets/images/k_black.png');

  /// File path: assets/images/k_white.png
  AssetGenImage get kWhite => const AssetGenImage('assets/images/k_white.png');

  /// File path: assets/images/logo_1p.png
  AssetGenImage get logo1p => const AssetGenImage('assets/images/logo_1p.png');

  /// File path: assets/images/logo_2p.png
  AssetGenImage get logo2p => const AssetGenImage('assets/images/logo_2p.png');

  /// File path: assets/images/logo_puzzles.png
  AssetGenImage get logoPuzzles =>
      const AssetGenImage('assets/images/logo_puzzles.png');

  /// File path: assets/images/n_black.png
  AssetGenImage get nBlack => const AssetGenImage('assets/images/n_black.png');

  /// File path: assets/images/n_white.png
  AssetGenImage get nWhite => const AssetGenImage('assets/images/n_white.png');

  /// File path: assets/images/p_black.png
  AssetGenImage get pBlack => const AssetGenImage('assets/images/p_black.png');

  /// File path: assets/images/p_white.png
  AssetGenImage get pWhite => const AssetGenImage('assets/images/p_white.png');

  /// File path: assets/images/q_black.png
  AssetGenImage get qBlack => const AssetGenImage('assets/images/q_black.png');

  /// File path: assets/images/q_white.png
  AssetGenImage get qWhite => const AssetGenImage('assets/images/q_white.png');

  /// File path: assets/images/r_black.png
  AssetGenImage get rBlack => const AssetGenImage('assets/images/r_black.png');

  /// File path: assets/images/r_white.png
  AssetGenImage get rWhite => const AssetGenImage('assets/images/r_white.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    bBlack,
    bWhite,
    chessLogo,
    kBlack,
    kWhite,
    logo1p,
    logo2p,
    logoPuzzles,
    nBlack,
    nWhite,
    pBlack,
    pWhite,
    qBlack,
    qWhite,
    rBlack,
    rWhite,
  ];
}

class $AssetsSvgsGen {
  const $AssetsSvgsGen();

  /// File path: assets/svgs/chess_logo.svg
  SvgGenImage get chessLogo => const SvgGenImage('assets/svgs/chess_logo.svg');

  /// File path: assets/svgs/ic_close_simple.svg
  SvgGenImage get icCloseSimple =>
      const SvgGenImage('assets/svgs/ic_close_simple.svg');

  /// File path: assets/svgs/ic_exclamation_circle.svg
  SvgGenImage get icExclamationCircle =>
      const SvgGenImage('assets/svgs/ic_exclamation_circle.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    chessLogo,
    icCloseSimple,
    icExclamationCircle,
  ];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// File path: assets/translations/vi.json
  String get vi => 'assets/translations/vi.json';

  /// List of all assets
  List<String> get values => [en, vi];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSvgsGen svgs = $AssetsSvgsGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
