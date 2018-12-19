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

/**
 * Checks the given condition and adds the given class-name to the components [element].
 * Format: [!]<variable> : '<classname>'
 *
 * If you put a exclamation mark in front of <variable> the returned value will be inverted
 * Variable-Context is "parent". parent is either the next "[ScopeAware]' parent or root-context (MaterialApplication)
 *
 * Sample:
 *
 *    <div class="testtext" mdl-class="checkBorder : 'withborder'">
 *       Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et
 *       dolore magna aliquyam erat, sed diam voluptua.
 *    </div>
 *
 *    <div class="switches">
 *        <label class="mdl-switch mdl-ripple-effect" for="switch-border">
 *            <input type="checkbox" id="switch-border" class="mdl-switch__input" mdl-model="checkBorder"/>
 *            <span class="mdl-switch__label">Switch 'border' on/off</span>
 *        </label>
 *    </div>
 *
 *    @Component
 *    class Application extends MaterialApplication {
 *          ...
 *          final ObservableProperty<bool> checkBorder = new ObservableProperty<bool>(false);
 *    }
 */
@Component
class MaterialClass extends MdlComponent {
    final Logger _logger = new Logger('mdldirective.MaterialClass');

    //static const _MaterialClassConstant _constant = const _MaterialClassConstant();
    static const _MaterialClassCssClasses _cssClasses = const _MaterialClassCssClasses();

    bool _isElementAWidget = null;
    
    final SimpleDataStore _store;
    final _conditions = Set<_ClassCondition>();

    MaterialClass.fromElement(final dom.HtmlElement element,final ioc.Container iocContainer)
        : _store = iocContainer.resolve(service.SimpleDataStore).as<SimpleDataStore>(),
            super(element,iocContainer) {
    }
    
    static MaterialClass widget(final dom.HtmlElement element) => mdlComponent(element,MaterialClass) as MaterialClass;
    
    @override
    void attached() {
        _init();
    }

    // --------------------------------------------------------------------------------------------
    // EventHandler

    void handleButtonClick() {
        _logger.info("Event: handleButtonClick");
    }    
    
    //- private -----------------------------------------------------------------------------------


    void _init() {
        _logger.fine("MaterialClass - init $element");
        
        /// Recommended - add SELECTOR as class
        element.classes.add(_MaterialClassConstant.WIDGET_SELECTOR);

        final Map<String,String> conditions = splitConditions(_attribute);
        conditions.forEach((String varname,final String classname) {
            //_logger.info("Var: $varname -> $classname");

            final bool negateValue = varname.startsWith("!");
            if(negateValue) {
                varname = varname.replaceFirst("!","");
            }

            _conditions.add(_ClassCondition(varname.trim(), negateValue,
                classname.trim()
                    .replaceFirst(RegExp(r"^'"), "")
                    .replaceFirst(RegExp(r"'$"), ""))
            );
        });

        _bindActions();
        _updateClasses();

        element.classes.add(_cssClasses.IS_UPGRADED);
    }

    /// Binds Actions/Events to the stores "DataStoreChangedEvent"
    void _bindActions() {
        // only after creation...
        if(_store == null) { return; }

        eventStreams.add(
            _store.onChange.listen((final DataStoreChangedEvent event) => _updateClasses())
        );
    }

    /// Updates all classes
    void _updateClasses() {
        _conditions.forEach((final _ClassCondition condition) {

            void _updateClass(final String classname, final bool value) {
                if(value) {
                    element.classes.add(classname);
                } else {
                    element.classes.remove(classname);
                }
            }

            if(_store.contains(condition.name)) {
                _updateClass(condition.classToChange,
                    condition.negate
                        ? !_store.asBool(condition.name)
                        : _store.asBool(condition.name)
                );
            } else {
                element.classes.remove(condition.classToChange);
                _logger.warning("Store does not contain '${condition.name}!");
            }

            if(_isWidget) {
                final MdlComponent component = mdlComponent(element,null);
                component.update();
            }

        });
    }

    /// Returns true if current element is a 'MaterialWidget' (MdlConfig.isWidget...)
    bool get _isWidget {
        if(_isElementAWidget == null) {
            _isElementAWidget = isMdlWidget(element);
        }
        return _isElementAWidget;
    }

    /// Returns the components attribute
    String get _attribute => element.attributes[_MaterialClassConstant.WIDGET_SELECTOR];
}

/// registration-Helper
void registerMaterialClass() {
    final MdlConfig config = new MdlConfig<MaterialClass>(
        _MaterialClassConstant.WIDGET_SELECTOR,
            (final dom.HtmlElement element,final ioc.Container iocContainer)
                => new MaterialClass.fromElement(element,iocContainer)
    );
    
    // If you want <mdl-class></mdl-class> set selectorType to SelectorType.TAG.
    // If you want <div mdl-class></div> set selectorType to SelectorType.ATTRIBUTE.
    // By default it's used as a class name. (<div class="mdl-class"></div>)
    config.selectorType = SelectorType.ATTRIBUTE;
    
    componentFactory().register(config);
}

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _MaterialClassCssClasses {

    final String IS_UPGRADED = 'is-upgraded';

    const _MaterialClassCssClasses(); }

/// Store constants in one place so they can be updated easily.
class _MaterialClassConstant {

    static const String WIDGET_SELECTOR = "mdl-class";

    const _MaterialClassConstant();
}

/// Helper-Class for managing Css-Class-Conditions
class _ClassCondition {
    final String name;
    final bool negate;
    final String classToChange;

    _ClassCondition(this.name, this.negate, this.classToChange);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is _ClassCondition &&
                runtimeType == other.runtimeType &&
                name == other.name;

    @override
    int get hashCode => name.hashCode;
}