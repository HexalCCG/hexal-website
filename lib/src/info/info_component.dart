import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../routes.dart';

export '../routes.dart';

@Component(
  selector: 'info',
  templateUrl: 'info_component.html',
  styleUrls: ['info_component.css'],
  directives: [coreDirectives, routerDirectives],
  providers: [],
  exports: [Routes],
)
class InfoComponent {}
