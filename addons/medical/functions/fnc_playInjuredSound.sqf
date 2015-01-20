/**
 * fn_playInjuredSound.sqf
 * @Descr: Play the injured sound for a unit if the unit is damaged. The sound broadcasted across MP. 
 * Will not play if the unit has already played a sound within to close a time frame.
 * Delay: With minimal damage (below 1), the delay is (10 + random(50)) seconds. Otherwise it is 60 seconds / damage. 
 * 
 * @Author: Glowbal
 *
 * @Arguments: [unit OBJECT]
 * @Return: nil
 * @PublicAPI: false
 */

#include "script_component.hpp"

private ["_unit","_amountOfDamage","_bodyPartStatus","_availableSounds_A","_availableSounds_B","_availableSounds_C","_sound"];
_unit = _this select 0;
if (!local _unit) exitwith{};

// Lock if the unit is already playing a sound.
if ((_unit getvariable [QGVAR(playingInjuredSound),false])) exitwith {};
_unit setvariable [QGVAR(playingInjuredSound),true];

// Classnames of the available sounds.
_availableSounds_A = [
    "WoundedGuyA_01",
    "WoundedGuyA_02",
    "WoundedGuyA_03",
    "WoundedGuyA_04",
    "WoundedGuyA_05",
    "WoundedGuyA_06",
    "WoundedGuyA_07",
    "WoundedGuyA_08"
];
_availableSounds_B = [
    "WoundedGuyB_01",
    "WoundedGuyB_02",
    "WoundedGuyB_03",
    "WoundedGuyB_04",
    "WoundedGuyB_05",
    "WoundedGuyB_06",
    "WoundedGuyB_07",
    "WoundedGuyB_08"
];
_availableSounds_C = [
    "WoundedGuyC_01",
    "WoundedGuyC_02",
    "WoundedGuyC_03",
    "WoundedGuyC_04",
    "WoundedGuyC_05"
];

// TODO Maybe base this off hitpoint damage
// Find the amount of damage for this unit, based upon body part status.
_bodyPartStatus = [_unit,QGVAR(bodyPartStatus)] call EFUNC(common,getDefinedVariable);
_amountOfDamage = 0;
{
    _amountOfDamage = _amountOfDamage + _x;
}foreach _bodyPartStatus;

// Play the sound if there is any damage present.
if (_amountOfDamage > 0) exitwith {
    _sound = "";
    
    // Select the to be played sound based upon damage amount.
    if (_amountOfDamage > 1) then {
        if (random(1) > 0.5) then {
            _sound = _availableSounds_A select (round(random((count _availableSounds_A) - 1)));
        } else {
            _sound = _availableSounds_B select (round(random((count _availableSounds_B) - 1)));
        };
    } else {
        _sound = _availableSounds_B select (round(random((count _availableSounds_B) - 1)));
    };
    
    // Play the sound
    playSound3D [((getArray(configFile >> "CfgSounds" >> _sound >> "sound") select 0)), _unit, false, getPos _unit, 2, 1, 15]; // +2db, 15 meters.
    
    // Figure out what the delay will be before it is possible to play a sound again.
    private "_delay";
    _delay = 1;
    if (_amountOfDamage < 1) then {
        _delay = 10 + random(50);
    } else {
        _delay = (60 / _amountOfDamage);
    };
    
    // Clean up the lock
    [{
        (_this select 0) setvariable [QGVAR(playingInjuredSound),nil];
    }, [_unit], _delay, _delay] call EFUNC(common,waitAndExecute);
};

// Clean up in case there has not been played any sounds.
_unit setvariable [QGVAR(playingInjuredSound),nil];
