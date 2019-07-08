import 'package:angular/angular.dart';

@Component(selector: 'unauthorized', template: '''
  <h2 style="color:red;">You are not authorized</h2>
  <p>Please turn back</p>
  ''')
class UnauthorizedComponent {}
