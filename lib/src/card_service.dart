import 'dart:core';

import 'package:csv/csv.dart';
import 'package:open_card_game/src/asset_service.dart';

import 'card.dart';

class CardService {
  static Future<List<Card>> _cardList;

  static Future<List<Card>> loadCards() async {
    var data = await AssetService.loadAllSets();
    var cards = <Card>[];

    for (var i = 0; i < data.length; i++) {
      var rows = const CsvToListConverter().convert(data[i]).skip(1).toList();
      cards.addAll(rows.map((List<dynamic> rowData) {
        return parseRowData(rowData, i);
      }));
    }
    return cards;
  }

  static Future<List<Card>> getAll() async {
    _cardList ??= loadCards();
    return _cardList;
  }

  static Future<Card> getById(int setId, int id) async {
    var list = await getAll();
    return list.singleWhere((Card card) {
      return card.id == id && card.setId == setId;
    });
  }

  static Card parseRowData(List<dynamic> data, int setId) {
    return Card(
        setId: setId,
        id: data[0],
        version: data[1],
        name: data[2],
        element: elementFromString(data[3].toLowerCase()),
        type: typeFromString(data[4].toLowerCase()),
        speed: speedFromString(data[5].toLowerCase()),
        cost: costFromString(data[6]),
        attack: (data[7] == '') ? null : data[7],
        health: (data[8] == '') ? null : data[8],
        text: data[9]);
  }

  static String stringToElement(Element e) {
    switch (e) {
      case Element.fire:
        return 'fire';
        break;
      case Element.earth:
        return 'earth';
        break;
      case Element.air:
        return 'air';
        break;
      case Element.water:
        return 'water';
        break;
      case Element.spirit:
        return 'spirit';
        break;
      default:
        return null;
    }
  }

  static Element elementFromString(String s) {
    switch (s) {
      case 'fire':
        return Element.fire;
        break;
      case 'earth':
        return Element.earth;
        break;
      case 'air':
        return Element.air;
        break;
      case 'water':
        return Element.water;
        break;
      case 'spirit':
        return Element.spirit;
        break;
      case 'any':
        return Element.any;
        break;
      default:
        return null;
    }
  }

  static Type typeFromString(String s) {
    switch (s) {
      case 'creature':
        return Type.creature;
        break;
      case 'spell':
        return Type.spell;
        break;
      case 'item':
        return Type.item;
        break;
      case 'hero':
        return Type.hero;
        break;
      case 'token':
        return Type.token;
        break;
      default:
        return null;
    }
  }

  static Speed speedFromString(String s) {
    switch (s) {
      case '':
        return Speed.none;
        break;
      case 'instant':
        return Speed.instant;
        break;
      case 'equip':
        return Speed.equip;
        break;
      case 'field':
        return Speed.field;
        break;
      case 'permanent':
        return Speed.permanent;
        break;
      default:
        return Speed.none;
        break;
    }
  }

  static Map<Element, int> costFromString(String s) {
    var result = <Element, int>{};
    if (s != '') {
      var list = s.split('.');
      list.forEach((item) {
        var e = parseElementLetter(item.substring(item.length - 1));
        var n = int.parse(item.substring(0, item.length - 1));
        result[e] = n;
      });
    }
    return result;
  }

  static Element parseElementLetter(String letter) {
    switch (letter) {
      case 's':
        return Element.spirit;
        break;
      case 'r':
        return Element.any;
        break;
      case 'a':
        return Element.air;
        break;
      case 'w':
        return Element.water;
        break;
      case 'f':
        return Element.fire;
        break;
      case 'e':
        return Element.earth;
        break;
      default:
        return null;
    }
  }

  static int compareCards(Card a, Card b) {
    var setDiff = a.setId.compareTo(b.setId);
    if (setDiff != 0) {
      return setDiff;
    }

    var elementDiff = a.element.index.compareTo(b.element.index);
    if (elementDiff != 0) {
      return elementDiff;
    }

    if ((a.type == Type.hero) && !(b.type == Type.hero)) {
      return 1;
    } else if (!(a.type == Type.hero) && (b.type == Type.hero)) {
      return -1;
    }

    var costDiff = a.totalCost.compareTo(b.totalCost);
    if (costDiff != 0) {
      return costDiff;
    }

    return a.name.compareTo(b.name);
  }

  static int compareId(Card a, Card b) {
    return a.id.compareTo(b.id);
  }
}
