import 'package:flutter/material.dart' show BuildContext, MediaQuery;
import 'package:quiver/strings.dart';

/// We use this Responsive image model to match our APIs.
/// Specially Laravel APIs using Spatie's Media Library.
/// https://spatie.be/docs/laravel-medialibrary.
///
/// as api response will be either
///
/// ```json
/// cover_collection: {
///     id: 10,
///     uuid: "badce664-3772-491d-810b-c932147275df",
///     name: "image name",
///     file_name: "image_name.jpg",
///     mime_type: "image/jpeg",
///     size: 273335,
///     responsive_urls: [
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_800_600.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_669_501.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_560_420.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_468_351.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_391_293.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_327_245.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_274_205.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_229_171.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_192_144.jpg",
///          "https://domain.com/storage/10/responsive-images/image_name___media_library_original_160_120.jpg"
///     ]
///     },
/// ```
///
/// or for custom conversations
///
/// ```json
/// logo: {
///     id: 50,
///     uuid: "9fc739d4-3be0-463d-b4d7-acc373ba59a9",
///     name: "0044cc",
///     file_name: "0044cc.png",
///     mime_type: "image/png",
///     size: 1849,
///     generated_conversions: {
///          small: true,
///          medium: true,
///          large: true
///     },
///     order_column: 50,
///     created_at: "2022-01-04T19:18:46.000000Z",
///     updated_at: "2022-01-04T19:18:46.000000Z",
///     url: "https://domain.com/storage/50/0044cc.png",
///     large: "https://domain.com/storage/50/conversions/0044cc-large.jpg",
///     medium: "https://domain.com/storage/50/conversions/0044cc-medium.jpg",
///     small: "https://domain.com/storage/50/conversions/0044cc-small.jpg",
///     collection: "logo"
///     }
/// ```

class ResponsiveImageModel {
  int? id;
  String? uuid;
  String? name;
  String? fileName;
  String? mimeType;
  String? url;
  num? size;
  String? _fallbackImage;
  List<ImageSize>? _images;

  List<ImageSize> get imageModels => (_images ?? <ImageSize>[]);

  ResponsiveImageModel.fromResponsiveJson(json, {String? fallbackImage}) {
    _fallbackImage = fallbackImage;

    if (json != null) {
      id = json['id'];
      uuid = json['uuid'];
      name = json['name'];
      fileName = json['file_name'];
      mimeType = json['mime_type'];
      url = json['url'];
      size = json['size'];
      for (final img in json['responsive_urls']) {
        (_images ??= <ImageSize>[]).add(ImageSize.fromLink(img));
      }
    }
  }

  ResponsiveImageModel.fromImageConversion(
    json, {
    String? fallbackImage,
    num generatedStartSize = 200,
    num incrementSize = 200,
  }) {
    _fallbackImage = fallbackImage;

    if (json != null) {
      id = json['id'];
      uuid = json['uuid'];
      name = json['name'];
      fileName = json['file_name'];
      mimeType = json['mime_type'];
      url = json['url'];
      size = json['size'];

      for (final img in json['generated_conversions'].keys) {
        if (json.containsKey(img)) {
          (_images ??= <ImageSize>[]).add(ImageSize(
            link: json[img],
            height: generatedStartSize,
            width: generatedStartSize,
          ));

          generatedStartSize += incrementSize;
        }
      }
    }
  }

  Map<int, String> get imageSrcSets {
    final _map = <int, String>{};
    for (var element in imageModels) {
      _map.addAll(element.toMap());
    }

    if (isNotEmpty(_fallbackImage)) {
      _map[9999999999] = _fallbackImage ?? '';
    }

    return _map;
  }

  String getImage(BuildContext context, {num? width, num? height}) {
    // Return Fallback Image if no images persist.
    if (imageModels.isEmpty) return _fallbackImage ?? '';

    // Generate Sizes if not available.
    if (width == null && height == null) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }

    return _getNearestNumber(width: width, height: height);
  }

  String _getNearestNumber({num? width, num? height}) {
    // Return Fallback Image if no images persist.
    if (imageModels.isEmpty) return _fallbackImage ?? '';

    // Start getting preferred image.
    List<ImageSize> greater = imageModels;

    if (width != null) {
      greater = imageModels.where((e) => e.width >= width).toList()
        ..sort((a, b) => a.width.compareTo(b.width));
    } else if (height != null) {
      greater = imageModels.where((e) => e.height >= height).toList()
        ..sort((a, b) => a.height.compareTo(b.height));
    }

    return greater.isEmpty ? imageModels.first.link : greater.first.link;
  }

  @override
  String toString() {
    return imageModels.isEmpty ? '' : imageModels.first.toString();
  }
}

class ImageSize {
  String link;
  late num width;
  late num height;

  ImageSize({required this.link, required this.width, required this.height});

  ImageSize.fromLink(this.link) {
    final _splits = link.split("_");
    width = num.parse(_splits[_splits.length - 2].split(".").first);
    height = num.parse(_splits.last.split(".").first);
  }

  Map<int, String> toMap() => {width.toInt(): link};

  @override
  String toString() {
    return '$link - @@ - ${width}w ${height}h';
  }
}
