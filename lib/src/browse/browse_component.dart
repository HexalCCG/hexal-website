import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:open_card_game/src/asset_service.dart';

import '../card.dart';
import '../card_service.dart';
import '../routes.dart';

export '../routes.dart';

@Component(
  selector: 'browse',
  templateUrl: 'browse_component.html',
  styleUrls: ['browse_component.css'],
  directives: [coreDirectives, routerDirectives, formDirectives],
  providers: [],
  exports: [Routes, AssetService],
)
class BrowseComponent implements OnInit {
  BrowseComponent();

  String searchBox = '';
  String selectedElement;
  int selectedMana;

  List<Card> allCards;
  List<Card> cards;

  @override
  Future<void> ngOnInit() async {
    allCards = await CardService.getAll();
    filter();
  }

  void selectElement(String string) {
    if (selectedElement == string) {
      selectedElement = null;
    } else {
      selectedElement = string;
    }
    filter();
  }

  void selectMana(int i) {
    if (selectedMana == i) {
      selectedMana = null;
    } else {
      selectedMana = i;
    }
    filter();
  }

  void filter() {
    cards = <Card>[...allCards];
    if (selectedElement != null) {
      cards.retainWhere((Card card) {
        return card.element == CardService.elementFromString(selectedElement);
      });
    }
    if (selectedMana != null) {
      cards.retainWhere((Card card) {
        return card.totalCost == selectedMana;
      });
    }
    if (searchBox != '') {
      cards.retainWhere((Card card) {
        return card.searchableText
            .toLowerCase()
            .replaceAll(RegExp(r'\W+'), '')
            .contains(searchBox.toLowerCase().replaceAll(RegExp(r'\W+'), ''));
      });
    }
    cards.sort(CardService.compareCards);
  }
}
