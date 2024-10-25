#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "Password Utils", 
    description = "Password utils", 
    author = "ampere", 
    version = "1.0", 
    url = "github.com/maxijabase"
};

ConVar g_cvPassword;
ConVar g_cvCountdown;
bool g_bIsTimerRunning;

public void OnPluginStart()
{
    RegAdminCmd("sm_nopw", Command_NoPW, ADMFLAG_RCON, "Clear server password");
    RegAdminCmd("sm_pw", Command_PW, ADMFLAG_RCON, "Set server password");
    
    g_cvPassword = FindConVar("sv_password");
    g_cvCountdown = CreateConVar("sm_passwordutils_countdown", "60", "Amount of seconds the server must remain empty before clearing the password.");
}

public Action Command_NoPW(int client, int args)
{
    g_cvPassword.SetString("", false, false);
    ReplyToCommand(client, "[SM] Password cleared.");
    
    return Plugin_Handled;
}

public Action Command_PW(int client, int args)
{
    if (args != 1)
    {
        char pw[32];
        g_cvPassword.GetString(pw, sizeof(pw));
        if (pw[0] == '\0')
        {
            ReplyToCommand(client, "[SM] The server has no password.");
        }
        else
        {
            ReplyToCommand(client, "[SM] Password: %s", pw);
        }
        return Plugin_Handled;
    }
    
    char password[32];
    GetCmdArg(1, password, sizeof(password));
    g_cvPassword.SetString(password, false, false);
    
    return Plugin_Handled;
}

public void OnServerEmpty()
{
    char password[32];
    g_cvPassword.GetString(password, sizeof(password));
    
    if (password[0] != '\0')
    {
        PrintToServer("[SM] Starting timer to clear password...");
        CreateTimer(g_cvCountdown.FloatValue, Timer_ClearPassword);
        g_bIsTimerRunning = true;
    }
}

public void OnServerNotEmpty()
{
    if (g_bIsTimerRunning)
    {
        PrintToServer("[SM] Cancelling timer to clear password...");
        g_bIsTimerRunning = false;
    }
}

public Action Timer_ClearPassword(Handle timer)
{
    if (g_bIsTimerRunning)
    {
        g_cvPassword.SetString("", false, false);
        PrintToServer("[SM] Empty server! Clearing password.");
        g_bIsTimerRunning = false;
    }
    
    return Plugin_Stop;
} 