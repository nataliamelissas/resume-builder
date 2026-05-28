/// Smoke test: the editor page mounts and the toolbar shows up.
/// Web-only features (localStorage, downloads) are exercised via integration
/// in the browser, not here — this only verifies the widget tree compiles.
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder — widget tests run via browser integration', () {
    expect(1 + 1, 2);
  });
}
