@TestOn("browser")
library test.unit.utils;

import 'package:test/test.dart';
import 'package:m4d_directive/m4d_directive.dart';

// import 'package:logging/logging.dart';

main() async {
    // final Logger _logger = new Logger("test.unit.utils");
    // configLogging();

    group('utils', () {
        setUp(() {});

        test('> split condition', () {
            expect(splitConditions("checkBorder : 'withborder'").length, 1);
            expect(splitConditions("checkBorder : 'border: 1px solid black'").length, 1);

            expect(
                splitConditions("checkBorder : 'withborder', checkname : mike").length, 2);
            
            expect(
                splitConditions("checkBorder : 'withborder', checkname : mike")["checkname"],
                "mike");

            expect(splitConditions("disabled : disabled, checkBorder : 'border: 1px solid black'")["disabled"],
                "disabled");


        }); // end of 'split condition' test

    });
    // End of 'utils' group
}

