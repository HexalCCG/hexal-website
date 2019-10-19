import 'dart:core';

import 'package:meta/meta.dart';
import 'package:image/src/image.dart' as img;
import 'package:open_card_game/src/asset_service.dart';
import 'package:open_card_game/src/card.dart';
import 'package:open_card_game/src/card_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfService {
  static const double mm = PdfPageFormat.mm;
  static const double pageHeight = 297 * mm;
  static const double pageWidth = 210 * mm;
  static const double cardHeight = 3.5 * PdfPageFormat.inch;
  static const double cardWidth = 2.5 * PdfPageFormat.inch;
  static const PdfPageFormat format = PdfPageFormat(pageWidth, pageHeight);

  static Future<Font> firaRegular;
  static Future<Font> firaSemiBold;
  static Future<Font> firaBold;

  static TextStyle title;
  static TextStyle typeLine;
  static TextStyle id;
  static TextStyle cardText;
  static TextStyle keyword;
  static TextStyle statsLine;

  

  static Future<Document> buildPdf(
      {@required String name, @required List<Card> cards}) async {
    Document pdf = Document(title: name);
    List<Page> pages = await Future.wait(paginateCardList(cards)
        .map<Future<Page>>(
            (List<Card> cards) => pageFromCards(pdf.document, cards)));
    pages.forEach((Page page) => pdf.addPage(page));
    return pdf;
  }

  static List<List<Card>> paginateCardList(List<Card> cards) {
    return List.generate((cards.length / 9).ceil(), (int i) {
      return cards.skip(i * 9).take(9).toList();
    });
  }

  static Future<Page> pageFromCards(
      PdfDocument document, List<Card> cards) async {
    firaRegular ??= AssetService.loadFont("assets/fonts/FiraSans-Regular.ttf");
    firaSemiBold ??=
        AssetService.loadFont("assets/fonts/FiraSans-SemiBold.ttf");
    firaBold ??= AssetService.loadFont("assets/fonts/FiraSans-Bold.ttf");
    title ??= TextStyle(font: await firaRegular, fontSize: 12);
    typeLine ??= TextStyle(font: await firaRegular, fontSize: 8);
    id ??= TextStyle(font: await firaRegular, fontSize: 7);
    cardText ??=
        TextStyle(font: await firaRegular, lineSpacing: 1, fontSize: 7);
    keyword ??=
        TextStyle(font: await firaSemiBold, lineSpacing: 1, fontSize: 7);
    statsLine ??= TextStyle(font: await firaBold, fontSize: 14);

    List<Widget> cardWidgets = await Future.wait(cards
        .map((Card card) => _buildCard(document, card))
        .toList(growable: true));
    while (cardWidgets.length < 9) {
      cardWidgets.add(
        SizedBox(
          height: cardHeight,
          width: cardWidth,
        ),
      );
    }
    return Page(
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
                children: cardWidgets.take(3).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: cardWidgets.skip(3).take(3).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: cardWidgets.skip(6).take(3).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<Widget> _buildCard(PdfDocument document, Card card) async {
    return SizedBox(
      height: cardHeight,
      width: cardWidth,
      child: Stack(
        children: [
          Stack(
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
                      child: Image(await _buildImage(document,
                          AssetService.elementImages[card.element])))),
              Positioned(
                  left: 1 * mm,
                  top: 8 * mm,
                  child: SizedBox(
                    height: 45 * mm,
                    width: 61.5 * mm,
                    child: Center(
                      child: Image(
                        await _buildImage(document,
                            AssetService.cardImage(card.setId, card.id)),
                      ),
                    ),
                  )),
              Positioned(
                  left: 2 * mm,
                  top: 54.1 * mm,
                  child: Text(card.typeLine, style: typeLine)),
              Positioned(
                right: 2 * mm,
                top: 54.1 * mm,
                child: Text(card.cardIdText, style: id),
              ),
              Positioned(
                  left: 4.1 * mm,
                  top: 58.5 * mm,
                  child: SizedBox(
                      height: 24.1 * mm,
                      width: 55.4 * mm,
                      child: await _buildCardText(document, card.text))),
              Positioned(
                  left: 1.5 * mm,
                  bottom: 1.5 * mm,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: await _buildCostRow(document, card.cost))),
              Positioned(
                  right: 2 * mm,
                  bottom: 1.2 * mm,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [Text(card.statsLine, style: statsLine)]))
            ],
          ),
          Image(
            await _buildImage(document, AssetService.frameImages[card.element]),
          ),
        ],
      ),
    );
  }

  // Expanded cost row
  static Future<List<Widget>> _buildCostRow(
      PdfDocument document, Map<Element, int> cost) async {
    Iterable<Future<List<Widget>>> a = cost.keys.map((key) async {
      return await Future.wait(
        List.generate(cost[key], (int i) async {
          return SizedBox(
            height: 4 * mm,
            width: 4 * mm,
            child: Image(
              await _buildImage(document, AssetService.elementImages[key]),
            ),
          );
        }),
      );
    });
    List<List<Widget>> b = await Future.wait(a);
    return b.expand((pair) => pair).toList();
  }

  static Future<RichText> _buildCardText(
      PdfDocument document, String text) async {
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
                await _buildImage(
                  document,
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

  static Future<PdfImage> _buildImage(
      PdfDocument document, String location) async {
    img.Image image = await AssetService.loadImage(location);
    return PdfImage(document,
        image: image.data.buffer.asUint8List(),
        width: image.width,
        height: image.height);
  }
}
