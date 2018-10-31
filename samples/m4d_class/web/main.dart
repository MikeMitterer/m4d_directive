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
            widget.checked = true;
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


class AppStore extends DefaultSimpleDataStore {

    AppStore() {
        value<bool>("hasBorder",true);
    }

    bool get withBorder => contains("hasBorder") ? bindings["hasBorder"].toBool() : false;
    void set withBorder(final bool hasBorder) => value<bool>("hasBorder",hasBorder);

}

