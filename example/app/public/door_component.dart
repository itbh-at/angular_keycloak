import 'package:angular/angular.dart';

@Component(selector: 'door', template: '''
  <div class="public container">
    <h3>The Door</h3>
    <p>Everyone can stand in front of this door, even unauthenticated visitor</p>
  </div>
  ''')
class DoorComponent {}
