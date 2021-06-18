import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'route_link_test.mocks.dart';

@GenerateMocks([RouteLink])
void main() {
  late RouteLink link;

  setUpAll(() {
    link = MockRouteLink();
  });

  group('Navigation', () {
    test('canPop', () {
      when(link.canPop()).thenReturn(true);
      expect(link.canPop(), true);
    });

    test('maybePop', () {
      when(link.maybePop()).thenAnswer((_) => Future.value(true));
      expect(link.maybePop(), completion(true));
    });
  });
}
