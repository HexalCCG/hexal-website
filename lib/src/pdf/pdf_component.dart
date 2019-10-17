import 'dart:html' hide Location;
import 'dart:convert';
import 'dart:typed_data';

import 'package:angular/security.dart';
import 'package:image/image.dart' as img;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
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
  int cardsLoaded = 0;
  int cardNumber = 0;
  bool loaded = false;

  Document pdf;

  TextStyle title;
  TextStyle typeLine;
  TextStyle id;
  TextStyle cardText;
  TextStyle keyword;
  TextStyle statsLine;

  static const double mm = PdfPageFormat.mm;

  static const String pdfName = "Hexal Deck";
  static const double pageHeight = 297 * mm;
  static const double pageWidth = 210 * mm;
  static const double cardHeight = 3.5 * PdfPageFormat.inch;
  static const double cardWidth = 2.5 * PdfPageFormat.inch;

  static const PdfPageFormat format = PdfPageFormat(pageWidth, pageHeight);

  @override
  void onActivate(_, RouterState current) async {
    List<Card> cardList = await _deckService
        .unmap(await _deckService.decodeDeck(current.parameters['deck']));
    cardNumber = cardList.length;

    /*
    iframeUrl = _sanitizationService.bypassSecurityTrustResourceUrl(
        "data:application/pdf;base64," + base64.encode(await buildPdf(cardList).save()));
    */

    Document a = await buildPdf(cardList);

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

  Future<Document> buildPdf(List<Card> cards) async {
    pdf = Document(title: pdfName);
    Font firaRegular = await getFont("assets/fonts/FiraSans-Regular.ttf");
    Font firaSemiBold = await getFont("assets/fonts/FiraSans-SemiBold.ttf");
    Font firaBold = await getFont("assets/fonts/FiraSans-Bold.ttf");

    title = TextStyle(font: firaRegular, fontSize: 12);
    typeLine = TextStyle(font: firaRegular, fontSize: 8);
    id = TextStyle(font: firaRegular, fontSize: 7);
    cardText = TextStyle(font: firaRegular, lineSpacing: 1, fontSize: 7);
    keyword = TextStyle(font: firaSemiBold, lineSpacing: 1, fontSize: 7);
    statsLine = TextStyle(font: firaBold, fontSize: 14);

    List<Widget> cardWidgets = List.from(
        await Future.wait(
          List<Future<Widget>>.generate(cards.length, (int i) {
            return buildCard(cards[i]);
          }),
        ),
        growable: true);

    while (cardWidgets.length % 9 != 0) {
      cardWidgets.add(
        SizedBox(
          height: cardHeight,
          width: cardWidth,
        ),
      );
    }

    int pages = (cardWidgets.length / 9).ceil();
    for (int p = 0; p < pages; p++) {
      Iterable<Widget> pageCards = cardWidgets.skip(p * 9).take(9);
      pdf.addPage(
        Page(
          pageFormat: format,
          build: (Context context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: pageCards.take(3).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: pageCards.skip(3).take(3).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: pageCards.skip(6).take(3).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return pdf;
  }

  Future<Widget> buildCard(Card card) async {
    Widget foreground = Stack(
      children: [
        Positioned(
            left: 1.9 * mm,
            top: 2.6 * mm,
            child: Text(card.name, style: title)),
        Positioned(
            left: 56 * mm,
            top: 1.5 * mm,
            child: SizedBox(
                height: 6 * mm,
                width: 6 * mm,
                child: Image(
                    await getImage(AssetService.elementImages[card.element])))),
        Positioned(
            left: 1 * mm,
            top: 8 * mm,
            child: SizedBox(
              height: 45 * mm,
              width: 61.5 * mm,
              child: Center(
                child: Image(
                  await getImage(AssetService.cardImage(card.setId, card.id)),
                ),
              ),
            )),
        Positioned(
            left: 2 * mm,
            top: 54.2 * mm,
            child: Text(card.typeLine, style: typeLine)),
        Positioned(
          right: 2 * mm,
          top: 54 * mm,
          child: Text(card.cardIdText, style: id),
        ),
        Positioned(
            left: 4.1 * mm,
            top: 58.5 * mm,
            child: SizedBox(
                height: 24.1 * mm,
                width: 55.4 * mm,
                child: await buildCardText(card.text))),
        Positioned(
            left: 1.5 * mm,
            bottom: 1.5 * mm,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: await buildCostRow(card.cost))),
        Positioned(
            right: 2 * mm,
            bottom: 1.2 * mm,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text(card.statsLine, style: statsLine)]))
      ],
    );
    Widget background = Image(
      await getImage(AssetService.frameImages[card.element]),
    );

    cardsLoaded += 1;

    return SizedBox(
      height: cardHeight,
      width: cardWidth,
      child: Stack(
        children: [
          background,
          foreground,
        ],
      ),
    );
  }

  // Simplified cost row
  /*
  Future<List<Widget>> buildCostRow(
      Document pdf, Map<Element, int> cost) async {
    Iterable<Future<List<Widget>>> a = cost.keys.map((key) async {
      List<Widget> result = List<Widget>();
      if (cost[key] > 1) {
        result.add(Text(cost[key].toString()));
      }
      result.add(LimitedBox(
          maxHeight: 16,
          maxWidth: 16,
          child: Image(await getImage(pdf, AssetService.elementImages[key]))));
      return result;
    });
    List<List<Widget>> b = await Future.wait(a);
    return b.expand((pair) => pair).toList();
  }
  */

  // Expanded cost row
  Future<List<Widget>> buildCostRow(Map<Element, int> cost) async {
    Iterable<Future<List<Widget>>> a = cost.keys.map((key) async {
      List<Widget> result = List<Widget>();
      for (int i = 0; i < cost[key]; i++) {
        result.add(SizedBox(
            height: 4 * mm,
            width: 4 * mm,
            child: Image(await getImage(AssetService.elementImages[key]))));
      }
      return result;
    });
    List<List<Widget>> b = await Future.wait(a);
    return b.expand((pair) => pair).toList();
  }

  Future<RichText> buildCardText(String text) async {
    List<InlineSpan> result = List<InlineSpan>();

    int p = 0;

    for (int i = 0; i < text.length; i++) {
      if (text[i] == "<" || text[i] == "[") {
        if (i > p) {
          result.add(TextSpan(text: text.substring(p, i)));
        }
        p = i + 1;
      }
      if (text[i] == ">") {
        if (i > p) {
          result.add(TextSpan(text: text.substring(p, i), style: keyword));
        }
        p = i + 1;
      }
      if (text[i] == "]") {
        if (i > p) {
          result.add(
            WidgetSpan(
              baseline: -0.3 * mm,
              child: Image(
                await getImage(
                  AssetService.elementImages[CardService.elementFromString(
                      text.substring(p, i).toLowerCase())],
                ),
              ),
            ),
          );
        }
        p = i + 1;
      }
    }
    if (text.length > p) {
      result.add(TextSpan(text: text.substring(p, text.length)));
    }

    return RichText(text: TextSpan(children: result, style: cardText));
  }

  Future<PdfImage> getImage(String location) async {
    img.Image image = await _assetService.loadImage(location);
    return PdfImage(pdf.document,
        image: image.data.buffer.asUint8List(),
        width: image.width,
        height: image.height);
  }

  Future<Font> getFont(String location) async {
    return _assetService.loadFont(location);
  }
}
