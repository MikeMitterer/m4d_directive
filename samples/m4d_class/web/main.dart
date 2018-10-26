import 'dart:html' as dom;

import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/services.dart' as coreService;
import "package:m4d_components/m4d_components.dart";

import "package:m4d_directive/directive/components/interfaces/stores.dart";
import "package:m4d_directive/m4d_directive.dart";
import "package:m4d_directive/services.dart" as service;

class Application extends MaterialApplication {
    final Logger _logger = new Logger('m4d_directive.m4d_class.example.main');

    @override
    void run() {
        new Future(() {
            final widget = MaterialSwitch.widget(dom.querySelector("#switch-border"));
            widget.onClick.listen((_) {
                _logger.info("Clicked!");
                _store.withBorder = widget.checked;
            });
        });
    }

    AppStore get _store => ioc.IOCContainer().resolve(service.SimpleDataStore).as<AppStore>();
}

main() async {
    configLogging(show: Level.INFO);

    ioc.IOCContainer.bindModules([
        CoreComponentsModule(), DirectivesModule()
    ]).bind(coreService.Application).to(Application());
    
    ioc.IOCContainer().bind(service.SimpleDataStore).to(AppStore());

    final Application app = await componentHandler().run();

    app.run();
}

typedef bool _StoreCallback();

class AppStore extends Emitter implements SimpleDataStore {
    bool _withBorder = false;
    final _bindings = Map<String,_StoreCallback>();

    AppStore() {
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

