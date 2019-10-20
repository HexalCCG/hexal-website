import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../routes.dart';

export '../routes.dart';

@Component(
  selector: 'download',
  templateUrl: 'download_component.html',
  styleUrls: ['download_component.css'],
  directives: [coreDirectives, routerDirectives],
  providers: [],
  exports: [Routes],
)
class DownloadComponent {
  
}
