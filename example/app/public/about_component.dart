import 'package:angular/angular.dart';

@Component(selector: 'about', template: '''
  <h2>About Page</h2>
  <p>This is a example for keycloak service in AngularDart</p>
  <p>This particular page is accessible for anyone, even unauthenticated visitor</p>
  ''')
class AboutComponent extends Component {}
