# CS:GO Explosive Bullets

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/AyNLrRxBMaw/0.jpg)](http://www.youtube.com/watch?v=AyNLrRxBMaw)

## Description
This plugin will make your bullets explode on impact

## Requirements
```
Plugin for Counter-Strike: Global Offensive
Requires Sourcemod 1.8+ and Metamod 1.10+
```

## Convar settings
```
sm_eb_enabled - [1/0] - Enables/Disables plugin
sm_eb_warmup - [1/0] - If set to 1, explosive bullets will be enabled for everyone during warmup round otherwise 0 to turn off.
sm_eb_roundend - [1/0] - If set to 1, explosive bullets will be enabled for everyone when round ends and is waiting for the next round restart otherwise 0 to turn off.
```

## Commands
```
sm_eb <client> <1:ON | 0:OFF> - Turns on/off explosive bullets, this will make ALL weapons have explosive bullets regardless if it is disabled in configuration
sm_explosivebullets - Same as sm_eb
sm_ebme - Turns on/off explosive bullets for yourself only
sm_explosivebulletsme - Same as sm_ebme
```

## Installation
```
1. Place explosivebullets.smx to addons/sourcemod/plugins/
2. Place explosivebullets_guns.cfg to addons/sourcemod/configs/
3. Place explosivebullets.cfg to cfg/sourcemod/ and edit your convars to fit your needs
```

## Configuration Setup
* Open addons/sourcemod/configs/explosivebullets_guns.cfg
```
"weapon_ak47"       //Classname of weapon
{
  "Enable"  "1"     //0 to turn off, 1 to turn on
  "Damage"  "10.0   //Damage done to player, does lesser damage the further player is away from impact with respect to the radius
  "Radius"  "100.0" //Radius of damage done
  "Flag"    "b"     //Only players with this flag can have explosive bullets for this weapon, check https://wiki.alliedmods.net/Adding_Admins_(SourceMod)#Levels for more flags
}
```
There are more weapons listed that you can individually modify
