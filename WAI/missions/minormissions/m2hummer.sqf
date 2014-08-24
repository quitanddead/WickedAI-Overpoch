private ["_playerPresent","_cleanmission","_currenttime","_starttime","_missiontimeout","_vehname","_veh","_position","_vehclass","_vehdir","_objPosition","_picture","_hint","_missionName"];

_vehclass = "HMMWV_M1151_M2_DES_EP1";

_vehname	= getText (configFile >> "CfgVehicles" >> _vehclass >> "displayName");

_missionName = _vehname;

_position = [getMarkerPos "center",0,5500,10,0,2000,0] call BIS_fnc_findSafePos;
diag_log format["WAI: Mission m2hummer Started At %1",_position];

_picture = getText (configFile >> "cfgVehicles" >> _vehclass >> "picture");



//Medical Supply Box
_box = createVehicle ["LocalBasicWeaponsBox",[(_position select 0) - 20,(_position select 1),0], [], 0, "CAN_COLLIDE"];
[_box] call Medical_Supply_Box;

_box1 = createVehicle ["LocalBasicWeaponsBox",[(_position select 0) + 15,(_position select 1),0], [], 0, "CAN_COLLIDE"];
[_box1] call Medium_Gun_Box;

//Medical Tent
_tent = createVehicle ["Land_fort_rampart",[(_position select 0) - 21,(_position select 1),0], [], 0, "CAN_COLLIDE"];
_tent setDir 90;
_tent2 = createVehicle ["Land_fort_rampart",[(_position select 0) + 16,(_position select 1),0], [], 0, "CAN_COLLIDE"];
_tent2 setDir 270;

//Hummer
_veh = createVehicle [_vehclass,_position, [], 0, "CAN_COLLIDE"];
_vehdir = round(random 360);
_veh setDir _vehdir;
clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
_veh setVariable ["ObjectID","1",true];
PVDZE_serverObjectMonitor set [count PVDZE_serverObjectMonitor,_veh];
diag_log format["WAI: Mission m2hummer spawned a %1",_vehname];

_objPosition = getPosATL _veh;
//[_veh,[_vehdir,_objPosition],_vehclass,true,"0"] call custom_publish;

//Troops
_rndnum = round (random 3) + 4;
[[_position select 0, _position select 1, 0],                  //position
_rndnum,				  //Number Of units
1,					      //Skill level 0-1. Has no effect if using custom skills
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"USMC_Soldier_LAT",						  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
true
] call spawn_group;

[[_position select 0, _position select 1, 0],                  //position
4,						  //Number Of units
1,					      //Skill level 0-1. Has no effect if using custom skills
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"USMC_Soldier_SL",						  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
true
] call spawn_group;

[[_position select 0, _position select 1, 0],                  //position
4,						  //Number Of units
1,					      //Skill level 0-1. Has no effect if using custom skills
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"USMC_SoldierM_Marksman",	  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
true					  // mission true
] call spawn_group;


//CREATE MARKER
while {minor_missionrunning} do {
	_Minor1 =	createMarker ["_Minor1", _position];
	_Minor1 setMarkerText "";
	_Minor1 setMarkerColor "ColorRed";
	_Minor1 setMarkerShape "ELLIPSE";
	_Minor1 setMarkerBrush "Solid";
	_Minor1 setMarkerSize [200,200];

	_Minor2 =	createMarker ["_Minor2", _position];
	_Minor2 setMarkerColor "ColorBlack";
	_Minor2 setMarkerType "mil_dot";
	_Minor2 setMarkerText _missionName;
	sleep 30;
	deleteMarker _Minor1;
	deleteMarker _Minor2;
};
if (_Minor1 == "Mission") then {
	deleteMarker _Minor1;
	deleteMarker _Minor2;
};

[nil,nil,rTitleText,"US Forces have been spotted with a GPK M2 Hummer\nKill the soldiers and make the vehicle your own!", "PLAIN",10] call RE;

_hint = parseText format ["<t align='center' color='#FF0000' shadow='2' size='1.75'>Priority Transmission</t><br/><t align='center' color='#FF0000'>------------------------------</t><br/><t align='center' color='#FFFFFF' size='1.25'>Side Mission</t><br/><t align='center'><img size='5' image='%1'/></t><br/><t align='center' color='#FFFFFF'>The US Military have a<t color='#FF0000'> %2</t>Eliminate the soldiers and make it yours!</t>", _picture, _vehname];
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
	[_veh,[_vehdir,_objPosition],_vehclass,true,"0"] call custom_publish;
	waitUntil
	{
		sleep 5;
		_playerPresent = false;
		{if((isPlayer _x) AND (_x distance _position <= 30)) then {_playerPresent = true};}forEach playableUnits;
		(_playerPresent)
	};
	diag_log format["WAI: Mission m2hummer Ended At %1",_position];
	[nil,nil,rTitleText,"US Forces have been wiped out, Good Work!", "PLAIN",10] call RE;
	deleteMarker "_Minor1";
	deleteMarker "_Minor2";
} else {
	clean_running_minor_mission = True;
	deleteVehicle _veh;
	deleteVehicle _box;
	{_cleanunits = _x getVariable "missionclean";
	if (!isNil "_cleanunits") then {
		switch (_cleanunits) do {
			case "ground" :  {ai_ground_units = (ai_ground_units -1);};
			case "air" :     {ai_air_units = (ai_air_units -1);};
			case "vehicle" : {ai_vehicle_units = (ai_vehicle_units -1);};
			case "static" :  {ai_emplacement_units = (ai_emplacement_units -1);};
		};
		deleteVehicle _x;
		sleep 0.05;
	};	
	} forEach allUnits;
	
	diag_log format["WAI: Mission m2hummer Timed Out At %1",_position];
	[nil,nil,rTitleText,"The US Forces have left the Area - Mission Failed", "PLAIN",10] call RE;
	deleteMarker "_Minor1";
	deleteMarker "_Minor2";
};
minor_missionrunning = false;