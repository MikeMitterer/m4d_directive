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

library m4d_directives.services;

import 'package:m4d_core/m4d_ioc.dart';

/// Service-ID for [ModelObserver]
const ModelObserverFactory = Service("m4d_directive.ModelObserverFactory",ServiceType.Instance);

const SimpleDataStore = Service("m4d_directive.SimpleDataStore",ServiceType.Instance);
const SimpleValueStore = Service("m4d_directive.SimpleValueStore",ServiceType.Instance);
