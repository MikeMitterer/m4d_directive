/*
 * Copyright (c) 2015, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 * 
 * All Rights Reserved.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library m4d_directive;

//@MirrorsUsed(metaTargets: const [ MdlComponentModelAnnotation ])
//import 'dart:mirrors';

import 'dart:html' as dom;
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:logging/logging.dart';
import 'package:validate/validate.dart';

import "package:m4d_core/core/interfaces.dart";

import "package:m4d_core/m4d_core.dart";

export "package:m4d_core/m4d_core.dart";

import "package:m4d_core/m4d_ioc.dart" as ioc;

import "package:m4d_components/m4d_components.dart";
//import "package:m4d_components/m4d_formatter.dart";

import 'package:m4d_flux/m4d_flux.dart';
export 'package:m4d_flux/m4d_flux.dart';

import 'directive/components/interfaces/stores.dart';
import 'services.dart' as service;

part "directive/components/MaterialClass.dart";
part "directive/components/MaterialAttribute.dart";
part "directive/components/MaterialModel.dart";
part "directive/components/model/ModelObserver.dart";
part "directive/components/model/ModelObserverFactory.dart";


part "directive/utils.dart";

/// Default implementation for SimpleValueStore
///
/// Overwrite it like this:
///     class MyDataStore extends Emitter implements SimpleValueStore {
///         ...
///     }
///
///     main() {
///         ioc.IOCContainer().bind(service.SimpleDataStore).to(MyDataStore());
///     }
///
///     void somewhereInYourCode() {
///         final store = ioc.IOCContainer().resolve(service.SimpleDataStore).as<MyDataStore>();
///     }
class DefaultSimpleDataStore extends Emitter implements SimpleValueStore {
    @protected
    final bindings = Map<String, ObservableProperty>();

    @override
    bool asBool(final String varname) {
        if(bindings.containsKey(varname)) {
            return bindings[varname].toBool();
        }
        return false;
    }

    @override
    bool contains(final String varname) => bindings.containsKey(varname);

    @override
    ObservableProperty<T> prop<T>(final String varname,{
            final T initWith = null, final FormatObservedValue<T> formatter = null }) {

        if(!bindings.containsKey(varname)) {
            bindings[varname] = ObservableProperty<T>(initWith, formatter: formatter);
            //print("$varname changed...");
            bindings[varname].onChange.listen((_) => emitChange());
        }
        
        if(formatter != null) {
            bindings[varname].onFormat(formatter);
        }
        
        return bindings[varname];
    }
}

void registerMdlDirectiveComponents() {
    registerMaterialAttribute();
    registerMaterialClass();
    registerMaterialModel();
    
    // registerMaterialObserve();
    // registerMaterialTranslate();

    //componentHandler().addModule(_directiveModule);

}

class DirectivesModule extends ioc.IOCModule {
    // One instance for SimpleDataStore and for SimpleValueStoree
    final _store = DefaultSimpleDataStore();

    @override
    configure() {
        registerMdlDirectiveComponents();

        ioc.IOCContainer().bind(service.SimpleDataStore).to(_store);
        ioc.IOCContainer().bind(service.SimpleValueStore).to(_store);
    }

//    @override
//    List<ioc.IOCModule> get dependsOn => [ FormatterModule() ];
}