import 'package:m4d_core/m4d_ioc.dart' as ioc;
import "package:m4d_components/m4d_components.dart";

import "package:m4d_directive/m4d_directive.dart";

main() async {
    ioc.IOCContainer.bindModules([
        CoreComponentsModule(), DirectivesModule()
    ]);

    final app = await componentHandler().run();
    app.run();
}


