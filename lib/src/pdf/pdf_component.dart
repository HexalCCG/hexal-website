import 'dart:html' hide Location;
import 'dart:convert';
import 'dart:typed_data';

import 'package:angular/security.dart';
import 'package:image/image.dart' as img;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:open_card_game/src/pdf_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../asset_service.dart';
import '../card.dart';
import '../card_service.dart';
import '../deck_service.dart';
import '../routes.dart';

@Component(
  selector: 'pdf',
  templateUrl: 'pdf_component.html',
  styleUrls: ['pdf_component.css'],
  directives: [coreDirectives, routerDirectives],
  providers: [
    ClassProvider(CardService),
    ClassProvider(DeckService),
    ClassProvider(AssetService)
  ],
  pipes: [commonPipes],
  exports: [Routes, AssetService],
)
class PdfComponent implements OnActivate {
  final DeckService _deckService;
  final AssetService _assetService;

  PdfComponent(this._deckService, this._assetService);

  SafeResourceUrl iframeUrl;

  @override
  void onActivate(_, RouterState current) async {
    List<Card> cardList = await DeckService.unmap(
        await _deckService.decodeDeck(current.parameters['deck']));
    cardNumber = cardList.length;

    Document a = await PdfService.buildPdf(name: "Name", cards: cardList);

    final String raw = base64.encode(a.save());

    final List<int> intList = base64.decode(raw);
    final Int8List int8array = Int8List.fromList(intList);
    final Blob b = Blob([int8array], 'application/pdf');

    String url = Url.createObjectUrlFromBlob(b);

    AnchorElement link = AnchorElement()
      ..href = url
      ..download = 'hexal_deck.pdf'
      ..text = 'Download';

    // Insert the link into the DOM.
    var p = querySelector('#link');
    p.append(link);
  }
}
