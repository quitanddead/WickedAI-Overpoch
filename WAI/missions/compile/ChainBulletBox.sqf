//Chain Bullet Box

_box = _this select 0;
_box setVariable ["ObjectID","1",true];
_box setVariable ["permaLoot",true];
PVDZE_serverObjectMonitor set [count PVDZE_serverObjectMonitor,_box];

clearWeaponCargoGlobal _box;
clearMagazineCargoGlobal _box;

// AMMUNITION
_box addMagazineCargoGlobal ["2000Rnd_762x51_M134", 3];
_box addMagazineCargoGlobal ["200Rnd_762x51_M240", 4];
_box addMagazineCargoGlobal ["100Rnd_127x99_M2", 3];
_box addMagazineCargoGlobal ["150Rnd_127x107_DSHKM", 4];

// BACKPACKS
_box addBackpackCargoGlobal ["DZ_LargeGunBag_EP1", 1];