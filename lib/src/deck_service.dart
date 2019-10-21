import 'dart:convert';

import 'package:open_card_game/src/card_service.dart';

import 'card.dart';

class DeckService {
  static String encodeDeck(Map<Card, int> deck) {
    Map<int, Map<Card, int>> sets = Map();

    deck.forEach((Card card, int number) {
      sets.putIfAbsent(card.setId, () => Map<Card, int>());
      sets[card.setId][card] = number;
    });

    String result = sets.keys.map<String>((int setId) {
          return setId.toString() + "[" + encodeSet(sets[setId]);
        }).join("]") +
        "]";

    List<int> bytes = utf8.encode(result);
    return base64.encode(bytes);
  }

  static String encodeSet(Map<Card, int> cards) {
    return cards.keys.map((card) {
      return card.id.toString() +
          ((cards[card] > 1) ? "x" + cards[card].toString() : "");
    }).join(",");
  }

  static Future<Map<Card, int>> decodeDeck(String code) async {
    List<int> bytes = base64.decode(code);
    String decodedString = utf8.decode(bytes);

    return Map.fromEntries((await Future.wait(
      (decodedString.split("]")..removeLast()).map<Future<Map<Card, int>>>(
        (String setCode) async {
          List<String> codeParts = setCode.split("[");
          return await decodeSet(int.parse(codeParts[0]), codeParts[1]);
        },
      ),
    ))
        .expand((Map<Card, int> cardMap) => cardMap.entries));
  }

  static Future<Map<Card, int>> decodeSet(int setId, String setCode) async {
    Iterable<Future<MapEntry<Card, int>>> decodedCardsFutures =
        setCode.split(",").map((String code) async {
      List<String> splitNumber = code.split("x");

      int id = int.parse(splitNumber[0]);
      int number = (splitNumber.length == 2) ? int.parse(splitNumber[1]) : 1;

      Card card = await CardService.getById(setId, id);
      return MapEntry<Card, int>(card, number);
    });
    return Map.fromEntries(await Future.wait(decodedCardsFutures));
  }

  static List<Card> unmap(Map<Card, int> deck) {
    List<Card> r = List<Card>();
    deck.keys.forEach((key) {
      for (int i = 0; i < deck[key]; i++) {
        r.add(key);
      }
    });
    return r;
  }
}
