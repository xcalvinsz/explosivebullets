#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "1.0"
#define CS_SLOT_PRIMARY 0
#define CS_SLOT_SECONDARY 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

ConVar cEnabled, cDamage, cRadius;
int gEnabled, gDamage, gRadius;
bool gActivated[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[CS:GO] Explosive Bullets",
	author = PLUGIN_AUTHOR,
	description = "Your bullets will explode on impact.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	CreateConVar("sm_eb_version", "1.0", PLUGIN_VERSION, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	cEnabled = CreateConVar("sm_eb_enabled", "1", "Enables/Disables this plugin.");
	cDamage = CreateConVar("sm_eb_damage", "50", "Damage of the explosive bullet.");
	cRadius = CreateConVar("sm_eb_radius", "100", "Radius that the explosive bullet hurt players.");
	
	RegAdminCmd("sm_eb", Command_Explode, ADMFLAG_GENERIC, "Enables explosive bullets on players.");
	RegAdminCmd("sm_explosivebullets", Command_Explode, ADMFLAG_GENERIC, "Enables explosive bullets on players.");
	
	cEnabled.AddChangeHook(OnConvarChanged);
	cDamage.AddChangeHook(OnConvarChanged);
	cRadius.AddChangeHook(OnConvarChanged);
	
	HookEvent("bullet_impact", Event_BulletImpact);
	
	AutoExecConfig(true, "explosivebullets"); 
}

public void OnConfigsExecuted()
{
	gEnabled = cEnabled.IntValue;
	gDamage = cDamage.IntValue;
	gRadius = cRadius.IntValue;
}

public void OnConvarChanged(Handle convar, char[] oldValue, char[] newValue) 
{
	if (StrEqual(oldValue, newValue, true))
		return;
		
	int iNewValue = StringToInt(newValue);
	
	if(convar == cEnabled)
		gEnabled = iNewValue;
	else if(convar == cDamage)
		gDamage = iNewValue;
	else if(convar == cRadius)
		gRadius = iNewValue;
}

public Action Command_Explode(int client, int args)
{
	if(!gEnabled)
	{
		ReplyToCommand(client, "[SM] This plugin is disabled.");
		return Plugin_Handled;
	}
	
	if(args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_eb <client> <1:ON | 0:OFF>");
		return Plugin_Handled;
	}
	
	char arg1[64], arg2[4];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	bool button = !!StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToCommand(client, "[SM] Can not find client.");
		return Plugin_Handled;
	}
	
	for(int i = 0; i < target_count; i++)
	{
		if(1 <= target_list[i] <= MaxClients && IsClientInGame(target_list[i]))
		{
			gActivated[target_list[i]] = button;
		}
	}
	
	if (tn_is_ml)
		ShowActivity2(client, "[SM] ", "%N has %s %t explosive bullets.", client, button ? "given" : "removed", target_name);
	else
		ShowActivity2(client, "[SM] ", "%N has %s %s explosive bullets.", client, button ? "given" : "removed", target_name);
		
	return Plugin_Handled;
}

public Action Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	if(!gEnabled)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(!gActivated[client])
		return Plugin_Continue;
		
	float pos[3];
	pos[0] = event.GetFloat("x");
	pos[1] = event.GetFloat("y");
	pos[2] = event.GetFloat("z");
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	char classname[32];
	GetEntityClassname(weapon, classname, sizeof(classname));
	CS_CreateExplosion(client, gDamage, gRadius, pos, classname);
	
	return Plugin_Continue;
}

void CS_CreateExplosion(int client, int damage, int radius, float pos[3], char[] classname)
{
	int entity;
	if((entity = CreateEntityByName("env_explosion")) != -1)
	{
		DispatchKeyValue(entity, "spawnflags", "552");
		DispatchKeyValue(entity, "rendermode", "5");
		DispatchKeyValue(entity, "classname", classname); 
		
		SetEntProp(entity, Prop_Data, "m_iMagnitude", damage);
		SetEntProp(entity, Prop_Data, "m_iRadiusOverride", radius);
		SetEntProp(entity, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);

		DispatchSpawn(entity);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		
		RequestFrame(TriggerExplosion, entity);
	}
}

public void TriggerExplosion(int entity)
{
	AcceptEntityInput(entity, "explode");
	AcceptEntityInput(entity, "Kill");
}