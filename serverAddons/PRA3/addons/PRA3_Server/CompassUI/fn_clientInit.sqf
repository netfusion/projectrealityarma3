#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: NetFusion

    Description:
    Client Init of Compass UI

    Parameter(s):
    None

    Returns:
    None
*/
GVAR(lineMarkers) = call CFUNC(createNamespace);

GVAR(lineMarkerControlPool) = [];
GVAR(iconMarkerControlPool) = [];

GVAR(lineAlphaCache) = [];
for "_i" from 0 to 108 do {GVAR(lineAlphaCache) pushBack 1};
GVAR(bearingAlphaCache) = [];
for "_i" from 0 to 36 do {GVAR(bearingAlphaCache) pushBack 1};

DFUNC(getAlphaFromX) = {
    (3 - (abs (_this - 92.5) / 30)) max 0
};

([UIVAR(Compass)] call BIS_fnc_rscLayer) cutRsc [UIVAR(Compass), "PLAIN"];

addMissionEventHandler ["MapSingleClick", {
    params ["_units", "_position", "_alt", "_shift"];

    if (!_shift) exitWith {};

    ["MOVE", [0.9, 0.66, 0.01, 1], _position] call FUNC(addCompassLineMarker);
}];

["missionStarted", {
    // The draw3D event triggers on each frame if the client window has focus.
    addMissionEventHandler ["Draw3D", {
        PERFORMANCECOUNTER_START(CompassUI)

        disableSerialization;

        private _dialog = uiNamespace getVariable UIVAR(Compass);

        private _viewDirectionVector = getCameraViewDirection PRA3_Player;
        private _viewDirection = ((_viewDirectionVector select 0) atan2 (_viewDirectionVector select 1) + 360) % 360;

        private _currentPosition = getPosVisual PRA3_Player;

        // Move all controls to view direction
        private _control = _dialog displayCtrl 7100;
        _control ctrlSetPosition [PX(_viewDirection * -0.5), PY(1)];
        _control ctrlCommit 0;

        // Alpha
        private _lineAngleOffset = 2.5 - (_viewDirection % 5);
        private _lineIndexVisibilityOffset = floor (_viewDirection / 5);
        for "_i" from 0 to 37 do {
            private _idc = _i + _lineIndexVisibilityOffset;
            private _control = _dialog displayCtrl (7101 + _idc);
            private _newAlpha = (_i * 5 + _lineAngleOffset) call FUNC(getAlphaFromX);
            private _oldAlpha = GVAR(lineAlphaCache) select _idc;

            if (_newAlpha != _oldAlpha) then {
                GVAR(lineAlphaCache) set [_idc, _newAlpha];
                _control ctrlSetTextColor [1, 1, 1, _newAlpha];
                _control ctrlCommit 0;
            };
        };

        private _bearingOffset = 2.5 - (_viewDirection % 15);
        for "_i" from 0 to 13 do {
            private _idc = _i + floor (_viewDirection / 15);
            private _control = _dialog displayCtrl (7301 + _idc);
            private _newAlpha = (_i * 15 + _bearingOffset) call FUNC(getAlphaFromX);
            private _oldAlpha = GVAR(bearingAlphaCache) select _idc;

            if (_newAlpha != _oldAlpha) then {
                GVAR(bearingAlphaCache) set [_idc, _newAlpha];
                _control ctrlSetTextColor [1, 1, 1, _newAlpha];
                _control ctrlCommit 0;
            };
        };

        // Line marker
        private _nextLineMarkerControl = 0;
        private _overlapCacheLineIndices = [];

        {
            private _lineMarker = GVAR(lineMarkers) getVariable _x;
            if (!(isNil "_lineMarker")) then {
                private _markerPosition = _lineMarker select 1;
                private _relativeVectorToMarker = _markerPosition vectorDiff _currentPosition;
                private _angleToMarker = ((_relativeVectorToMarker select 0) atan2 (_relativeVectorToMarker select 1) + 360) % 360;

                private _control = GVAR(lineMarkerControlPool) select _nextLineMarkerControl;
                if (isNil "_control") then {
                    _control = _dialog ctrlCreate ["RscPicture", 7401 + _nextLineMarkerControl, _dialog displayCtrl 7100];
                    _control ctrlSetText "#(argb,8,8,3)color(1,1,1,1)";
                    GVAR(lineMarkerControlPool) set [_nextLineMarkerControl, _control];
                } else {
                    _control ctrlShow true;
                };

                private _lineIndex = floor (_angleToMarker / 5) + 18;
                if (_viewDirection >= 270 && _lineIndex < 36) then {
                    _lineIndex = _lineIndex + 72;
                };
                if (_viewDirection <= 90 && _lineIndex > 72) then {
                    _lineIndex = _lineIndex - 72;
                };

                private _offset = (_angleToMarker % 5) - 2.5;
                _control setVariable [QGVAR(color), _lineMarker select 0];
                _control setVariable [QGVAR(offset), _offset];
                _control setVariable [QGVAR(lineIndex), _lineIndex];

                // Shift
                private _otherMarkerControl = _overlapCacheLineIndices param [_lineIndex, nil];
                if (!(isNil "_otherMarkerControl")) then {
                    // Compare
                    private _otherOffset = _otherMarkerControl getVariable QGVAR(offset);
                    if (abs _otherOffset < abs _offset) then {
                        // Swap
                        _offset = _otherOffset;
                        private _tmp = _otherMarkerControl;
                        _otherMarkerControl = _control;
                        _control = _tmp;
                    };

                    // Direction
                    private _shiftDirection = _offset / abs _offset; // 1 or -1

                    // Shift
                    private _shiftedLineIndex = _lineIndex;
                    waitUntil {
                        _shiftedLineIndex = _shiftedLineIndex + _shiftDirection;
                        _otherMarkerControl setVariable [QGVAR(lineIndex), _shiftedLineIndex];

                        _otherMarkerControl = _overlapCacheLineIndices param [_shiftedLineIndex, nil];
                        _overlapCacheLineIndices set [_shiftedLineIndex, _otherMarkerControl];
                        isNil "_otherMarkerControl"
                    };
                } else {
                    _overlapCacheLineIndices set [_lineIndex, _control];
                };

                _nextLineMarkerControl = _nextLineMarkerControl + 1;
            };
            nil
        } count ([GVAR(lineMarkers), QGVAR(lineMarkerIDs), []] call CFUNC(getVariableLoc));

        if (_nextLineMarkerControl < count GVAR(lineMarkerControlPool)) then {
            for "_i" from _nextLineMarkerControl to (count GVAR(lineMarkerControlPool) - 1) do {
                private _control = GVAR(lineMarkerControlPool) select _i;
                _control ctrlShow false; //@todo use ctrlDelete when its fixed by BI
            };
        };

        {
            if (ctrlShown _x) then {
                private _lineIndex = _x getVariable QGVAR(lineIndex);
                _x ctrlSetPosition [PX(_lineIndex * 2.5 + 0.15), PY(0.6), PX(2.2), PY(0.3)];

                private _color = _x getVariable QGVAR(color);
                _color set [3, (2.5 + ((_lineIndex - floor (_viewDirection / 5)) * 5) - (_viewDirection % 5)) call FUNC(getAlphaFromX)];
                _x ctrlSetTextColor _color;
                _x ctrlCommit 0;
            };
            nil
        } count GVAR(lineMarkerControlPool);

        // Icon marker
        private _nextIconMarkerControl = 0;
        private _nearUnits = [QEGVAR(Nametags,nearUnits), {_this nearObjects ["CAManBase", 31]}, positionCameraToWorld [0, 0, 0], 1, QEGVAR(Nametags,clearNearUnits)] call CFUNC(cachedCall);
        private _sideColor = missionNamespace getVariable format [QEGVAR(Mission,SideColor_%1), playerSide];
        private _groupColor = [0, 0.87, 0, 1];

        {
            private _targetSide = side (group _x);

            // Check if the unit is not the player himself, alive and a friend of player.
            if (_x != PRA3_Player && alive _x && playerSide getFriend _targetSide >= 0.6) then {
                private _unitPosition = getPosVisual _x;
                private _relativeVectorToUnit = _unitPosition vectorDiff _currentPosition;
                private _angleToUnit = ((_relativeVectorToUnit select 0) atan2 (_relativeVectorToUnit select 1) + 360) % 360;

                private _control = GVAR(iconMarkerControlPool) select _nextIconMarkerControl;
                if (isNil "_control") then {
                    _control = _dialog ctrlCreate ["RscPicture", 7501 + _nextIconMarkerControl, _dialog displayCtrl 7100];
                    GVAR(iconMarkerControlPool) set [_nextIconMarkerControl, _control];
                } else {
                    _control ctrlShow true;
                };

                private _compassAngle = _angleToUnit + 90;
                if (_viewDirection >= 270 && _compassAngle < 180) then {
                    _compassAngle = _compassAngle + 360;
                };
                if (_viewDirection <= 90 && _compassAngle > 360) then {
                    _compassAngle = _compassAngle - 360;
                };

                private _icon = "a3\ui_f\data\map\Markers\Military\dot_ca.paa";
                private _size = [PX(3.6), PY(3.6)];
                if (_x getVariable [QEGVAR(Kit,isMedic), false]) then {
                    _icon = "a3\ui_f\data\Revive\medikit_ca.paa";
                    _size = [PX(2), PY(2)];
                };
                if (_x == leader _x) then {
                    _icon = "a3\ui_f\data\gui\cfg\ranks\corporal_gs.paa";
                    _size = [PX(1.3), PY(1.3)];
                };

                _control ctrlSetText _icon;

                private _color = [_sideColor, _groupColor] select (group PRA3_Player == group _x);
                _color set [3, ((1 - 0.2 * ((PRA3_Player distance _x) - 25)) min 1) * ((_compassAngle - _viewDirection) call FUNC(getAlphaFromX))];
                _control ctrlSetTextColor _color;

                private _positionCenter = [PX(_compassAngle * 0.5) - ((_size select 0) / 2), PY(0.75) - ((_size select 1) / 2)];
                _positionCenter append _size;
                _control ctrlSetPosition _positionCenter;

                _control ctrlCommit 0;

                _nextIconMarkerControl = _nextIconMarkerControl + 1;
            };
            nil
        } count _nearUnits;

        if (_nextIconMarkerControl < count GVAR(iconMarkerControlPool)) then {
            for "_i" from _nextIconMarkerControl to (count GVAR(iconMarkerControlPool) - 1) do {
                private _control = GVAR(iconMarkerControlPool) select _i;
                _control ctrlShow false; //@todo use ctrlDelete when its fixed by BI
            };
        };

        PERFORMANCECOUNTER_END(CompassUI)
    }];
}] call CFUNC(addEventHandler);

["addCompassLineMarker", {
    (_this select 0) call FUNC(addCompassLineMarker);
}] call CFUNC(addEventHandler);
["removeCompassLineMarker", {
    (_this select 0) call FUNC(removeCompassLineMarker)
}] call CFUNC(addEventHandler);