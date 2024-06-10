Action Command_PasstimeSimpleChatPrint(int client, int args)
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
	int redCursor, bluCursor = 0;
	// calculate possession time
	int totalPossessionTime = iBluBallTime + iRedBallTime;

#if defined(DEBUG)
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
			redTeam[redCursor] = x;
			redCursor++;
		}

		else if (TF2_GetClientTeam(x) == TFTeam_Blue) {
			bluTeam[bluCursor] = x;
			bluCursor++;
		}
	}
	for (int x = 1; x < MaxClients + 1; x++)
	{
		if (!IsValidClient(x, false)) continue;

		// if on red team, print red team's stats last
		// so it shows up most recently in chat
		if (TF2_GetClientTeam(x) == TFTeam_Red)
		{
			for (int i = 0; i < bluCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(bluTeam[i], playerName, sizeof(playerName));
				if (arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B GLS %d,\x073bc48f AST %d,\x07ffff00 SAV %d,\x07ff00ff INT %d,\x07ff8000 STL %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if (!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//                                                                    //\n//   BLU | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals, arriPlyRoundPassStats[bluTeam[i]].iPlyPanaceas, arriPlyRoundPassStats[bluTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[bluTeam[i]].iPlyDeathbombs, arriPlyRoundPassStats[bluTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[bluTeam[i]].iPlyFirstGrabs, arriPlyRoundPassStats[bluTeam[i]].iPlyCatapults, arriPlyRoundPassStats[bluTeam[i]].iPlyBlocks, arriPlyRoundPassStats[bluTeam[i]].iPlySteal2Saves);	 // have this be red so your team shows up first?
			}

			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				if (arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B GLS %d,\x073bc48f AST %d,\x07ffff00 SAV %d,\x07ff00ff INT %d,\x07ff8000 STL %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				else if (!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				PrintToConsole(x, "//                                                                    //\n//   RED | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals, arriPlyRoundPassStats[redTeam[i]].iPlyPanaceas, arriPlyRoundPassStats[redTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[redTeam[i]].iPlyDeathbombs, arriPlyRoundPassStats[redTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[redTeam[i]].iPlyFirstGrabs, arriPlyRoundPassStats[redTeam[i]].iPlyCatapults, arriPlyRoundPassStats[redTeam[i]].iPlyBlocks, arriPlyRoundPassStats[redTeam[i]].iPlySteal2Saves);
			}
			PrintToChat(x, "\x0700ffff[PASS] \x07C43F3BRED Team \x073BC43Bpossession: %.1f%%, \x074EA6C1BLU Team \x073BC43Bpossession: %.1f%%", redBallPossessionPercent, bluBallPossessionPercent)
		}
		// otherwise, print blue last
		else if (TF2_GetClientTeam(x) == TFTeam_Blue || TF2_GetClientTeam(x) == TFTeam_Spectator) {
			for (int i = 0; i < redCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(redTeam[i], playerName, sizeof(playerName));
				if (arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting || IsClientSourceTV(x))
					PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B GLS %d,\x073bc48f AST %d,\x07ffff00 SAV %d,\x07ff00ff INT %d,\x07ff8000 STL %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				else if (!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x07C43F3B %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals);
				PrintToConsole(x, "//                                                                    //\n//   RED | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[redTeam[i]].iPlyScores, arriPlyRoundPassStats[redTeam[i]].iPlyAssists, arriPlyRoundPassStats[redTeam[i]].iPlySaves, arriPlyRoundPassStats[redTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[redTeam[i]].iPlySteals, arriPlyRoundPassStats[redTeam[i]].iPlyPanaceas, arriPlyRoundPassStats[redTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[redTeam[i]].iPlyDeathbombs, arriPlyRoundPassStats[redTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[redTeam[i]].iPlyFirstGrabs, arriPlyRoundPassStats[redTeam[i]].iPlyCatapults, arriPlyRoundPassStats[redTeam[i]].iPlyBlocks, arriPlyRoundPassStats[redTeam[i]].iPlySteal2Saves);
			}

			for (int i = 0; i < bluCursor; i++)
			{
				char playerName[MAX_NAME_LENGTH];
				GetClientName(bluTeam[i], playerName, sizeof(playerName));
				if (arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting || IsClientSourceTV(x))
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B GLS %d,\x073bc48f AST %d,\x07ffff00 SAV %d,\x07ff00ff INT %d,\x07ff8000 STL %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				else if (!arrbJackAcqSettings[x].bPlySimpleChatPrintSetting && !arrbJackAcqSettings[x].bPlyToggleChatPrintSetting)
					PrintToChat(x, "\x0700ffff[PASS]\x074EA6C1 %s:\x073BC43B goals %d,\x073bc48f assists %d,\x07ffff00 saves %d,\x07ff00ff intercepts %d,\x07ff8000 steals %d", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals);
				PrintToConsole(x, "//                                                                    //\n//   BLU | %s\n//   %d goals, %d assists, %d saves, %d intercepts, %d steals              //\n//   %d Panaceas, %d win strats, %d deathbombs, %d handoffs               //\n//   %d first grabs, %d catapults, %d blocks, %d steal2saves              //\n//                                                                    //", playerName, arriPlyRoundPassStats[bluTeam[i]].iPlyScores, arriPlyRoundPassStats[bluTeam[i]].iPlyAssists, arriPlyRoundPassStats[bluTeam[i]].iPlySaves, arriPlyRoundPassStats[bluTeam[i]].iPlyIntercepts, arriPlyRoundPassStats[bluTeam[i]].iPlySteals, arriPlyRoundPassStats[bluTeam[i]].iPlyPanaceas, arriPlyRoundPassStats[bluTeam[i]].iPlyWinStrats, arriPlyRoundPassStats[bluTeam[i]].iPlyDeathbombs, arriPlyRoundPassStats[bluTeam[i]].iPlyHandoffs, arriPlyRoundPassStats[bluTeam[i]].iPlyFirstGrabs, arriPlyRoundPassStats[bluTeam[i]].iPlyCatapults, arriPlyRoundPassStats[bluTeam[i]].iPlyBlocks, arriPlyRoundPassStats[bluTeam[i]].iPlySteal2Saves);
			}
			PrintToChat(x, "\x0700ffff[PASS] \x074EA6C1BLU \x073BC43Bpossession: %.1f%%, \x07C43F3BRED \x073BC43Bpossession: %.1f%%", bluBallPossessionPercent, redBallPossessionPercent)
		}
	}

	for (int i = 0; i < MaxClients + 1; i++)
		ClearLocalStats(i);

	return Plugin_Stop;
}