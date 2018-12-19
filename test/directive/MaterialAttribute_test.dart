@TestOn("browser")
library test.unit.materialclass;

import 'dart:html' as dom;
import 'package:test/test.dart';

import 'package:m4d_core/m4d_core.dart';
import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/m4d_utils.dart';

import 'package:m4d_directive/m4d_directive.dart';
import "package:m4d_directive/services.dart" as service;
import "package:m4d_directive/directive/components/interfaces/stores.dart";

// import 'package:console_log_handler/console_log_handler.dart';

main() async {
    // final Logger _logger = new Logger("test.unit.materialclass");
    // configLogging();

    final String html = '''
    <div class="testtext" mdl-attribute="hasBorder : style='border: 5px solid yellow'">
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et
        dolore magna aliquyam erat, sed diam voluptua.
    </div>
    '''.trim().replaceAll(new RegExp(r"\s+")," ");

    final DomRenderer renderer = new DomRenderer();
    final dom.DivElement parent = new dom.DivElement();

    ioc.Container.bindModules([ DirectivesModule() ]);
    ioc.Container().bind(service.SimpleDataStore).to(_TestStore());

    group('MaterialAttribute', () {
        setUp(() {
        });

        test('> Upgrade', () async {
            final dom.DivElement div = await renderer.render(parent,html) as dom.DivElement;
            await componentHandler().upgradeElement(div);

            expect(div, isNotNull);

            final mc = MaterialAttribute.widget(div);
            expect(mc, isNotNull);
        }); // end of 'Upgrade' test

        test('> Change attribute via model', () async {
            final dom.DivElement div = await renderer.render(parent,html) as dom.DivElement;
            await componentHandler().upgradeElement(div);

            expect(div, isNotNull);

            final ma = MaterialAttribute.widget(div);
            expect(ma, isNotNull);

            // testtext mdl-upgraded mdl-class is-upgraded
            expect(div.attributes.containsKey("border"),isFalse);

            final testStore = ioc.Container().resolve(service.SimpleDataStore).as<_TestStore>();
            testStore.withBorder = true;

            await waitUntil(() => div.attributes.containsKey("style"));

            expect(div.attributes["style"],"border: 5px solid yellow");
        }); // end of 'Change class via model' test

    });
    // End of 'MaterialClass' group
}

typedef bool _StoreCallback();
class _TestStore extends Emitter implements SimpleDataStore {
    bool _withBorder = false;
    final _bindings = Map<String,_StoreCallback>();

    _TestStore() {
        _bindings["hasBorder"] = () => withBorder;
    }

    bool get withBorder => _withBorder;
    void set withBorder(final bool value) {
        _withBorder = value;
        emitChange();
    }

    @override
    bool asBool(final String varname) {
        if(contains(varname)) {
            return _bindings[varname]();
        }
        return false;
    }

    @override
    bool contains(final String varname) => _bindings.containsKey(varname);

}

