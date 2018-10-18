// --
// Modified version of the work: Copyright (C) 2006-2018 c.a.p.e. IT GmbH, https://www.cape-it.de
// based on the original work of:
// Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file LICENSE for license information (AGPL). If you
// did not receive this file, see https://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Debug = Core.Debug || {};

Core.Debug = (function (Namespace) {
    Namespace.RunUnitTests = function(){
        module('Core.Debug');
        test('Core.Debug.CheckDependency()', function(){

            Core.Debug.DummyFunction = function(){};

            expect(4);

            equal(
                Core.Debug.CheckDependency('Core.Debug.RunUnitTests', 'Core.Debug.DummyFunction', 'existing_function', true),
                true
            );

            equal(
                Core.Debug.CheckDependency('Core.Debug.RunUnitTests', 'Core.Debug.DummyFunction2', 'existing_function', true),
                false
            );

            equal(
                Core.Debug.CheckDependency('Core.Debug.RunUnitTests', 'Core.Debug2.DummyFunction2', 'existing_function', true),
                false
                );

            equal(
                Core.Debug.CheckDependency('Core.Debug.RunUnitTests', 'nonexisting_function', 'nonexisting_function', true),
                false
            );

            delete Core.Debug.DummyFunction;
        });
    };

    return Namespace;
}(Core.Debug || {}));
