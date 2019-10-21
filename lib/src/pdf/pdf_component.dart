import 'dart:html' hide Location;
import 'dart:convert';
import 'dart:typed_data';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:open_card_game/src/pdf_service.dart';
import 'package:pdf/widgets.dart';

import '../card.dart';
import '../deck_service.dart';
import '../routes.dart';

@Component(
  selector: 'pdf',
  templateUrl: 'pdf_component.html',
  styleUrls: ['pdf_component.css'],
  directives: [coreDirectives, routerDirectives],
  providers: [],
  pipes: [commonPipes],
  exports: [Routes],
)
class PdfComponent implements OnActivate {
  PdfComponent();

  int complete = 0;
  int total = 0;

  @override
  void onActivate(_, RouterState current) async {
    List<Card> cardList = await DeckService.unmap(
        await DeckService.decodeDeck(current.parameters['deck']));

    Document pdf = Document(title: "Hexal Deck");

    List<List<Card>> cardPages = PdfService.paginateCardList(cardList);
    total = cardPages.length;
    List<Page> pages =
        await Future.wait(cardPages.map<Future<Page>>((List<Card> cards) {
      return PdfService.pageFromCards(pdf.document, cards)
        ..then((i) {
          complete += 1;
        });
    }));

    pages.forEach((Page page) {
      pdf.addPage(page);
    });

    final String raw = base64.encode(pdf.save());

    final List<int> intList = base64.decode(raw);
    final Int8List int8array = Int8List.fromList(intList);
    final Blob blob = Blob([int8array], 'application/pdf');

    String url = Url.createObjectUrlFromBlob(blob);

    AnchorElement link = AnchorElement()
      ..href = url
      ..download = 'hexal_deck.pdf'
      ..text = 'Download';

    // Insert the link into the DOM.
    var p = querySelector('#link');
    p.append(link);
  }
}
