library m4d_directives.components.interfaces;

import 'package:m4d_core/m4d_core.dart';
import 'package:m4d_flux/m4d_flux.dart';

abstract class SimpleDataStore extends Emitter {
    bool contains(final String varname);
    bool asBool(final String varname);
}

abstract class SimpleValueStore extends SimpleDataStore {
    ObservableProperty<T> value<T>(final String varname,final T value);
}

