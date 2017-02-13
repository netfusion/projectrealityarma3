#include "macros.hpp"
/*
    Arma At War

    Author: BadGuy

    Description:
    Updates all sectors dependencies

    Parameter(s):
    None

    Returns:
    None
*/

if (isNil QGVAR(allSectorsArray)) exitWith {};

{
    private _isActive = _x getVariable ["isActive", false];
    // if sector is captureable
    if ([_x] call FUNC(isCaptureable)) then {
        // and was not active
        if (!_isActive) then {
            // set as active sector and update start per frame handler
            _x setVariable ["isActive", true];
            [{
                params ["_params", "_pfhId"];
                if !(_params call FUNC(sectorUpdatePFH)) then {
                    _pfhId call CFUNC(removePerFrameHandler);
                };
            }, 0, [_x]] call CFUNC(addPerFrameHandler);
        };
    } else { // is not captureable
        // and was active
        if (_isActive) then {
            _x setVariable ["isActive", false];
        };
    };
    nil;
} count GVAR(allSectorsArray);
