import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../routers/modular_page.dart';

import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter>
    implements
        IModularNavigator {
  final GlobalKey<NavigatorState> navigatorKey;
  final ModularRouteInformationParser parser;
  final Map<String, ChildModule> injectMap;

  ModularRouterDelegate(this.navigatorKey, this.parser, this.injectMap);

  NavigatorState get navigator => navigatorKey.currentState;

  ModularRouter _router;

  List<ModularPage> _pages = [];

  @override
  ModularRouter get currentConfiguration => _router;

  @override
  Widget build(BuildContext context) {
    return _pages.isEmpty
        ? Material()
        : Navigator(
            key: navigatorKey,
            pages: _pages,
            onPopPage: _onPopPage,
          );
  }

  @override
  Future<void> setNewRoutePath(ModularRouter router) async {
    final page = ModularPage(
      key: ValueKey('url:${router.path}'),
      router: router,
    );
    if (_pages.isEmpty) {
      _pages.add(page);
    } else {
      _pages.last = page;
    }
    _router = router;

    rebuildPages();
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result) || route.isFirst) {
      return false;
    }

    final page = route.settings as ModularPage;
    final path = page.router.path;
    page.popRoute.complete(result);
    _pages.removeLast();
    rebuildPages();

    final trash = <String>[];

    injectMap.forEach((key, module) {
      module.paths.remove(path);
      if (module.paths.length == 0) {
        module.cleanInjects();
        trash.add(key);
        Modular.debugPrintModular(
            "-- ${module.runtimeType.toString()} DISPOSED");
      }
    });

    for (final key in trash) {
      injectMap.remove(key);
    }

    return true;
  }

  void rebuildPages() {
    _pages = List.from(_pages);
    notifyListeners();
  }

  @override
  Future<T> pushNamed<T extends Object>(String routeName,
      {Object arguments}) async {
    var router = parser.selectRoute(path);
    router = router.copyWith(args: router?.args?.copyWith(data: arguments));
    final page = ModularPage<T>(
      router: router,
    );
    _pages.add(page);
    rebuildPages();
    return page.popRoute.future;
  }

  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO result,
      Object arguments}) {
    var router = parser.selectRoute(path);
    router = router.copyWith(args: router?.args?.copyWith(data: arguments));
    final page = ModularPage<T>(
      router: router,
    );

    _onPopPage(ModularRoute(_pages.last), result);
    _pages.add(page);
    rebuildPages();
    return page.popRoute.future;
  }

  @override
  bool canPop() => navigator.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) =>
      navigator.maybePop(result);

  @override
  void pop<T extends Object>([T result]) => navigator.pop(result);

  @override
  Future<T> push<T extends Object>(Route<T> route) {
    return navigator.push<T>(route);
  }

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
          String routeName,
          {TO result,
          Object arguments}) =>
      navigator.popAndPushNamed(
        routeName,
        result: result,
        arguments: arguments,
      );

  @override
  void popUntil(bool Function(Route) predicate) =>
      navigator.popUntil(predicate);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
          String newRouteName, bool Function(Route) predicate,
          {Object arguments}) =>
      navigator.pushNamedAndRemoveUntil(newRouteName, predicate,
          arguments: arguments);

  @override
  String get modulePath => _router.modulePath;

  @override
  String get path => _router.path;
}