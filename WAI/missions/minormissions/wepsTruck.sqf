/*
	File: wepsTruck.sqf
	Author: JakeHekesFists[DMD]
	Description: Minor Mission for WAI
	Based on SM6 for DZMS - Weapon Truck Crash by lazyink (Full credit for code to TheSzerdi & TAW_Tonic) & Vampire

	Damaged Truck, Low Fuel
	Box of Vehicle Parts
	Extra Large Box of Weapons
	3 Small Groups of AI
*/

private ["_playerPresent","_cleanmission","_currenttime","_starttime","_missiontimeout","_vehname","_veh","_position","_vehclass","_picture","_hint","_missionName","_difficulty","_worldName"];

_vehclass = cargo_trucks call BIS_fnc_selectRandom;

_vehname	= getText (configFile >> "CfgVehicles" >> _vehclass >> "displayName");
_worldName = toLower format ["%1", worldName];

_missionName = "Weapons Truck";
_difficulty = "normal";

_position = [getMarkerPos "center",0,5500,10,0,2000,0] call BIS_fnc_findSafePos;
diag_log format["WAI: Mission wepsTruck Started At %1",_position];

_picture = getText (configFile >> "cfgVehicles" >> _vehclass >> "picture");

// CRATES 
_box = createVehicle ["BAF_VehicleBox",[(_position select 0) + 0.7408, (_position select 1) + 4.565, 0.10033049], [], 0, "CAN_COLLIDE"];
[_box] call vehicle_wreck_box;

_box1 = createVehicle ["RULaunchersBox",[(_position select 0) - 0.2387, (_position select 1) + 1.043, 0.10033049], [], 0, "CAN_COLLIDE"];
[_box1] call Extra_Large_Gun_Box;

// crashed truck
_veh = createVehicle [_vehclass,[(_position select 0) - 10.6206, (_position select 1) - 0.49,0], [], 0, "CAN_COLLIDE"];
[_veh,0.75,0.15] call spawnTempVehicle; 
//[_veh,damage,fuel] call spawnTempVehicle;

diag_log format["WAI: Mission wepsTruck spawned a %1",_vehname];


//Troops
_rndnum = round (random 3) + 4;
[[_position select 0, _position select 1, 0],_rndnum,"normal","Random",4,"","","Random","minor","WAIminorArray"] call spawn_group;
[[_position select 0, _position select 1, 0],2,"normal","Random",4,"","","Random","minor","WAIminorArray"] call spawn_group;
[[_position select 0, _position select 1, 0],4,"normal","Random",4,"","","Random","minor","WAIminorArray"] call spawn_group;

//CREATE MARKER
[_position,_missionName,_difficulty] execVM wai_minor_marker;

[nil,nil,rTitleText,"A Weapons Truck has Crashed!\nGo Recover the Supplies!", "PLAIN",10] call RE;

_hint = parseText format ["
	<t align='center' color='#1E90FF' shadow='2' size='1.75'>Priority Transmission</t><br/>
	<t align='center' color='#FFFFFF'>------------------------------</t><br/>
	<t align='center' color='#1E90FF' size='1.25'>Side Mission</t><br/>
	<t align='center' color='#FFFFFF' size='1.15'>Difficulty: <t color='#1E90FF'> NORMAL</t><br/>
	<t align='center'><img size='5' image='%1'/></t><br/>
	<t align='center' color='#FFFFFF'>%2 : A %4 carrying weapons across %3 has crashed. Kill Them and secure the vehicle and weapons for yourself!</t>",
	_picture, 
	_missionName, 
	_worldName,
	_vehname
];
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
	diag_log format["WAI: Mission wepsTruck Ended At %1",_position];
	[nil,nil,rTitleText,"The Crashed Weapons Truck has been Secured", "PLAIN",10] call RE;
} else {
	clean_running_minor_mission = True;
	deleteVehicle _veh;
	deleteVehicle _box;
	deleteVehicle _box1;
	{_cleanunits = _x getVariable "minorclean";
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
	
	diag_log format["WAI: Mission wepsTruck Timed Out At %1",_position];
	[nil,nil,rTitleText,"You Failed to Clear the Mission in Time", "PLAIN",10] call RE;
};

minor_missionrunning = false;