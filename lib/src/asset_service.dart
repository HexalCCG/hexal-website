import 'dart:core';
import 'package:http/http.dart';

import 'package:image/image.dart';
import 'package:pdf/widgets.dart' hide Image;

import 'card.dart';

class AssetService {
  static const maxSet = 1;

  static const Map<Element, String> elementImages = {
    Element.spirit: "assets/icons/element-spirit.png",
    Element.fire: "assets/icons/element-fire.png",
    Element.air: "assets/icons/element-air.png",
    Element.earth: "assets/icons/element-earth.png",
    Element.water: "assets/icons/element-water.png",
    Element.any: "assets/icons/element-any.png",
  };

  static const Map<Element, String> frameImages = {
    Element.spirit: "assets/card-frames/spirit.png",
    Element.fire: "assets/card-frames/fire.png",
    Element.air: "assets/card-frames/air.png",
    Element.earth: "assets/card-frames/earth.png",
    Element.water: "assets/card-frames/water.png",
    Element.any: "assets/card-frames/any.png",
  };

  Map<String, Future<Image>> imageMap = Map<String, Future<Image>>();
  Map<String, Future<Font>> fontMap = Map<String, Future<Font>>();
  Map<int, Future<String>> setMap = Map<int, Future<String>>();

  static String setLocation(int id) {
    return "assets/data/set-" + id.toString().padLeft(2, '0') + ".csv";
  }

  static String cardImage(int setId, int id) {
    return "assets/card-images/full/set-" +
        setId.toString().padLeft(2, '0') +
        "/" +
        id.toString().padLeft(3, '0') +
        ".png";
  }

  Future<String> loadSet(int setId) {
    if (!setMap.containsKey(setId)) {
      setMap[setId] = read(setLocation(setId));
    }
    return setMap[setId];
  }

  Future<List<String>> loadAllSets() {
    for (int i = 0; i <= maxSet; i++) {
      loadSet(i);
    }
    return Future.wait(setMap.values);
  }

  Future<Image> loadImage(String location) {
    if (!imageMap.containsKey(location)) {
      imageMap[location] =
          readBytes(location).then((data) => decodeImage(data));
    }
    return imageMap[location];
  }

  Future<Font> loadFont(String location) {
    if (!fontMap.containsKey(location)) {
      fontMap[location] = readBytes(location)
          .then((data) => Font.ttf(data.buffer.asByteData()));
    }
    return fontMap[location];
  }
}
