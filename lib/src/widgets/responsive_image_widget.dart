import 'package:flutter/widgets.dart';

/// Inspired By https://github.com/theochampion/responsive_image

typedef ResponsiveImageBuilder = Widget Function(
  BuildContext context,
  String url,
);

/// Define the preference of scaling for available size options.
/// [ScalePreference.auto] will select the absolute closest match in the size
/// options. [ScalePreference.lower] and [ScalePreference.upper] will respectively
/// select the lower or upper size options.
enum ScalePreference { lower, auto, upper }

class ResponsiveImage extends StatelessWidget {
  const ResponsiveImage({
    Key? key,
    required this.srcSet,
    this.scalePreference = ScalePreference.auto,
    this.builder,
  }) : super(key: key);

  /// Set of possible source options, each entry containing the
  /// url of the image resource along with the width in pixel of the targeted image
  final Map<int, String> srcSet;

  /// Define the preference of scaling for available size options.
  /// [ScalePreference.Auto] will select the abosulte closest match in the size
  /// options. [ScalePreference.Lower] and [ScalePreference.Upper] will respectively
  /// select the lower or upper size options.
  /// Default to [ScalePreference.Auto]
  final ScalePreference scalePreference;

  /// Optional builder to further customize the display of the image.
  /// If not specified, [Image.network] will be used.
  final ResponsiveImageBuilder? builder;

  _selectSrcInSet(double maxWidth) {
    int srcKey = srcSet.keys.reduce((prev, curr) {
      double prevDiff = prev - maxWidth;
      double currDiff = curr - maxWidth;
      switch (scalePreference) {
        case ScalePreference.lower:
          return (currDiff <= 0 && currDiff.abs() < prevDiff.abs())
              ? curr
              : prev;
        case ScalePreference.auto:
          return (currDiff.abs() < prevDiff.abs()) ? curr : prev;
        case ScalePreference.upper:
          return (currDiff >= 0 && currDiff.abs() < prevDiff.abs())
              ? curr
              : prev;
        default:
          return prev;
      }
    });
    return srcSet[srcKey];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      String url = _selectSrcInSet(
        constraints.maxWidth * MediaQuery.of(context).devicePixelRatio,
      );

      return builder != null
          ? builder!(context, url)
          : Image.network(
              url,
              fit: BoxFit.fill,
            );
    });
  }
}
