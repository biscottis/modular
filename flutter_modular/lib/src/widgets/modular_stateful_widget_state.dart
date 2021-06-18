import 'package:flutter/widgets.dart';
import '../../flutter_modular.dart';

abstract class ModularState<TWidget extends StatefulWidget, TBind>
    extends State<TWidget> {
  final TBind? controller = Modular.get<TBind>();

  @override
  void dispose() {
    super.dispose();
    Modular.dispose<TBind>();
  }
}

mixin ModularStateMixin<T extends StatefulWidget, TBind> on State<T> {
  final TBind? controller = Modular.get<TBind>();

  @override
  void dispose() {
    super.dispose();
    Modular.dispose<TBind>();
  }
}
