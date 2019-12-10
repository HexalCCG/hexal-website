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
    var cardList = await DeckService.unmap(
        await DeckService.decodeDeck(current.parameters['deck']));

    var pdf = Document(title: 'Hexal Deck');

    var cardPages = PdfService.paginateCardList(cardList);
    total = cardPages.length;
    var pages =
        await Future.wait(cardPages.map<Future<Page>>((List<Card> cards) {
      return PdfService.pageFromCards(pdf.document, cards)
        ..then((i) {
          complete += 1;
        });
    }));

    pages.forEach((Page page) {
      pdf.addPage(page);
    });

    final raw = base64.encode(pdf.save());

    final List<int> intList = base64.decode(raw);
    final int8array = Int8List.fromList(intList);
    final blob = Blob([int8array], 'application/pdf');

    final url = Url.createObjectUrlFromBlob(blob);

    final link = AnchorElement()
      ..href = url
      ..download = 'hexal_deck.pdf'
      ..text = 'Download';

    // Insert the link into the DOM.
    var p = querySelector('#link');
    p.append(link);
  }
}
