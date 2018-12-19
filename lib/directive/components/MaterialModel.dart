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
part of m4d_directive;

/// Usage (HTML):
///
///      <div class="mdl-textfield">
///             <input class="mdl-textfield__input" type="text" id="sample1" mdl-model="modelTest.minimodel"/>
///            <label class="mdl-textfield__label" for="sample1">Type Something...</label>
///      </div>
///      
/// Usage (Dart):
///
///     @Model
///     class ModelTest {
///         final ObservableProperty<String> minimodel = new ObservableProperty<String>("test");
///     }
///
///     @Model
///     class Application extends MaterialApplication {
///         final ModelTest modelTest = new ModelTest();
///     }
///
///     main() async {
///         registerMdl();
///
///         final MaterialApplication application = await componentFactory().
///         rootContext(Application).run(enableVisualDebugging: true);
///
///         application.run();
///     }
///     
class MaterialModel extends MdlComponent implements RefreshableComponent {
    final Logger _logger = new Logger('mdldirective.MaterialModel');

    //static const _MaterialModelConstant _constant = const _MaterialModelConstant();
    static const _MaterialModelCssClasses _cssClasses = const _MaterialModelCssClasses();

    final SimpleValueStore _store;
    final ModelObserverFactory _observerFactory;

    MaterialModel.fromElement(final dom.HtmlElement element,final ioc.Container iocContainer)
        : _store = iocContainer.resolve(service.SimpleValueStore).as<SimpleValueStore>(),
            _observerFactory = ModelObserverFactory(), super(element,iocContainer) {
    }

    @override
    void attached() {
        _init();
    }

    @override
    /// Called in [_MaterialDialogComponent] if parent changes ([MaterialDialog] sets itself as parent!!!)
    void refresh() {
        _logger.fine("MaterialModel - refresh");

        // Remove previously registered Streams!
        downgrade();

        // Re-Init
        _setupObserver();
     
        // Added as init may throw an exception in _setupObserver
        element.classes.add(_cssClasses.IS_UPGRADED);
    }

    //- private -----------------------------------------------------------------------------------

    void _init() {
        _logger.fine("MaterialModel - init");

        /// Recommended - add SELECTOR as class
        element.classes.add(_MaterialModelConstant.WIDGET_SELECTOR);

        _setupObserver();

        element.classes.add(_cssClasses.IS_UPGRADED);
    }

    /// Scope-Context is always the next (up the tree) ScopeAware parent
    void _setupObserver() {
        final ModelObserver observer = _observerFactory.createFor(element);
        eventStreams.addAll( observer.observe( _store ,_fieldname));
    }

    String get _fieldname => element.attributes[_MaterialModelConstant.WIDGET_SELECTOR].trim();
}

/// registration-Helper
void registerMaterialModel() {
    final MdlConfig config = new MdlConfig<MaterialModel>(
        _MaterialModelConstant.WIDGET_SELECTOR,
            (final dom.HtmlElement element,final ioc.Container iocContainer)
                => new MaterialModel.fromElement(element,iocContainer)
    );
    
    // If you want <mdl-model></mdl-model> set selectorType to SelectorType.TAG.
    // If you want <div mdl-model></div> set selectorType to SelectorType.ATTRIBUTE.
    // By default it's used as a class name. (<div class="mdl-model"></div>)
    config.selectorType = SelectorType.ATTRIBUTE;

    componentHandler().register(config);
}

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _MaterialModelCssClasses {

    final String IS_UPGRADED = 'is-upgraded';

    const _MaterialModelCssClasses(); }

/// Store constants in one place so they can be updated easily.
class _MaterialModelConstant {

    static const String WIDGET_SELECTOR = "mdl-model";

    const _MaterialModelConstant();
}
