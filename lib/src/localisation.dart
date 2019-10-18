import 'dart:core';

import 'card.dart';

class Localisation {
  static const Map element = {
    Element.fire: "Fire",
    Element.earth: "Earth",
    Element.air: "Air",
    Element.water: "Water",
    Element.spirit: "Spirit",
    Element.any: "Any"
  };
  static const Map type = {
    Type.creature: "Creature",
    Type.spell: "Spell",
    Type.item: "Item",
    Type.hero: "Hero",
    Type.token: "Token Creature"
  };
  static String speed(Speed speed, Type type) {
    switch (speed) {
      case Speed.none:
        return "";
        break;
      case Speed.instant:
        return "Instant";
        break;
      case Speed.equip:
        if (type == Type.item) {
          return "Equipment";
        } else {
          return "Enchantment";
        }
        break;
      case Speed.field:
        return "Field";
        break;
      case Speed.permanent:
        return "Permanent";
        break;
      default:
        return "";
        break;
    }
  }
}
