/*
	_botks
	Author: MaxShadow
	Date: 02/20/2023
	Give random killstreaks to bots
*/

#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\gametypes\_hud_message;
#include common_scripts\utility;


/*
	Entry point to the bots
*/
init()
{
	level.bw_VERSION = "1.0.0";
	
	if ( getDvar( "grs_main" ) == "" )
		setDvar( "grs_main", true );

	//if ( !getDvarInt( "grs_main" ) )
	//	return;

	if ( getDvar( "grs_player_type" ) == "" )
		setDvar( "grs_player_type", "bots" ); // Who gets random scorestreaks - bots, players, all
		
	if ( getDvar( "grs_player_team" ) == "" )
		setDvar( "grs_player_team", "all" ); // What team gets random scorestreaks - allies, axis, all
		
	if ( getDvar( "grs_notify" ) == "" )
		setDvar( "grs_notify", false ); // Send a chat message to all players when a scorestreak was given away
		
	if ( getDvar( "grs_delay" ) == "" )
		setDvar( "grs_delay", 30 ); // Delay between scorestreak drops
		
	if ( getDvar( "grs_allowed_streaks" ) == "" )
		setDvar( "grs_allowed_streaks", "uav,rc_xd,hunter_killer,care_package,counter_uav,guardian,hellstorm_missile,lightning_strike,sentry_gun,death_machine,war_machine,dragonfire,agr,stealth_chopper,orbital_vsat,escort_drone,emp_systems,warthog,lodestar,vtol_warship,k9_unit,swarm" ); // What killstreaks can be given away

	thread mainLoop();
}

/*
	Get array of allowed killstreaks
*/
getKillstreakArray(isForBots)
{
	killstreakIds = [];
	killstreakIds["uav"] = "radar_mp";
	killstreakIds["counter_uav"] = "counteruav_mp";
	killstreakIds["hellstorm_missile"] = "remote_missile_mp";
	killstreakIds["lightning_strike"] = "planemortar_mp";
	killstreakIds["stealth_chopper"] = "helicopter_comlink_mp";
	killstreakIds["orbital_vsat"] = "radardirection_mp";
	killstreakIds["escort_drone"] = "helicopter_guard_mp";
	killstreakIds["warthog"] = "straferun_mp";
	killstreakIds["lodestar"] = "remote_mortar_mp";
	killstreakIds["swarm"] = "missile_swarm_mp";
	killstreakIds["agr"] = "inventory_ai_tank_drop_mp";
	killstreakIds["k9_unit"] = "dogs_mp";
	killstreakIds["emp_systems"] = "emp_mp";
	killstreakIds["vtol_warship"] = "helicopter_player_gunner_mp";
	killstreakIds["death_machine"] = "minigun_mp";
	killstreakIds["war_machine"] = "m32_mp";
	killstreakIds["hunter_killer"] = "inventory_missile_drone_mp";
	killstreakIds["dragonfire"] = "qrdrone_mp";
	killstreakIds["rc_xd"] = "rcbomb_mp";
	killstreakIds["care_package"] = "inventory_supply_drop_mp";
	killstreakIds["sentry_gun"] = "autoturret_mp";
	killstreakIds["guardian"] = "microwaveturret_mp";
	
	allowedStreaks = getDvar("grs_allowed_streaks");
	
	split = strtok( allowedStreaks, "," );
	
	result = [];
	
	for ( i = 0; i < split.size; i++ ) {
		streak = split[i];
		streakId = killstreakIds[streak];
		
		if (isDefined(streakId)) {
			if (isForBots) {
				if (streakId != "remote_mortar_mp" && streakId != "helicopter_player_gunner_mp" && streakId != "qrdrone_mp" && streakId != "rcbomb_mp") {
					result[result.size] = killstreakIds[streak];
				}
			}
			else {
				result[result.size] = killstreakIds[streak];
			}
		}
	}
	
	return result;
}

/*
	Gives killstreak to player
*/
GiveKillstreak(killstreak)
{
	self maps\mp\killstreaks\_killstreaks::givekillstreak(killstreak, 5594, false, 5594);
}

/*
	Starts the threads for bots.
*/
mainLoop()
{
	level endon( "game_ended" );

	killstreakNames = [];
	killstreakNames["radar_mp"] = "UAV";
	killstreakNames["counteruav_mp"] = "Counter-UAV";
	killstreakNames["remote_missile_mp"] = "Hellstorm Missile";
	killstreakNames["planemortar_mp"] = "Lightning Strike";
	killstreakNames["helicopter_comlink_mp"] = "Stealth Chopper";
	killstreakNames["radardirection_mp"] = "Orbital VSAT";
	killstreakNames["helicopter_guard_mp"] = "Escort Drone";
	killstreakNames["straferun_mp"] = "Warthog";
	killstreakNames["remote_mortar_mp"] = "Lodestar";
	killstreakNames["missile_swarm_mp"] = "Swarm";
	killstreakNames["inventory_ai_tank_drop_mp"] = "A.G.R.";
	killstreakNames["dogs_mp"] = "K9 Unit";
	killstreakNames["emp_mp"] = "EMP Systems";
	killstreakNames["helicopter_player_gunner_mp"] = "VTOL Warship";
	killstreakNames["minigun_mp"] = "Death Machine";
	killstreakNames["m32_mp"] = "War Machine";
	killstreakNames["inventory_missile_drone_mp"] = "Hunter Killer";
	killstreakNames["qrdrone_mp"] = "Dragonfire";
	killstreakNames["rcbomb_mp"] = "RC-XD";
	killstreakNames["inventory_supply_drop_mp"] = "Care Package";
	killstreakNames["autoturret_mp"] = "Sentry Gun";
	killstreakNames["microwaveturret_mp"] = "Guardian";
	
	for ( ;; )
	{
		delay = getDVarInt( "grs_delay" );
		notf = getDVarInt( "grs_notify" );
		
		if (!delay || delay < 5) {
			delay = 5;
		}
		
		wait delay;
		
		if (getDvarInt( "grs_main" )) {
			tempPlayer = "";
			
			playerType = getDvar("grs_player_type");
			if (playerType != "bots" && playerType != "players" && playerType != "all")
				playerType = "all";
				
			team = getDvar("grs_player_team");
			if (team != "allies" && team != "axis" && team != "all")
				team = "all";
			
			tempPlayer = PickRandom(getPlayerArray(playerType, team));

			if (isDefined(tempPlayer)) {
				isBot = tempPlayer isBot();
				
				killstreakList = getKillstreakArray(isBot);
				
				if (killstreakList.size > 0) {
					tempKs = PickRandom(killstreakList);
					
					tempPlayer GiveKillstreak(tempKs);
					
					if (notf) {
						allPlayers = getPlayerArray("all", "all");
						for ( i = 0; i < allPlayers.size; i++ )
						{
							playr = allPlayers[i];
							playr IPrintLn("Giving killstreak (" + killstreakNames[tempKs] + ") to '" + tempPlayer.name + "'");
						}
					}
				}
			}
		}
	}
}

/*
	Picks random
*/
PickRandom(arr)
{
	if ( !arr.size )
		return undefined;

	return arr[randomInt( arr.size )];
}

/*
	Is bot
*/
isBot()
{
	if ( !isDefined( self ) || !isPlayer( self ) )
		return false;

	if ( !isDefined( self.pers ) || !isDefined( self.team ) )
		return false;

	if ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] )
		return true;

	if ( isDefined( self.pers["isBotWarfare"] ) && self.pers["isBotWarfare"] )
		return true;

	if ( self istestclient() )
		return true;

	return false;
}

/*
	Returns array of bots
*/
getPlayerArray(type, team)
{
	answer = [];

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		
		if ( isDefined( player ) && isDefined( player.team )) {
			if (
				(type == "bots" && player isBot()) ||
				(type == "players" && !(player isBot())) ||
				(type == "all")
			) {
				if (
					(team == "allies" && player.team == "allies") ||
					(team == "axis" && player.team == "axis") ||
					(team == "all" && (player.team == "allies" || player.team == "axis"))
				) {
					answer[answer.size] = player;
				}
			}
		}
	}

	return answer;
}