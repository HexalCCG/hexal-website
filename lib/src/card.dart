import 'package:open_card_game/src/asset_service.dart';
import 'package:open_card_game/src/localisation.dart';
import 'package:meta/meta.dart';

enum Element { fire, earth, air, water, spirit, any }
enum Type { creature, spell, item, hero, token }
enum Speed { none, instant, equip, field, permanent }

class Card {
  Card(
      {@required this.setId,
      @required this.id,
      @required this.version,
      @required this.name,
      @required this.element,
      @required this.type,
      @required this.speed,
      @required this.cost,
      @required this.attack,
      @required this.health,
      @required this.text})
      : totalCost = cost.values.fold(0, (a, b) => a + b);

  final int setId;
  final int id;
  final int version;
  final String name;
  final Element element;
  final Type type;
  final Speed speed;
  final Map<Element, int> cost;
  final int totalCost;
  final int attack;
  final int health;
  final String text;

  String get typeLine {
    String r;
    r = Localisation.type[type];
    if (speed != Speed.none) {
      r += ' - ' + Localisation.speed(speed, type);
    }
    return r;
  }

  String get statsLine {
    if (attack != null && health != null) {
      if (type == Type.creature || type == Type.token) {
        return attack.toString() + ' / ' + health.toString();
      } else {
        return (attack >= 0 ? '+' + attack.toString() : attack.toString()) +
            ' / ' +
            (health >= 0 ? '+' + health.toString() : health.toString());
      }
    } else {
      return '';
    }
  }

  String get image {
    return AssetService.cardImage(setId, id);
  }

  String get elementImage {
    return AssetService.elementImages[element];
  }

  String get paddedId {
    return id.toString().padLeft(3, '0');
  }

  String get cardIdText {
    return '[' +
        setId.toString() +
        '.' +
        paddedId +
        ']' +
        (version > 1 ? ('.' + version.toString()) : '');
  }

  String get searchableText {
    return paddedId + ' ' + name + ' ' + typeLine + ' ' + text;
  }
}
