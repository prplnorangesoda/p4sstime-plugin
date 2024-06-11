#if !defined BLU
	#define BLU true
	#define RED false
#endif

enum
{
	MAX_MESSAGE_LENGTH = 192
}

static const char sGoalsLongFormat[]				= "\x073BC43B goals %d";
static const char sAssistsLongFormat[]			= "\x073bc48f assists %d";
static const char sSavesLongFormat[]				= "\x07ffff00 saves %d";
static const char sInterceptsLongFormat[]		= "\x07ff00ff intercepts %d";
static const char sStealsLongFormat[]				= "\x07ff8000 steals %d";

static const char sGoalsSimpleFormat[]			= "\x073BC43B GLS %d";
static const char sAssistsSimpleFormat[]		= "\x073bc48f AST %d";
static const char sSavesSimpleFormat[]			= "\x07ffff00 SAV %d";
static const char sInterceptsSimpleFormat[] = "\x07ff00ff INT %d";
static const char sStealsSimpleFormat[]			= "\x07ff8000 STL %d";

Action						Command_PasstimeSimpleChatPrint(int client, int args)
{
	int value = 0;
	if (GetCmdArgIntEx(1, value))
	{
		if (value == 1)
			arrbJackAcqSettings[client].bPlySimpleChatPrintSetting = true;
		else if (value == 0)
			arrbJackAcqSettings[client].bPlySimpleChatPrintSetting = false;
		if (value == 1 || value == 0)
		{
			SetCookieBool(client, cookieSimpleChatPrint, arrbJackAcqSettings[client].bPlySimpleChatPrintSetting);
			ReplyToCommand(client, "[PASS] Simple round chat summary: %s", arrbJackAcqSettings[client].bPlySimpleChatPrintSetting ? "ON" : "OFF");
		}
	}
	else
		ReplyToCommand(client, "[PASS] Invalid argument");
	return Plugin_Handled;
}

Action Command_PasstimeToggleChatPrint(int client, int args)
{
	int value = 0;
	if (GetCmdArgIntEx(1, value))
	{
		if (value == 1)
			arrbJackAcqSettings[client].bPlyToggleChatPrintSetting = true;
		else if (value == 0)
			arrbJackAcqSettings[client].bPlyToggleChatPrintSetting = false;
		if (value == 1 || value == 0)
		{
			SetCookieBool(client, cookieToggleChatPrint, arrbJackAcqSettings[client].bPlyToggleChatPrintSetting);
			ReplyToCommand(client, "[PASS] Toggle round chat summary: %s", arrbJackAcqSettings[client].bPlyToggleChatPrintSetting ? "OFF" : "ON");
		}
	}
	else
		ReplyToCommand(client, "[PASS] Invalid argument");
	return Plugin_Handled;
}

Action Timer_ShowMoreTF(Handle timer, any client)
{
	if (!IsValidClient(client))
		return Plugin_Stop;

	char	 num[3];
	Handle Kv = CreateKeyValues("data");
	IntToString(MOTDPANEL_TYPE_URL, num, sizeof(num));
	KvSetString(Kv, "title", "MoreTF");
	KvSetString(Kv, "type", num);
	KvSetString(Kv, "msg", moreurl);
	KvSetNum(Kv, "customsvr", 1);
	ShowVGUIPanel(client, "info", Kv);
	CloseHandle(Kv);

	return Plugin_Stop;
}

// Clear all plugin stats for the specified client.
void ClearLocalStats(int client)
{
	arrbPlyIsDead[client]													= false;
	arrbBlastJumpStatus[client]										= false;
	arrbPanaceaCheck[client]											= false;
	arrbWinStratCheck[client]											= false;

	arriPlyRoundPassStats[client].iPlyScores			= 0;
	arriPlyRoundPassStats[client].iPlyAssists			= 0;
	arriPlyRoundPassStats[client].iPlySaves				= 0;
	arriPlyRoundPassStats[client].iPlyIntercepts	= 0;
	arriPlyRoundPassStats[client].iPlySteals			= 0;
	arriPlyRoundPassStats[client].iPlyPanaceas		= 0;
	arriPlyRoundPassStats[client].iPlyWinStrats		= 0;
	arriPlyRoundPassStats[client].iPlyDeathbombs	= 0;
	arriPlyRoundPassStats[client].iPlyHandoffs		= 0;
	arriPlyRoundPassStats[client].iPlyFirstGrabs	= 0;
	arriPlyRoundPassStats[client].iPlyCatapults		= 0;
	arriPlyRoundPassStats[client].iPlyBlocks			= 0;
	arriPlyRoundPassStats[client].iPlySteal2Saves = 0;
}

// this is really fucking sloppy but shrug
Action Timer_DisplayStats(Handle timer)
{
	int redTeam[16], bluTeam[16];
	int redAmount, bluAmount = 0;
	// calculate possession time
	int totalPossessionTime = iBluBallTime + iRedBallTime;

#if defined(VERBOSE)
	LogToGame("BluBallTime: %d, RedBallTime: %d, totalPossessionTime = %d", iBluBallTime, iRedBallTime, totalPossessionTime);
#endif
	float bluBallPossessionPercent;
	float redBallPossessionPercent;

	if (iBluBallTime == 0)
		bluBallPossessionPercent = 0.0;
	else
		bluBallPossessionPercent = (float(iBluBallTime) / float(totalPossessionTime)) * 100;

	if (iRedBallTime == 0)
		redBallPossessionPercent = 0.0;
	else
		redBallPossessionPercent = (float(iRedBallTime) / float(totalPossessionTime)) * 100;

	for (int x = 1; x < MaxClients + 1; x++)
	{
		if (!IsValidClient(x)) continue;

		if (TF2_GetClientTeam(x) == TFTeam_Red)
		{
			redTeam[redAmount] = x;
			redAmount++;
		}

		else if (TF2_GetClientTeam(x) == TFTeam_Blue) {
			bluTeam[bluAmount] = x;
			bluAmount++;
		}
	}
	for (int x = 1; x < MaxClients + 1; x++)
	{
		if (!IsValidClient(x, false)) continue;

		// if on red team, print red team's stats last
		// so it shows up most recently in chat
		if (IsClientSourceTV(x))
		{
			PrintAllTeamStats(x, redTeam, redAmount, RED);
			PrintAllTeamStats(x, bluTeam, bluAmount, BLU);
			PrintToChat(x, "\x0700ffff[PASS] \x074EA6C1BLU \x073BC43Bpossession: %.2f%%, \x07C43F3BRED \x073BC43Bpossession: %.2f%%", bluBallPossessionPercent, redBallPossessionPercent);
			PrintToChat(x, "[PASS-TV] BLU possession time in ticks: %d", iRedBallTime);
			PrintToChat(x, "[PASS-TV] RED possession time in ticks: %d", iBluBallTime);
		}
		else if (TF2_GetClientTeam(x) == TFTeam_Red)
		{
			PrintAllTeamStats(x, bluTeam, bluAmount, BLU);
			PrintAllTeamStats(x, redTeam, redAmount, RED);
			PrintToChat(x, "\x0700ffff[PASS] \x07C43F3BRED \x073BC43Bpossession: %.2f%%, \x074EA6C1BLU \x073BC43Bpossession: %.2f%%", redBallPossessionPercent, bluBallPossessionPercent);
		}
		// otherwise, print blue last
		else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) {
			PrintAllTeamStats(x, redTeam, redAmount, RED);
			PrintAllTeamStats(x, bluTeam, bluAmount, BLU);
			PrintToChat(x, "\x0700ffff[PASS] \x074EA6C1BLU \x073BC43Bpossession: %.2f%%, \x07C43F3BRED \x073BC43Bpossession: %.2f%%", bluBallPossessionPercent, redBallPossessionPercent);
		}
	}

	for (int i = 0; i < MaxClients + 1; i++)
		ClearLocalStats(i);

	return Plugin_Stop;
}

/**
 * @param simplified whether to use the simplified 3 letter abbreviations (true) or long names (false)
 */
static void AssembleColoredStatsString(char[] buf, int maxLength, int client, bool simplified = false)
{
#if defined(VERBOSE)
	LogMessage("Assembling stats for client: %d", client);
#endif
	char sGoals[48];
	char sAssists[48];
	char sSaves[48];
	char sIntercepts[48];
	char sSteals[48];
	if (simplified)
	{
		Format(sGoals, sizeof(sGoals), sGoalsSimpleFormat, arriPlyRoundPassStats[client].iPlyScores);
		Format(sAssists, sizeof(sAssists), sAssistsSimpleFormat, arriPlyRoundPassStats[client].iPlyAssists);
		Format(sSaves, sizeof(sSaves), sSavesSimpleFormat, arriPlyRoundPassStats[client].iPlySaves);
		Format(sIntercepts, sizeof(sIntercepts), sInterceptsSimpleFormat, arriPlyRoundPassStats[client].iPlyIntercepts);
		Format(sSteals, sizeof(sSteals), sStealsSimpleFormat, arriPlyRoundPassStats[client].iPlySteals);
	}
	else
	{
		Format(sGoals, sizeof(sGoals), sGoalsLongFormat, arriPlyRoundPassStats[client].iPlyScores);
		Format(sAssists, sizeof(sAssists), sAssistsLongFormat, arriPlyRoundPassStats[client].iPlyAssists);
		Format(sSaves, sizeof(sSaves), sSavesLongFormat, arriPlyRoundPassStats[client].iPlySaves);
		Format(sIntercepts, sizeof(sIntercepts), sInterceptsLongFormat, arriPlyRoundPassStats[client].iPlyIntercepts);
		Format(sSteals, sizeof(sSteals), sStealsLongFormat, arriPlyRoundPassStats[client].iPlySteals);
	}

	Format(buf, maxLength, "%s,%s,%s,%s,%s", sGoals, sAssists, sSaves, sIntercepts, sSteals);
}

static void PrintAllTeamStats(int client, int[] teamMembers, int len, bool isBlu)
{
	// format names to blue
	if (isBlu)
	{
		for (int i = 0; i < len; i++)
		{
			char playerName[MAX_NAME_LENGTH];
			GetClientName(teamMembers[i], playerName, sizeof(playerName));
			// if client requests simplified print:
			if (arrbJackAcqSettings[client].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[client].bPlyToggleChatPrintSetting)
			{
				char stats[MAX_MESSAGE_LENGTH];
				AssembleColoredStatsString(stats, sizeof(stats), teamMembers[i], true);
				PrintToChat(client, "\x0700ffff[PASS]\x074EA6C1 %s:%s", playerName, stats);
			}
			// if client requests regular print:
			else if (!arrbJackAcqSettings[client].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[client].bPlyToggleChatPrintSetting)
			{
				char stats[MAX_MESSAGE_LENGTH];
				AssembleColoredStatsString(stats, sizeof(stats), teamMembers[i]);
				PrintToChat(client, "\x0700ffff[PASS]\x074EA6C1 %s:%s", playerName, stats);
			}
			PrintToConsole(client, "//                                                                    //\n//   BLU | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[teamMembers[i]].iPlyScores, arriPlyRoundPassStats[teamMembers[i]].iPlyAssists, arriPlyRoundPassStats[teamMembers[i]].iPlySaves, arriPlyRoundPassStats[teamMembers[i]].iPlyIntercepts, arriPlyRoundPassStats[teamMembers[i]].iPlySteals, arriPlyRoundPassStats[teamMembers[i]].iPlyPanaceas, arriPlyRoundPassStats[teamMembers[i]].iPlyWinStrats, arriPlyRoundPassStats[teamMembers[i]].iPlyDeathbombs, arriPlyRoundPassStats[teamMembers[i]].iPlyHandoffs, arriPlyRoundPassStats[teamMembers[i]].iPlyFirstGrabs, arriPlyRoundPassStats[teamMembers[i]].iPlyCatapults, arriPlyRoundPassStats[teamMembers[i]].iPlyBlocks, arriPlyRoundPassStats[teamMembers[i]].iPlySteal2Saves);	// have this be red so your team shows up first?
		}
	}
	// format names to red
	else
	{
		for (int i = 0; i < len; i++)
		{
			char playerName[MAX_NAME_LENGTH];
			GetClientName(teamMembers[i], playerName, sizeof(playerName));
			if (arrbJackAcqSettings[client].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[client].bPlyToggleChatPrintSetting)
			{
				char stats[MAX_MESSAGE_LENGTH];
				AssembleColoredStatsString(stats, sizeof(stats), teamMembers[i], true);
				PrintToChat(client, "\x0700ffff[PASS]\x07C43F3B %s:%s", playerName, stats);
			}
			else if (!arrbJackAcqSettings[client].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[client].bPlyToggleChatPrintSetting)
			{
				char stats[MAX_MESSAGE_LENGTH];
				AssembleColoredStatsString(stats, sizeof(stats), teamMembers[i]);
				PrintToChat(client, "\x0700ffff[PASS]\x07C43F3B %s:%s", playerName, stats);
			}
			PrintToConsole(client, "//                                                                    //\n//   RED | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[teamMembers[i]].iPlyScores, arriPlyRoundPassStats[teamMembers[i]].iPlyAssists, arriPlyRoundPassStats[teamMembers[i]].iPlySaves, arriPlyRoundPassStats[teamMembers[i]].iPlyIntercepts, arriPlyRoundPassStats[teamMembers[i]].iPlySteals, arriPlyRoundPassStats[teamMembers[i]].iPlyPanaceas, arriPlyRoundPassStats[teamMembers[i]].iPlyWinStrats, arriPlyRoundPassStats[teamMembers[i]].iPlyDeathbombs, arriPlyRoundPassStats[teamMembers[i]].iPlyHandoffs, arriPlyRoundPassStats[teamMembers[i]].iPlyFirstGrabs, arriPlyRoundPassStats[teamMembers[i]].iPlyCatapults, arriPlyRoundPassStats[teamMembers[i]].iPlyBlocks, arriPlyRoundPassStats[teamMembers[i]].iPlySteal2Saves);
		}
	}
}