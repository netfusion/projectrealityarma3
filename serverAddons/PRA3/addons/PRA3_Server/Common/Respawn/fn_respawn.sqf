#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: NetFusion

    Description:
    Simulate a "normal" respawn

    Parameter(s):
    0: Spawn position <Position3D>

    Returns:
    None
*/
params ["_targetPosition", ["_tempUnit", false]];

// Remove tempUnit status
if (CLib_Player getVariable [QGVAR(tempUnit), false]) then {
    CLib_Player setVariable [QGVAR(tempUnit), false];
    ["enableSimulation", [CLib_Player, true]] call CFUNC(serverEvent);
    ["hideObject", [CLib_Player, false]] call CFUNC(serverEvent);
};

if (!alive CLib_Player) then {
    // This will cause one frame delay until new unit is available
    setPlayerRespawnTime 0;

    [{
        params ["_targetPosition", "_tempUnit", "_oldPlayer"];

        setPlayerRespawnTime 10e10;

        if (_tempUnit) then {
            CLib_Player setVariable [QGVAR(tempUnit), true];
            // Wait one frame to let the damage of this frame handled
            [{
                ["enableSimulation", [CLib_Player, false]] call CFUNC(serverEvent);
                ["hideObject", [CLib_Player, true]] call CFUNC(serverEvent);
            }] call CFUNC(execNextFrame);
        };

        CLib_Player setDir (random 360);
        CLib_Player setPosASL _targetPosition;

        // Respawn event is triggered by engine
        ["MPRespawn", [CLib_Player, _oldPlayer]] call CFUNC(globalEvent);
    }, [_targetPosition, _tempUnit, CLib_Player]] call CFUNC(execNextFrame);
} else {
    CLib_Player setDir (random 360);
    CLib_Player setPosASL _targetPosition;

    // This is instant cause we reuse the old unit
    ["Respawn", [CLib_Player, CLib_Player]] call CFUNC(localEvent);
    ["MPRespawn", [CLib_Player, CLib_Player]] call CFUNC(globalEvent);
};
