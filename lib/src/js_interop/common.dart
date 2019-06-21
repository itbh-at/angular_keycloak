@JS()
library js_common;

import 'package:js/js.dart' show JS;

@JS("JSON.stringify")
external String stringify(obj);

@JS("JSON.parse")
external dynamic parse(obj);
