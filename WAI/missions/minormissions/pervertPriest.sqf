private ["_playerPresent","_cleanmission","_currenttime","_starttime","_missiontimeout","_position","_hint","_missionName","_difficulty"];

_missionName = "Pervert Priest";
_difficulty = "normal";

_position = [getMarkerPos "center",0,5500,10,0,2000,0] call BIS_fnc_findSafePos;
diag_log format["WAI: Mission pervertPriest Started At %1",_position];


// CHURCH
_base = createVehicle ["Land_Church_03",_position, [], 0, "CAN_COLLIDE"];
_box = createVehicle ["RUOrdnanceBox",[(_position select 0) + 6.0991, (_position select 1) + 4.1523, 0.55672312], [], 0, "CAN_COLLIDE"];
[_box] call priest_gold_box;

//Troops
//priest
_rndnum = round (random 3) + 4;
[[(_position select 0) + 3.8232, (_position select 1) + 0.0303, 0],                  //position
1,						  //Number Of units
"hard",			    	  //Skill level
"Random",			      //Primary gun set number. "Random" for random weapon set.
2,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"Priest_DZ",			  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
"minor"
] call spawn_group;

//parishioners
[[(_position select 0) - 27.6187, (_position select 1) - 0.0669, 0],                  //position
_rndnum,				  //Number Of units
"normal",			      //Skill level
"Random",			      //Primary gun set number. "Random" for random weapon set.
4,						  //Number of magazines
"",						  //Backpack "" for random or classname here.
"Functionary1_EP1_DZ",	  //Skin "" for random or classname here.
"Random",				  //Gearset number. "Random" for random gear set.
"minor"
] call spawn_group;



//CREATE MARKER
[_position,_missionName,_difficulty] execVM wai_minor_marker;

[nil,nil,rTitleText,"Reverend Cross has been accused of diddling little boys and stealing from the collection plate!\nSend this filth to hell and keep the gold for yourself!", "PLAIN",10] call RE;

_hint = parseText format ["
	<t align='center' color='#1E90FF' shadow='2' size='1.75'>Priority Transmission</t><br/>
	<t align='center' color='#FFFFFF'>------------------------------</t><br/>
	<t align='center' color='#1E90FF' size='1.25'>Side Mission</t><br/>
	<t align='center' color='#FFFFFF' size='1.15'>Difficulty: <t color='#1E90FF'> NORMAL</t><br/>
	<br/>
	<br/>
	<t align='center' color='#FFFFFF'>Reverend Cross has been accused of diddling little boys and stealing from the collection plate, An allegation which he denies. He has hired some of his parishioners as bodyguards to protect himself. Send this filth to hell and take the gold for yourself!</t>", _missionName];
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
	diag_log format["WAI: Mission pervertPriest Ended At %1",_position];
	[nil,nil,rTitleText,"Reverend Cross has been killed, Children of Chernarus Rejoice!", "PLAIN",10] call RE;
} else {
	clean_running_minor_mission = True;
	deleteVehicle _box;
	deleteVehicle _base;
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
	
	diag_log format["WAI: Mission pervertPriest Timed Out At %1",_position];
	[nil,nil,rTitleText,"Time's up! Reverend Cross has gone into hiding", "PLAIN",10] call RE;
};
minor_missionrunning = false;