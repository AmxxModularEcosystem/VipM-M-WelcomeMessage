#include <amxmodx>
#include <VipModular>

#pragma semicolon 1
#pragma compress 1

public stock const PluginName[] = "[VipM-M] Welcome Message";
public stock const PluginVersion[] = "1.0.0";
public stock const PluginAuthor[] = "ArKaNeMaN";
public stock const PluginURL[] = "t.me/arkanaplugins";
public stock const PluginDescription[] = "Welcome messages for Vip Modular";

new const MODULE_NAME[] = "WelcomeMessage";

enum E_Cvars {
    Float:Cvar_Delay,
}
new Cvars[E_Cvars];
#define Cvar(%1) Cvars[Cvar_%1]

new g_sUserIps[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_sUserSteamIds[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];

public VipM_OnInitModules() {
    register_plugin(PluginName, PluginVersion, PluginAuthor);

    VipM_Modules_Register(MODULE_NAME);
    VipM_Modules_AddParams(MODULE_NAME, 
        "Message", ptString, true
    );

    RegisterCvars();
}

public client_putinserver(UserId) {
    get_user_ip(UserId, g_sUserIps[UserId], charsmax(g_sUserIps[]), true);
    get_user_authid(UserId, g_sUserSteamIds[UserId], charsmax(g_sUserSteamIds[]));

    set_task(Cvar(Delay), "@Task_ShowMessage", UserId);
}

public client_disconnected(UserId) {
    remove_task(UserId);
}

@Task_ShowMessage(const UserId) {
    new Trie:tParams = VipM_Modules_GetParams(MODULE_NAME, UserId);

    new sMessage[256];
    VipM_Params_GetStr(tParams, "Message", sMessage, charsmax(sMessage), "");

    if (sMessage[0]) {
        new sName[MAX_NAME_LENGTH];
        get_user_name(UserId, sName, charsmax(sName));

        replace_all(sMessage, charsmax(sMessage), "{name}", sName);
        replace_all(sMessage, charsmax(sMessage), "{ip}", g_sUserIps[UserId]);
        replace_all(sMessage, charsmax(sMessage), "{steamid}", g_sUserSteamIds[UserId]);

        replace_all(sMessage, charsmax(sMessage), "^^1", "^1");
        replace_all(sMessage, charsmax(sMessage), "^^3", "^3");
        replace_all(sMessage, charsmax(sMessage), "^^4", "^4");

        client_print_color(0, print_team_default, "%s", sMessage);
    }
}

RegisterCvars() {
    bind_pcvar_float(create_cvar(
        "VipM_WelcomeMessage_Delay", "5.0", FCVAR_NONE,
        "Задержка перед показом сообщения.^nЗа время задержки привилеги игрока должны успеть загрузиться.",
        true, 1.0
    ), Cvar(Delay));

    AutoExecConfig(true, "VipM-M-WelcomeMessage");
}
