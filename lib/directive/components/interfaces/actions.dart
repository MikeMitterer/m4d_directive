library m4d_directives.components.actions;

import 'package:m4d_flux/m4d_flux.dart';

// - Actions sent by our app -------------------------------------------------------------------------------------------

class ListChangedAction extends Action {
    static const ActionName NAME = const ActionName("m4d_directives.components.actions.ListChangedAction");
    const ListChangedAction() : super(ActionType.Signal, NAME);
}

class PropertyChangedAction extends DataAction<String> {
    static const ActionName NAME = const ActionName("m4d_directives.components.actions.PropertyChangedAction");
    const PropertyChangedAction(final String propertyName) : super(NAME,propertyName);
}


