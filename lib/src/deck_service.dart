import 'dart:convert';

import 'package:angular/angular.dart';

import 'card.dart';
import 'card_service.dart';

@Component(
  selector: 'deck-service',
  template: '',
  directives: [coreDirectives],
  providers: [ClassProvider(CardService)],
  pipes: [commonPipes],
)
class DeckService {
  final CardService _cardService;
  DeckService(this._cardService);

  String generateCode(Map<Card, int> deck) {
    String list = deck.keys.map((card) {
      return card.setId.toString() +
          "." +
          card.id.toString() +
          ((deck[card] > 1) ? "x" + deck[card].toString() : "");
    }).join(",");

    List<int> bytes = utf8.encode(list);
    return base64.encode(bytes);
  }

  List<Card> unmap(Map<Card, int> deck) {
    List<Card> r = List<Card>();
    deck.keys.forEach((key) {
      for (int i = 0; i < deck[key]; i++) {
        r.add(key);
      }
    });
    return r;
  }

  Future<Map<Card, int>> decodeDeck(String code) async {
    List<int> bytes = base64.decode(code);
    String s = utf8.decode(bytes);

    Iterable<Future<MapEntry<Card, int>>> decodedCardsFutures =
        s.split(",").map((String code) async {
      List<String> splitNumber = code.split("x");
      List<String> splitSet = splitNumber[0].split(".");

      int setId = int.parse(splitSet[0]);
      int id = int.parse(splitSet[1]);
      int number = (splitNumber.length == 2) ? int.parse(splitNumber[1]) : 1;

      Card card = await _cardService.getById(setId, id);
      return MapEntry<Card, int>(card, number);
    });
    return Map.fromEntries(await Future.wait(decodedCardsFutures));
  }
}
