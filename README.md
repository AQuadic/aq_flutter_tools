<p align="center"><a href="https://aquadic.com/" target="_blank"><img src="/AQ%20Flutter%20Tools.png"></a></p>

Made by [AQuadic](https://aquadic.com)

----------

# Getting started

## Important Links
- [AQuadic](https://aquadic.com)

## Script Requirement
This script assumes you have the requirement as the following:

- Flutter Version `">=2.9.0 <3.0.0"`
- Dart Version `">=2.15.0 <3.0.0"`

## Usage

```dart
// assume you have api response and our media in field logo
final image = ResponsiveImageModel.fromResponsiveJson(
json['logo'], fallbackImage = "https://domain.com/logo.png",
);

// get image src set ( may you need it for use is responsive image widget
image.imageSrcSets;

// get image all models
image.imageModels;

// get nearst image for this size.
image.getImage(context, width: 1200, height: 700);

```

```dart
ResponsiveImage(
  srcSet: image.imageSrcSets;
  // srcSet: {
  //   256: "https://via.placeholder.com/256",
  //   512: "https://via.placeholder.com/512",
  //   1024: "https://via.placeholder.com/1024",
  // },
  builder: (BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  },
);
```

----------

## Made with ♥ By

<p align="center"><a href="https://AQuadic.com" target="_blank"><img src="https://AQuadic.com/img/logo.svg" width="200"></a></p>
