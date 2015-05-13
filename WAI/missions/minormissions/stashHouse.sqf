private ["_playerPresent","_cleanmission","_currenttime","_starttime","_missiontimeout","_vehname","_veh","_position","_vehclass","_vehdir","_objPosition","_picture","_hint","_missionName","_difficulty"];

_vehclass = civil_vehicles call BIS_fnc_selectRandom;
_vehname	= getText (configFile >> "CfgVehicles" >> _vehclass >> "displayName");

_missionName = "Stash House";
_difficulty = "normal";

_position = [getMarkerPos "center",0,5500,10,0,2000,0] call BIS_fnc_findSafePos;
diag_log format["WAI: Mission stashHouse Started At %1",_position];

_picture = getText (configFile >> "cfgVehicles" >> _vehclass >> "picture");


// STASH HOUSE 
_base = createVehicle ["Land_HouseV_1I4",_position, [], 0, "CAN_COLLIDE"];
_base setDir 152.66766;
_base1 = createVehicle ["Land_kulna",[(_position select 0) + 5.4585, (_position select 1) - 2.885,0],[], 0, "CAN_COLLIDE"];
_base1 setDir -28.282881;

minorBldList = minorBldList + [_base];
minorBldList = minorBldList + [_base1];




// civ car
_veh = createVehicle [_vehclass,[(_position select 0) - 10.6206, (_position select 1) - 0.49,0], [], 0, "CAN_COLLIDE"];
_vehdir = round(random 360);
_veh setDir _vehdir;
clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
_veh setVariable ["ObjectID","1",true];
PVDZE_serverObjectMonitor set [count PVDZE_serverObjectMonitor,_veh];
_veh setVehicleLock "LOCKED";
_veh setVariable ["R3F_LOG_disabled",true,true];
diag_log format["WAI: Mission stashHouse spawned a %1",_vehname];

_objPosition = getPosATL _veh;
//[_veh,[_vehdir,_objPosition],_vehclass,true,"0"] call custom_publish;

//Troops
_rndnum = round (random 3) + 4;
[[_position select 0, _position select 1, 0],                  //position
_rndnum,				  //Number Of units
"normal",					      //Skill level 0-1. Has no effect if using custom skills
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"",						  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
"minor",
"WAIminorArray"
] call spawn_group;

[[_position select 0, _position select 1, 0],                  //position
4,						  //Number Of units
"normal",					      //Skill level 0-1. Has no effect if using custom skills
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"",						  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
"minor",
"WAIminorArray"
] call spawn_group;



//CREATE MARKER
[_position,_missionName,_difficulty] execVM wai_minor_marker;

[nil,nil,rTitleText,"Bandits have set up a Weapon Stash House!\nGo Empty it Out!", "PLAIN",10] call RE;

_hint = parseText format ["
	<t align='center' color='#1E90FF' shadow='2' size='1.75'>Priority Transmission</t><br/>
	<t align='center' color='#FFFFFF'>------------------------------</t><br/>
	<t align='center' color='#1E90FF' size='1.25'>Side Mission</t><br/>
	<t align='center' color='#FFFFFF' size='1.15'>Difficulty: <t color='#1E90FF'> NORMAL</t><br/>
	<t align='center' color='#FFFFFF'>%2 : Bandits have set up a Weapon Stash House! Go Empty it Out!</t>", _picture, _missionName];
[nil,nil,rHINT,_hint] call RE;

_missiontimeout = true;
_cleanmission = false;
_playerPresent = false;
_starttime = floor(time);
while {_missiontimeout} do {
	sleep 5;
	_currenttime = floor(time);
	{if((isPlayer _x) AND (_x distance _position <= 150)) then {_playerPresent = true};}forEach playableUnits;
	if (_currenttime - _starttime >= wai_mission_timeout) then {_cleanmission = true;};
	if ((_playerPresent) OR (_cleanmission)) then {_missiontimeout = false;};
};
if (_playerPresent) then {
	
	[_position,"WAIminorArray"] call missionComplete;
	
	// wait for mission complete then publish vehicle and spawn crates
	_veh setVehicleLock "UNLOCKED";
	_veh setVariable ["R3F_LOG_disabled",false,true];
	[_veh,[_vehdir,_objPosition],_vehclass,true,"0"] call custom_publish;
	

	_box = createVehicle ["USBasicAmmunitionBox",[(_position select 0) + 0.7408, (_position select 1) + 1.565, 0.10033049], [], 0, "CAN_COLLIDE"];
	[_box] call Medical_Supply_Box; // medical supplies
	_box1 = createVehicle ["USBasicAmmunitionBox",[(_position select 0) - 0.2387, (_position select 1) + 1.043, 0.10033049], [], 0, "CAN_COLLIDE"];
	[_box1] call Medium_Gun_Box; // med gun box

	// mark crates with smoke/flares
	[_box] call markCrates;
	[_box1] call markCrates;

	diag_log format["WAI: Mission stashHouse Ended At %1",_position];
	[nil,nil,rTitleText,"The Stash House is under Survivor Control!", "PLAIN",10] call RE;
	uiSleep 300;
	["minorclean"] call WAIcleanup;
} else {
	clean_running_minor_mission = True;
	deleteVehicle _veh;
	["minorclean"] call WAIcleanup;
	
	diag_log format["WAI: Mission stashHouse Timed Out At %1",_position];
	[nil,nil,rTitleText,"Time's up! MISSION FAILED", "PLAIN",10] call RE;
};
minor_missionrunning = false;