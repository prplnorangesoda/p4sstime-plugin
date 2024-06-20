Action Command_PasstimeSpawnBall(int client, int args)
{
	bWaitingForBallSpawnToRestart = true;
	ServerCommand("mp_restartgame_immediate 1");
}