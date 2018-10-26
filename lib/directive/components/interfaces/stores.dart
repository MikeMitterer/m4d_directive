library m4d_directives.components.interfaces;

import 'package:m4d_flux/m4d_flux.dart';

abstract class SimpleDataStore extends Emitter {
    bool contains(final String varname);
    bool asBool(final String varname);
}
