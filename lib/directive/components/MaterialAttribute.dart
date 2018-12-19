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
 * Checks the given condition and adds the given attribute to the components [element].
 * Format: [!]<variable> : '<attribute>'
 *
 * If you put a exclamation mark in front of <variable> the returned value will be inverted
 * Variable-Context is "parent". parent is either the next "[ScopeAware]' parent or root-context (MaterialApplication)
 *
 *    <div class="controls">
 *        <div class="mdl-textfield">
 *            <input class="mdl-textfield__input" type="text" id="sample-text-attribute" mdl-attribute="!checkAttribute : 'disabled' "/>
 *            <label class="mdl-textfield__label" for="sample-text-attribute" mdl-class="checkAttribute : 'enabled'">
 *            <span class="enabled">Type something</span>
 *            <span class="disabled">I'm Disabled</span>
 *        </label>
 *        </div>
 *        <button class="mdl-button mdl-js-button mdl-ripple-effect" mdl-attribute="!checkAttribute : 'disabled' ">Submit</button>
 *    </div>
 *
 *    @inject
 *    class Application extends MaterialApplication {
 *          ...
 *          final ObservableProperty<bool> checkBorder = new ObservableProperty<bool>(false);
 *    }
 *
 */
@Component
class MaterialAttribute extends MdlComponent {
    final Logger _logger = new Logger('mdldirective.MaterialAttribute');

    //static const _MaterialAttributeConstant _constant = const _MaterialAttributeConstant();
    static const _MaterialAttributeCssClasses _cssClasses = const _MaterialAttributeCssClasses();

    bool _isElementAWidget = null;

    final SimpleDataStore _store;
    final _conditions = List<_AttributeCondition>();

    MaterialAttribute.fromElement(final dom.HtmlElement element,final ioc.Container iocContainer)
        : _store = iocContainer.resolve(service.SimpleDataStore).as<SimpleDataStore>(),
            super(element,iocContainer) {
    }
    
    static MaterialAttribute widget(final dom.HtmlElement element) => mdlComponent(element,MaterialAttribute) as MaterialAttribute;

    @override
    void attached() {
        _init();
    }

    //- private -----------------------------------------------------------------------------------

    void _init() {
        _logger.fine("MaterialAttribute - init");
        
        /// Recommended - add SELECTOR as class
        element.classes.add(_MaterialAttributeConstant.WIDGET_SELECTOR);

        final Map<String,String> conditions = splitConditions(_attribute);
        conditions.forEach((String varname,final String attribute) {
            //_logger.info("Var: $varname -> $classname");

            final bool negateValue = varname.startsWith("!");
            if(negateValue) {
                varname = varname.replaceFirst("!","");
            }

            _conditions.add(_AttributeCondition(varname.trim(), negateValue, attribute));
        });

        _bindActions();
        _updateAttributes();
        
        element.classes.add(_cssClasses.IS_UPGRADED);
    }

    /// Binds Actions/Events to the stores "DataStoreChangedEvent"
    void _bindActions() {
        // only after creation...
        if(_store == null) { return; }

        eventStreams.add(
            _store.onChange.listen((final DataStoreChangedEvent event) => _updateAttributes())
        );
    }

    /// Updates all Attributes
    void _updateAttributes() {
        _conditions.forEach((final _AttributeCondition condition) {
            // In case of attributeToChange is something like "style='border: 3px solid red'"
            final segments = condition.attributeToChange.split("=");
            final attribute = segments.first.trim();
            final expression = (segments.length > 1 ? segments[1].trim() : "")
                .replaceFirst(RegExp(r"^'"), "").replaceFirst(RegExp(r"'$"), "");

            void _updateAttribute(final String attribute, final String expression, final bool addAddtribute) {
                if(addAddtribute) {
                    element.setAttribute(attribute, expression);
                } else {
                    if(element.attributes.containsKey(attribute)
                        && element.attributes[attribute] == expression) {
                        element.attributes.remove(attribute);
                    }
                }
            }

            if(_store.contains(condition.name)) {
                _updateAttribute(attribute, expression ,
                    condition.negate
                        ? !_store.asBool(condition.name)
                        : _store.asBool(condition.name)
                );

            } else {
                attributes.remove(attribute);
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
    String get _attribute => element.attributes[_MaterialAttributeConstant.WIDGET_SELECTOR];
 
}

/// registration-Helper
void registerMaterialAttribute() {
    final MdlConfig config = new MdlConfig<MaterialAttribute>(
        _MaterialAttributeConstant.WIDGET_SELECTOR,
            (final dom.HtmlElement element,final ioc.Container iocContainer)
                => new MaterialAttribute.fromElement(element,iocContainer)
    );
    
    // If you want <mdl-attribute></mdl-attribute> set selectorType to SelectorType.TAG.
    // If you want <div mdl-attribute></div> set selectorType to SelectorType.ATTRIBUTE.
    // By default it's used as a class name. (<div class="mdl-attribute"></div>)
    config.selectorType = SelectorType.ATTRIBUTE;
    
    componentFactory().register(config);
}

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _MaterialAttributeCssClasses {

    final String IS_UPGRADED = 'is-upgraded';

    const _MaterialAttributeCssClasses(); }

/// Store constants in one place so they can be updated easily.
class _MaterialAttributeConstant {

    static const String WIDGET_SELECTOR = "mdl-attribute";

    const _MaterialAttributeConstant();
}

/// Helper-Class for managing Css-Attribute-Conditions
class _AttributeCondition {
    final String name;
    final bool negate;
    final String attributeToChange;

    _AttributeCondition(this.name, this.negate, this.attributeToChange);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is _ClassCondition &&
                runtimeType == other.runtimeType &&
                name == other.name;

    @override
    int get hashCode => name.hashCode;
}