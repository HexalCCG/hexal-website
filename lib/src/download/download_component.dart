import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import '../card.dart';
import '../card_service.dart';
import '../deck_service.dart';
import '../routes.dart';

export '../routes.dart';

@Component(
  selector: 'download',
  templateUrl: 'download_component.html',
  styleUrls: ['download_component.css'],
  directives: [coreDirectives, routerDirectives, formDirectives],
  providers: [],
  exports: [Routes],
)
class DownloadComponent {
  final Router _router;
  DownloadComponent(this._router);

  String codeBox = '';

  void onSubmit() {
    //TODO Validate deck code
    _router.navigate(Routes.pdf.toUrl({'deck': '$codeBox'}));
  }

  void onSubmitAll() async {
    var cardList = await CardService.getAll();
    var deck = Map.fromEntries(cardList.map<MapEntry<Card, int>>((Card card) {
      var number = (card.type == Type.hero) ? 2 : 1;
      return MapEntry<Card, int>(card, number);
    }));
    var code = DeckService.encodeDeck(deck);
    await _router.navigate(Routes.pdf.toUrl({'deck': '$code'}));
  }
}
