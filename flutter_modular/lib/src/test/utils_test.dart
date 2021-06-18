import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

void initModule(ChildModule module, {List<Bind>? changeBinds, bool? initialModule}) {
  Modular.debugMode = false;
  final list = module.binds!;
  final changedList = List<Bind>.from(list);
  for (var item in list) {
    var dep = (changeBinds ?? []).firstWhereOrNull((dep) {
      return item.runtimeType == dep.runtimeType;
    });
    if (dep != null) {
      changedList.remove(item);
      changedList.add(dep);
    }
  }
  module.changeBinds(changedList);
  if (initialModule ?? false) {
    Modular.init(module);
  } else {
    Modular.bindModule(module);
  }
}

void initModules(List<ChildModule> modules, {List<Bind>? changeBinds}) {
  for (var module in modules) {
    initModule(module, changeBinds: changeBinds);
  }
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: widget,
      initialRoute: '/',
      navigatorKey: Modular.navigatorKey,
      onGenerateRoute: Modular.generateRoute,
    ),
  );
}
