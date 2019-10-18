import 'dart:core';

import 'package:csv/csv.dart';
import 'package:open_card_game/src/asset_service.dart';

import 'card.dart';

class CardService {
  CardService(this._assetService);
  final AssetService _assetService;
  Future<List<Card>> _cardList;

  Future<List<Card>> loadCards() async {
    List<String> data = await _assetService.loadAllSets();
    List<Card> cards = List<Card>();

    for (int i = 0; i < data.length; i++) {
      List<List<dynamic>> rows =
          const CsvToListConverter().convert(data[i]).skip(1).toList();
      cards.addAll(rows.map((List<dynamic> rowData) {
        return parseRowData(rowData, i);
      }));
    }
    return cards;
  }

  Future<List<Card>> getAll() async {
    if (_cardList == null) {
      _cardList = loadCards();
    }
    return _cardList;
  }

  Future<Card> getById(int setId, int id) async {
    List<Card> list = await getAll();
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
        attack: (data[7] == "") ? null : data[7],
        health: (data[8] == "") ? null : data[8],
        text: data[9]);
  }

  static String stringToElement(Element e) {
    switch (e) {
      case Element.fire:
        return "fire";
        break;
      case Element.earth:
        return "earth";
        break;
      case Element.air:
        return "air";
        break;
      case Element.water:
        return "water";
        break;
      case Element.spirit:
        return "spirit";
        break;
      default:
        return null;
    }
  }

  static Element elementFromString(String s) {
    switch (s) {
      case "fire":
        return Element.fire;
        break;
      case "earth":
        return Element.earth;
        break;
      case "air":
        return Element.air;
        break;
      case "water":
        return Element.water;
        break;
      case "spirit":
        return Element.spirit;
        break;
      case "any":
        return Element.any;
        break;
      default:
        return null;
    }
  }

  static Type typeFromString(String s) {
    switch (s) {
      case "creature":
        return Type.creature;
        break;
      case "spell":
        return Type.spell;
        break;
      case "item":
        return Type.item;
        break;
      case "hero":
        return Type.hero;
        break;
      case "token":
        return Type.token;
        break;
      default:
        return null;
    }
  }

  static Speed speedFromString(String s) {
    switch (s) {
      case "":
        return Speed.none;
        break;
      case "reaction":
        return Speed.instant;
        break;
      case "equip":
        return Speed.equip;
        break;
      case "field":
        return Speed.field;
        break;
      case "permanent":
        return Speed.permanent;
        break;
      default:
        return Speed.none;
        break;
    }
  }

  static Map<Element, int> costFromString(String s) {
    Map<Element, int> result = Map<Element, int>();
    if (s != "") {
      List<String> list = s.split(".");
      list.forEach((item) {
        Element e = parseElementLetter(item.substring(item.length - 1));
        int n = int.parse(item.substring(0, item.length - 1));
        result[e] = n;
      });
    }
    return result;
  }

  static Element parseElementLetter(String letter) {
    switch (letter) {
      case "s":
        return Element.spirit;
        break;
      case "r":
        return Element.any;
        break;
      case "a":
        return Element.air;
        break;
      case "w":
        return Element.water;
        break;
      case "f":
        return Element.fire;
        break;
      case "e":
        return Element.earth;
        break;
      default:
        return null;
    }
  }

  static int compareCards(Card a, Card b) {
    int c;

    c = a.element.index.compareTo(b.element.index);
    if (c != 0) {
      return c;
    }

    if ((a.type == Type.hero) && !(b.type == Type.hero)) {
      return 1;
    } else if (!(a.type == Type.hero) && (b.type == Type.hero)) {
      return -1;
    }

    c = a.totalCost.compareTo(b.totalCost);
    if (c != 0) {
      return c;
    }

    return a.name.compareTo(b.name);
  }

  static int compareId(Card a, Card b) {
    return a.id.compareTo(b.id);
  }
}
