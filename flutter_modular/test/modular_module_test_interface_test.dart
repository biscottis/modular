import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'app/app_module_test_modular.dart';
import 'app/modules/home/home_module.dart';
import 'app/modules/home/home_module_test_modular.dart';
import 'app/modules/home/home_widget.dart';
import 'app/modules/product/product_module_test_modular.dart';
import 'app/shared/app_info.state.dart';
import 'app/shared/ilocal_repository.dart';
import 'app/shared/local_mock.dart';
import 'app/shared/local_storage_shared.dart';

class CustomModuleTestMock extends Mock implements IModularTest {}

class CustomLocalStorage extends Mock implements ILocalStorage {}

void main() {
  group("change bind", () {
    IModularTest appModularHelper = InitAppModuleHelper();
    setUp(() {
      appModularHelper.load();
    });
    test('ILocalStorage is a LocalMock', () {
      expect(Modular.get<ILocalStorage>(), isA<LocalMock>());
    });

    tearDown(() {
      appModularHelper.memoryManage(ModularTestType.resetModules);
    });
  });
  group("IModuleTest", () {
    ILocalStorage? localStorageBeforeReload;
    setUp(() {
      InitAppModuleHelper().load();
      Modular.get<ILocalStorage>();
    });

    // ILocalStorage localStorageBeforeReload = ;

    test('ILocalStorage is not equal when reload by default', () {
      final localStorageAfterReload = Modular.get<ILocalStorage>();

      expect(localStorageBeforeReload.hashCode,
          isNot(equals(localStorageAfterReload.hashCode)));
    });
    test('ILocalStorage is equals when keepModulesOnMemory', () {
      localStorageBeforeReload = Modular.get<ILocalStorage>();
      InitAppModuleHelper(modularTestType: ModularTestType.keepModulesOnMemory)
          .load();
      final localStorageAfterReload = Modular.get<ILocalStorage>();
      expect(localStorageBeforeReload.hashCode,
          equals(localStorageAfterReload.hashCode));
    });
    test('ILocalStorage Change bind when load on runtime', () {
      IModularTest modularTest = InitAppModuleHelper();
      modularTest.load();

      final localStorageBeforeChangeBind = Modular.get<ILocalStorage>();
      expect(localStorageBeforeChangeBind.runtimeType, equals(LocalMock));

      modularTest.load(changeBinds: [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
      ]);
      final localStorageAfterChangeBind = Modular.get<ILocalStorage>();

      expect(localStorageAfterChangeBind.runtimeType,
          equals(LocalStorageSharePreference));
    });
    test('ILocalStorage getDendencies', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getDendencies(isLoadDependency: true), isNull);
      expect(
        modularTest.getDendencies(
          changedependency: InitAppModuleHelper(),
          isLoadDependency: true,
        ),
        isNotNull,
      );
    });
    test('ILocalStorage getBinds', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getBinds([]).length, modularTest.binds.length);
      expect(modularTest.getBinds(null), isNotEmpty);
      expect(modularTest.getBinds(null).first,
          isInstanceOf<Bind<ILocalStorage>>());

      final stringBind = Bind<String>((i) => "teste");
      final changeBinds = [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
        stringBind,
      ];

      expect(modularTest.getBinds(changeBinds), containsAll(changeBinds));
    });
    test('ILocalStorage mergeBinds', () {
      IModularTest modularTest = InitAppModuleHelper();
      final stringBind = Bind<String>((i) => "teste");
      final changeBinds = [
        Bind<ILocalStorage>((i) => LocalMock()),
      ];
      final defaultBinds = [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
        stringBind,
      ];

      expect(modularTest.mergeBinds(changeBinds, defaultBinds),
          containsAll([changeBinds.first, stringBind]));
      expect(modularTest.mergeBinds(changeBinds, null), equals(changeBinds));
      expect(modularTest.mergeBinds(null, defaultBinds), equals(defaultBinds));
      expect(modularTest.mergeBinds(null, null), equals([]));
    });
    test('ILocalStorage memoryManage', () {
      IModularTest modularTest = InitAppModuleHelper();

      modularTest.load();
      expect(Modular.get<ILocalStorage>(), isNotNull);

      modularTest.memoryManage(ModularTestType.keepModulesOnMemory);
      expect(Modular.get<ILocalStorage>(), isNotNull);

      modularTest.memoryManage(ModularTestType.resetModules);

      expect(
        Modular.get,
        throwsA(
          isInstanceOf<ModularError>(),
        ),
      );
    });
    test('ILocalStorage loadModularDependency', () {
      IModularTest modularTest = InitAppModuleHelper();

      final customModule = CustomModuleTestMock();
      when(customModule.load(changeBinds: anyNamed("changeBinds")))
          .thenReturn(() {});

      modularTest.loadModularDependency(
        isLoadDependency: true,
        changeBinds: [],
        dependency: customModule,
      );
      verify(customModule.load(changeBinds: anyNamed("changeBinds"))).called(1);

      modularTest.loadModularDependency(
        isLoadDependency: false,
        changeBinds: [],
        dependency: customModule,
      );
      verifyNever(customModule.load(changeBinds: anyNamed("changeBinds")));
    });
    test('ILocalStorage load HomeModule', () {
      IModularTest homeModuleTest = InitHomeModuleHelper();
      expect(
        Modular.get,
        throwsA(
          isInstanceOf<ModularError>(),
        ),
      );

      homeModuleTest.load();
      expect(
        Modular.get<AppState>(),
        isNotNull,
      );
    });

    test('Changing binds of parent modules', () {
      IModularTest homeModuleTest = InitHomeModuleHelper();

      homeModuleTest.load();
      final instance = Modular.get<ILocalStorage>();

      expect(
        instance,
        isInstanceOf<LocalMock>(),
      );

      homeModuleTest.load(changeBinds: [
        Bind<ILocalStorage>(
          (i) => CustomLocalStorage(),
        )
      ]);

      expect(
        Modular.get<ILocalStorage>(),
        isInstanceOf<CustomLocalStorage>(),
      );

      homeModuleTest.load(changeBinds: [
        Bind<String>(
          (i) => "test",
        )
      ]);

      expect(
        Modular.get<ILocalStorage>(),
        isInstanceOf<LocalMock>(),
      );

      expect(
        Modular.get,
        throwsA(isInstanceOf<ModularError>()),
      );
    });

    // tearDown(() {
    //   Modular.removeModule(app);
    // });
  });
  group("navigation test", () {
    // As both share the same parent,
    // you can pass by changeDependency and it can load in a row
    IModularTest modularProductTest = InitProductModuleHelper();
    setUp(() {
      InitProductModuleHelper().load(
        changedependency: InitHomeModuleHelper(),
      );
    });
    testWidgets('on pushNamed modify actualRoute ', (tester) async {
      await tester.pumpWidget(buildTestableWidget(HomeWidget()));
      Modular.to.pushNamed('/product');
      expect(Modular.to.path, '/product');
    });
    tearDown(() {
      modularProductTest.memoryManage(ModularTestType.resetModules);
    });
  });
  group("arguments test", () {
    IModularTest modularHomeTest = InitHomeModuleHelper();

    setUpAll(() {
      modularHomeTest.load();
    });
    testWidgets("Arguments Page id", (tester) async {
      await tester.pumpWidget(buildTestableWidget(ArgumentsPage(
        id: 10,
      )));
      final titleFinder = find.text("10");
      expect(titleFinder, findsOneWidget);
    });
    testWidgets("Modular Arguments Page id", (tester) async {
      Modular.arguments(data: 10);
      await tester.pumpWidget(buildTestableWidget(ModularArgumentsPage()));
      final titleFinder = find.text("10");
      expect(titleFinder, findsOneWidget);
    });
    tearDownAll(() {
      modularHomeTest.memoryManage(ModularTestType.resetModules);
    });
  });
}
