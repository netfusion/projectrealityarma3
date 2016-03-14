#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas

    Description:
    Load Kits from mission Config

    Parameter(s):
    0: Config Path <Config>

    Returns:
    None
*/
private [
    "_scope", "_cfg", "_name", "_displayName", "_isMedic", "_isEngineer",
    "_isPilot", "_isVehicleCrew", "_isLeader", "_primaryWeapon", "_primaryAttachments",
    "_primaryMagazine", "_primaryMagazineTracer", "_primaryMagazineCount", "_primaryMagazineTracerCount",
    "_secondaryWeapon", "_secondaryMagazine", "_secondaryMagazineCount", "_handgunWeapon", "_handgunMagazine",
    "_handgunMagazineCount", "_uniform", "_vest", "_backpack", "_headGear", "_assignedItems",
    "_attributes", "_realKit", "_KitVar", "_Kit", "_condition", "_maxCount", "_uiIcon"
];
params ["_cfg", "_sideName"];

_scope = getNumber(_cfg >> "scope");

if (_scope == 0) exitWith {};

_name = configName _cfg;
_displayName = getText (_cfg >> "displayName");
if (_displayName == "") then {
    _displayName = _name;
};
_name = format ["%1_%2", _sideName, _name];
_icon = getText (_cfg >> "icon");
if (_icon isEqualTo "") then {
    _icon = "\a3\ui_f\data\IGUI\Cfg\Actions\clear_empty_ca.paa";
};

_uiIcon = getText (_cfg >> "UIicon");
if (_uiIcon isEqualTo "") then {
    _uiIcon = "\a3\ui_f\data\IGUI\Cfg\Actions\clear_empty_ca.paa";
};
_isMedic = (getNumber (_cfg >> "isMedic")) isEqualTo 1;
_isEngineer = (getNumber (_cfg >> "isEngineer")) isEqualTo 1;
_isPilot = (getNumber (_cfg >> "isPilot")) isEqualTo 1;
_isVehicleCrew = (getNumber (_cfg >> "isVehicleCrew")) isEqualTo 1;
_isLeader = (getNumber (_cfg >> "isLeader")) isEqualTo 1;


_primaryWeapon = getText (_cfg >> "primaryWeapon");
_primaryAttachments = getArray (_cfg >> "primaryAttachments");
_primaryMagazine = getText (_cfg >> "primaryMagazine");
_primaryMagazineTracer = getText (_cfg >> "primaryMagazineTracer");
_primaryMagazineCount = getNumber (_cfg >> "primaryMagazineCount");
_primaryMagazineTracerCount = getNumber (_cfg >> "primaryMagazineTracerCount");
_primarySecondMagazine = getText (_cfg >> "primarySecondMagazine");
_primarySecondMagazineCount = getNumber (_cfg >> "primarySecondMagazineCount");

_secondaryWeapon = getText (_cfg >> "secondaryWeapon");
_secondaryMagazine = getText (_cfg >> "secondaryMagazine");
_secondaryMagazineCount = getNumber (_cfg >> "secondaryMagazineCount");


_handgunWeapon = getText (_cfg >> "handgunWeapon");
_handgunMagazine = getText (_cfg >> "handgunMagazine");
_handgunMagazineCount = getNumber (_cfg >> "handgunMagazineCount");


_uniform = getText (_cfg >> "uniform");
_vest = getText (_cfg >> "vest");
_backpack = getText (_cfg >> "backpack");
_headGear = getText (_cfg >> "headGear");


_assignedItems = getArray (_cfg >> "assignedItems");
_items = getArray (_cfg >> "items");
_maxCountGroup = getNumber (_cfg >> "groupMaxCount");
_maxCountGlobal = getNumber (_cfg >> "globalMaxCount");
_condition = compile getText (_cfg >> "condition");

_attributes = [_isMedic, _isEngineer, _isPilot, _isVehicleCrew, _isLeader];
_realKit = [_primaryWeapon,_primaryAttachments,_primaryMagazine,_primaryMagazineTracer,_primaryMagazineCount,_primaryMagazineTracerCount,_secondaryWeapon,_secondaryMagazine,_secondaryMagazineCount,_handgunWeapon,_handgunMagazine,_handgunMagazineCount,_uniform,_vest,_backpack,_headGear,_assignedItems,_items];
_KitVar = [_name, [[_displayName, _icon, _uiIcon], _realKit, _attributes, [_maxCountGroup, _maxCountGlobal, _condition]]];
["saveKit", _KitVar, true] call CFUNC(localEvent);