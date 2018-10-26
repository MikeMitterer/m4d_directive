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
import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:validate/validate.dart';
import 'package:l10n/l10n.dart';

import "package:m4d_core/core/interfaces.dart";

import "package:m4d_core/m4d_core.dart";
export "package:m4d_core/m4d_core.dart";

import "package:m4d_core/m4d_ioc.dart" as ioc;

//import "package:m4d_components/m4d_components.dart";
//import "package:m4d_components/m4d_formatter.dart";

import 'package:m4d_flux/m4d_flux.dart';
export 'package:m4d_flux/m4d_flux.dart';

import 'directive/components/interfaces/stores.dart';
import 'services.dart' as service;

//part "directive/components/MaterialAttribute.dart";
part "directive/components/MaterialClass.dart";
//part "directive/components/MaterialModel.dart";
//part "directive/components/MaterialObserve.dart";
//part "directive/components/MaterialTranslate.dart";

//part "directive/components/model/ModelObserver.dart";
//part "directive/components/model/ModelObserverFactory.dart";

part "directive/utils.dart";

//class MdlDirectiveModule extends Module {
//  @override
//  configure() {
//      bind(ModelObserverFactory);
//  }
//}
//final MdlDirectiveModule _directiveModule = new MdlDirectiveModule();

class _DummyStore extends SimpleDataStore {
  @override
  bool asBool(final String varname) => false;

  @override
  bool contains(final String varname) => false;
}


void registerMdlDirectiveComponents() {

    // registerMaterialAttribute();
    registerMaterialClass();
    // registerMaterialModel();
    // registerMaterialObserve();
    // registerMaterialTranslate();

    //componentHandler().addModule(_directiveModule);

}

class DirectivesModule extends ioc.IOCModule {
    @override
    configure() {
        registerMdlDirectiveComponents();

        ioc.IOCContainer().bind(service.SimpleDataStore).to(_DummyStore());
    }

//    @override
//    List<ioc.IOCModule> get dependsOn => [ FormatterModule() ];
}