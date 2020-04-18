#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

#pragma semicolon 1
#define MAX_FILE_LEN 80
#define NUMBER_OF_SONGS 10

new String:soundNames[NUMBER_OF_SONGS][MAX_FILE_LEN] = 
{
	"66thserversounds/aaaaaa.mp3",
	"66thserversounds/countryroads.mp3",
	"66thserversounds/gbu.mp3",
	"66thserversounds/gold.mp3",
	"66thserversounds/cheeki_breeki.mp3",
	"66thserversounds/rome.mp3",
	"66thserversounds/marchingtogether.mp3",
	"66thserversounds/run.mp3",
	"66thserversounds/numanuma.mp3",
	"66thserversounds/downunder.mp3"
};

char roundEndSoundName[MAX_FILE_LEN] = "66thserversounds/apcdestroyed.mp3";

#define PLUGIN_VERSION "1.0"
public Plugin:myinfo = 
{
	name = "Random Server Join Sound",
	author = "ChrisK112",
	description = "Plays a randomly selected sound to user upon joining the server",
	version = PLUGIN_VERSION,
	url = "https://chrisk112.github.io/portfolio/#/"
};
public OnPluginStart()
{
	// Create the rest of the cvar's
	CreateConVar("sm_randsound_version", PLUGIN_VERSION, "Plugin Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	
	//Hook events
	//we will leave this for the future, in case we get a proper way of determining round end
	//HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	
}
//not ever run in this version
public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = event.GetInt("userid");
	new clientp = GetClientOfUserId(client);
	new teamp = GetClientTeam(clientp);
	if(teamp != 0)
	{
		if(LastOnTeamDead(teamp))
		{
			PlayEndRoundSound();
		}
	}
	
	
	
}
//not ever run in this version
//check if last person on team is dead - 2 is american, 3 is brit
//this is checked BEFORE the player is registered as "dead" - so he will count toward total
stock bool:LastOnTeamDead(int player_team)
{
	int alive = 0;
    for(int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) )
        {
			new team = GetClientTeam(i);
            if(team == player_team && IsPlayerAlive(i))
			{
				alive++;
				if(alive > 1)
				{
					return false;
				}
			}
			
        }
    }
	//1 if last, 0 if he dissapeared?
	if(alive == 0 || alive == 1) 
	{
		return true;
	}
	
	//would be hard pressed to get here
	return false;

}

//not ever run in this version
public PlayEndRoundSound()
{
	//PrintToChatAll("Trying to emit: %s", roundEndSoundName);
	//EmitGameSoundToAll doesn't seem to be working : loopthrough clients and play sound to them instead
	//also, for some reason the last person to die doesnt hear the sound. wth?
	for(int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) )
        {
			EmitSoundToClient(i,roundEndSoundName);
        }
    }
	
}

public OnMapStart()
{
	PrepareSounds();

}

//This loads the sounds to the DL list
public PrepareSounds()
{
	//loop through all sounds, and put them to dl list
	decl String:buffer[MAX_FILE_LEN];
	for (int i = 0; i < NUMBER_OF_SONGS; i++)
    {
		PrecacheSound(soundNames[i], true);
		Format(buffer, sizeof(buffer), "sound/%s", soundNames[i]);
		AddFileToDownloadsTable(buffer);
    }
	
	//and once more for round end sound
	//PrecacheSound(roundEndSoundName, true);
	//Format(buffer, sizeof(buffer), "sound/%s", roundEndSoundName);
	//AddFileToDownloadsTable(buffer);


}

//this plays sound to client when he joins
public OnClientPostAdminCheck(client)
{
	//TODO - first check if its TheSoul, then play his sound to the entire server. Could do this for other people too
	//get random sound name
	EmitSoundToClient(client,soundNames[GetRandomSound()]);
}

//get random sound name from array
stock int GetRandomSound() 
{
	int picked;
	picked = GetRandomInt(0,NUMBER_OF_SONGS-1);
	return picked;
	
} 

//TODO Make server play sound to all upon TheSoul joining the server