#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Panel System v3.0
//
// File      : filterscripts/features/crp_admin.pwn
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fokus v3.0:
// - Admin Panel Foundation
// - Account Username Identity
// - RankName + Account Username Admin Identity
// - Admin Duty Foundation
// - Admin List
// - Duty Online
// - Admins
// - Logs
// - Ban / Kick / Jail / Warning / Mute / Reports
// - Faction and Families Logs
// - Admin Settings
// - Money Settings
// - Admin Division
// - Faction Handler
// - Families Handler
// - Houses & Business Handler
// - Developer Protection
// - Hierarchy Protection
// - Handler Access Protection
// - RemoteFunction Bridge
//
// IMPORTANT:
// Admin Rank is ACCOUNT based.
// Admin Rank is NOT Character based.
//
// IMPORTANT:
// Command implementation belongs to:
// filterscripts/features/crp_admin_cmd.pwn
//
// Persistent log implementation belongs to:
// filterscripts/features/crp_admin_logs.pwn
//
// No Archives.
// No Archived Reports.
// No command implementation in this file.
// ============================================================


// ============================================================
// COLORS
// ============================================================

#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_RED               0xFF0000FF
#define COLOR_GREEN             0x00FF00FF
#define COLOR_YELLOW            0xFFFF00FF
#define COLOR_GREY              0xBFC0C2FF

#define COLOR_ADMIN_CHAT        0xFF4444FF
#define COLOR_ADMIN_RANK        0xFF6666FF
#define COLOR_ADMIN_USERNAME    0xFF4444FF
#define COLOR_ADMIN_MESSAGE     0xFFFFFFFF

#define COLOR_PANEL             0xD8B56AFF
#define COLOR_EMERALD           0x09261FFF


// ============================================================
// ADMIN RANK
// ============================================================

#define ADMIN_NO_STAFF          0
#define ADMIN_INTERN            1
#define ADMIN_HELPER            2
#define ADMIN_SENIOR_HELPER     3
#define ADMIN_ADMIN             4
#define ADMIN_SENIOR_ADMIN      5
#define ADMIN_SUPERVISOR        6
#define ADMIN_HIGH_ADMIN        7
#define ADMIN_ADMIN_DIRECTOR    8
#define ADMIN_SERVER_DIRECTOR   9
#define ADMIN_DEVELOPER         10


// ============================================================
// ADMIN DIVISION
// ============================================================

#define ADMIN_DIVISION_NONE             0
#define ADMIN_DIVISION_FACTION_FAMILY  1
#define ADMIN_DIVISION_HOUSE_BUSINESS  2


// ============================================================
// FACTION
// ============================================================

#define ADMIN_FACTION_NONE      0
#define ADMIN_FACTION_LSPD      1
#define ADMIN_FACTION_LSMD      2
#define ADMIN_FACTION_LAN       3
#define ADMIN_FACTION_GOV       4


// ============================================================
// FAMILY
// ============================================================

#define ADMIN_FAMILY_NONE       0
#define ADMIN_FAMILY_SLOT_1     1
#define ADMIN_FAMILY_SLOT_2     2
#define ADMIN_FAMILY_SLOT_3     3
#define ADMIN_FAMILY_SLOT_4     4
#define ADMIN_FAMILY_SLOT_5     5
#define ADMIN_FAMILY_SLOT_6     6
#define ADMIN_FAMILY_SLOT_7     7
#define ADMIN_FAMILY_SLOT_8     8
#define ADMIN_FAMILY_SLOT_9     9
#define ADMIN_FAMILY_SLOT_10    10


// ============================================================
// PANEL STATE
// ============================================================

#define ADMIN_PANEL_NONE            0
#define ADMIN_PANEL_MAIN            1
#define ADMIN_PANEL_LIST            2
#define ADMIN_PANEL_DUTY            3
#define ADMIN_PANEL_ADMINS          4
#define ADMIN_PANEL_LOGS            5
#define ADMIN_PANEL_REPORTS         6
#define ADMIN_PANEL_ADMIN_SETTINGS  7
#define ADMIN_PANEL_MONEY_SETTINGS 8
#define ADMIN_PANEL_ADMIN_DIVISION  9
#define ADMIN_PANEL_FACTION         10
#define ADMIN_PANEL_FAMILIES        11
#define ADMIN_PANEL_HOUSE_BUSINESS  12
#define ADMIN_PANEL_LOG_FACTION     13
#define ADMIN_PANEL_LOG_FAMILIES    14


// ============================================================
// LOG CATEGORY
// ============================================================

#define ADMIN_LOG_NONE              0
#define ADMIN_LOG_BAN               1
#define ADMIN_LOG_KICK              2
#define ADMIN_LOG_JAIL              3
#define ADMIN_LOG_WARNING           4
#define ADMIN_LOG_MUTE              5
#define ADMIN_LOG_REPORT            6
#define ADMIN_LOG_FACTION           7
#define ADMIN_LOG_FAMILY            8
#define ADMIN_LOG_OTHER             9


// ============================================================
// HANDLER TYPE
// ============================================================

#define ADMIN_HANDLER_NONE          0
#define ADMIN_HANDLER_FACTION       1
#define ADMIN_HANDLER_FAMILY        2
#define ADMIN_HANDLER_HOUSE         3
#define ADMIN_HANDLER_BUSINESS      4


// ============================================================
// LIMITS
// ============================================================

#define ADMIN_USERNAME_LENGTH       25
#define ADMIN_RANKNAME_LENGTH       32
#define ADMIN_DIALOG_SIZE            4096

#define ADMIN_FACTION_NAME_LENGTH   32
#define ADMIN_HANDLER_MAX             50


// ============================================================
// PLAYER ADMIN DATA
// ============================================================
//
// Runtime only.
//
// Persistence of Admin Rank will be handled later through
// Account Storage when explicitly integrated.
//
// ============================================================

new gPlayerAdminRank[MAX_PLAYERS];

new gPlayerAccountUsername[MAX_PLAYERS][ADMIN_USERNAME_LENGTH];

new bool:gPlayerAdminDuty[MAX_PLAYERS];
new gPlayerAdminDutyStart[MAX_PLAYERS];
new gPlayerAdminDutyTotal[MAX_PLAYERS];

new gPlayerAdminPanel[MAX_PLAYERS];


// ============================================================
// ADMIN DIVISION DATA
// ============================================================
//
// Handler assignment is account based.
//
// A handler must already have minimum Admin Level 6.
//
// Rank 9 / Rank 10 only may manage handlers.
//
// ============================================================

new gFactionFamilyHandler[MAX_PLAYERS];
new gHouseBusinessHandler[MAX_PLAYERS];

new gFactionHandlerID[5];
new gFamilyHandlerID[11];

new gHouseHandlerID;
new gBusinessHandlerID;

new gPlayerActiveFaction[MAX_PLAYERS];
new gPlayerActiveFamily[MAX_PLAYERS];


// ============================================================
// PLAYER UI CACHE
// ============================================================

new gSelectedAdminTarget[MAX_PLAYERS];
new gSelectedHandlerTarget[MAX_PLAYERS];

new gSelectedFaction[MAX_PLAYERS];
new gSelectedFamily[MAX_PLAYERS];


// ============================================================
// DIALOG IDS
// ============================================================

#define DIALOG_ADMIN_MAIN              3000
#define DIALOG_ADMIN_LIST              3001
#define DIALOG_ADMIN_DUTY              3002
#define DIALOG_ADMIN_ADMINS            3003
#define DIALOG_ADMIN_LOGS              3004
#define DIALOG_ADMIN_REPORTS           3005

#define DIALOG_ADMIN_SETTINGS          3010
#define DIALOG_ADMIN_MONEY_SETTINGS    3011
#define DIALOG_ADMIN_DIVISION          3012

#define DIALOG_ADMIN_FACTION           3020
#define DIALOG_ADMIN_FAMILIES          3021
#define DIALOG_ADMIN_HOUSE_BUSINESS    3022

#define DIALOG_ADMIN_LOG_FACTION       3030
#define DIALOG_ADMIN_LOG_FAMILIES      3031

#define DIALOG_ADMIN_HANDLER_LIST      3040
#define DIALOG_ADMIN_HANDLER_CONFIRM   3041


// ============================================================
// FORWARD DECLARATIONS
// ============================================================

forward CRP_AdminOpenPanel(playerid);
forward CRP_AdminGetRank(playerid);
forward CRP_AdminIsStaffRemote(playerid);
forward CRP_AdminIsDeveloperRemote(playerid);
forward CRP_AdminCanTargetRemote(actorid, targetid);
forward CRP_AdminGetDivision(playerid);
forward CRP_AdminGetFaction(playerid);
forward CRP_AdminGetFamily(playerid);
forward CRP_AdminGetHandlerType(playerid);
forward CRP_AdminGetAccountUsername(playerid, output[], size);
forward CRP_AdminSetRankRemote(playerid, rank);
forward CRP_AdminSetFactionRemote(playerid, faction);
forward CRP_AdminSetFamilyRemote(playerid, family);


// ============================================================
// RANK NAME
// ============================================================

stock CRP_GetAdminRankName(rank, output[], size)
{
    switch(rank)
    {
        case ADMIN_DEVELOPER:
        {
            format(output, size, "Developer");
        }

        case ADMIN_SERVER_DIRECTOR:
        {
            format(output, size, "Server Director");
        }

        case ADMIN_ADMIN_DIRECTOR:
        {
            format(output, size, "Admin Director");
        }

        case ADMIN_HIGH_ADMIN:
        {
            format(output, size, "High Admin");
        }

        case ADMIN_SUPERVISOR:
        {
            format(output, size, "Supervisor Admin");
        }

        case ADMIN_SENIOR_ADMIN:
        {
            format(output, size, "Senior Admin");
        }

        case ADMIN_ADMIN:
        {
            format(output, size, "Admin");
        }

        case ADMIN_SENIOR_HELPER:
        {
            format(output, size, "Senior Helper");
        }

        case ADMIN_HELPER:
        {
            format(output, size, "Helper");
        }

        case ADMIN_INTERN:
        {
            format(output, size, "Intern Staff");
        }

        default:
        {
            format(output, size, "No Staff");
        }
    }

    return 1;
}


// ============================================================
// ACCOUNT IDENTITY
// ============================================================

stock CRP_AdminLoadAccountIdentity(playerid)
{
    if(!IsPlayerConnected(playerid))
    {
        return 0;
    }

    GetPlayerName(
        playerid,
        gPlayerAccountUsername[playerid],
        ADMIN_USERNAME_LENGTH
    );

    return 1;
}


// ============================================================
// BASIC VALIDATION
// ============================================================

stock CRP_AdminIsValidPlayer(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    if(!IsPlayerConnected(playerid))
    {
        return 0;
    }

    return 1;
}


stock CRP_AdminIsStaff(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] > ADMIN_NO_STAFF;
}


stock CRP_AdminIsDeveloper(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] == ADMIN_DEVELOPER;
}


stock CRP_AdminIsDirector(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] == ADMIN_DEVELOPER)
    {
        return 1;
    }

    if(gPlayerAdminRank[playerid] == ADMIN_SERVER_DIRECTOR)
    {
        return 1;
    }

    return 0;
}


// ============================================================
// DEVELOPER INTERNAL SETTER
// ============================================================
//
// This function is NOT exposed as a command.
//
// Rank 10 must never be assigned through normal Admin Settings.
//
// ============================================================

stock CRP_SetDeveloperInternal(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    gPlayerAdminRank[playerid] = ADMIN_DEVELOPER;

    return 1;
}


// ============================================================
// TARGET HIERARCHY
// ============================================================

stock CRP_AdminCanTarget(actorid, targetid)
{
    if(!CRP_AdminIsValidPlayer(actorid))
    {
        return 0;
    }

    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(!CRP_AdminIsStaff(actorid))
    {
        return 0;
    }

    if(actorid == targetid)
    {
        return 0;
    }

    // Developer is completely protected.
    if(CRP_AdminIsDeveloper(targetid))
    {
        return 0;
    }

    // Developer may target lower ranks.
    if(CRP_AdminIsDeveloper(actorid))
    {
        return 1;
    }

    // Same or higher rank cannot be targeted.
    if(gPlayerAdminRank[targetid] >= gPlayerAdminRank[actorid])
    {
        return 0;
    }

    return 1;
}


// ============================================================
// ADMIN SETTINGS ACCESS
// ============================================================
//
// Only:
// Rank 10 Developer
// Rank 9 Server Director
//
// ============================================================

stock CRP_AdminCanAccessAdminSettings(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR)
    {
        return 1;
    }

    return 0;
}


// ============================================================
// MONEY SETTINGS ACCESS
// ============================================================
//
// Only Rank 9 / Rank 10.
//
// ============================================================

stock CRP_AdminCanAccessMoneySettings(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR)
    {
        return 1;
    }

    return 0;
}


// ============================================================
// ADMIN DIVISION ACCESS
// ============================================================
//
// Only Rank 9 / Rank 10.
//
// Handler-specific menus are checked separately.
//
// ============================================================

stock CRP_AdminCanAccessAdminDivision(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR)
    {
        return 1;
    }

    return 0;
}


// ============================================================
// HANDLER MINIMUM RANK
// ============================================================

stock CRP_AdminCanBecomeHandler(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    // Handler must be at least Admin Level 6.
    if(gPlayerAdminRank[playerid] < ADMIN_SUPERVISOR)
    {
        return 0;
    }

    // Developer protection.
    if(CRP_AdminIsDeveloper(playerid))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// HANDLER ACCESS
// ============================================================

stock CRP_AdminIsFactionFamilyHandler(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gFactionFamilyHandler[playerid] == 1;
}


stock CRP_AdminIsHouseBusinessHandler(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gHouseBusinessHandler[playerid] == 1;
}


// ============================================================
// ADMIN LIST DISPLAY
// ============================================================

stock CRP_AdminBuildList(output[], size)
{
    output[0] = EOS;

    strcat(
        output,
        "Account Username\tRank\tDuty\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        new rankname[ADMIN_RANKNAME_LENGTH];
        new dutyname[16];
        new line[96];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        if(gPlayerAdminDuty[i])
        {
            format(dutyname, sizeof(dutyname), "ON");
        }
        else
        {
            format(dutyname, sizeof(dutyname), "OFF");
        }

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\n",
            gPlayerAccountUsername[i],
            rankname,
            dutyname
        );

        strcat(output, line);
    }

    return 1;
}


// ============================================================
// DUTY DISPLAY
// ============================================================

stock CRP_AdminGetDutySeconds(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    new total = gPlayerAdminDutyTotal[playerid];

    if(gPlayerAdminDuty[playerid])
    {
        total += gettime() - gPlayerAdminDutyStart[playerid];
    }

    return total;
}


// ============================================================
// DUTY ON
// ============================================================
//
// Command itself will be triggered by crp_admin_cmd.pwn.
//
// This function remains here as the central runtime state owner.
//
// ============================================================

stock CRP_AdminDutyOn(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(gPlayerAdminDuty[playerid])
    {
        return 1;
    }

    gPlayerAdminDuty[playerid] = true;
    gPlayerAdminDutyStart[playerid] = gettime();

    return 1;
}


// ============================================================
// DUTY OFF
// ============================================================

stock CRP_AdminDutyOff(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(!gPlayerAdminDuty[playerid])
    {
        return 1;
    }

    gPlayerAdminDutyTotal[playerid] +=
        gettime() - gPlayerAdminDutyStart[playerid];

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;

    return 1;
}


// ============================================================
// ADMIN CHAT
// ============================================================
//
// Format:
//
// Developer Defender: message
// Senior Admin Username: message
//
// Account Username only.
// Character Name is never used.
//
// ============================================================

stock CRP_AdminSendChat(playerid, const message[])
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new rankname[ADMIN_RANKNAME_LENGTH];
    new output[192];

    CRP_GetAdminRankName(
        gPlayerAdminRank[playerid],
        rankname,
        sizeof(rankname)
    );

    format(
        output,
        sizeof(output),
        "{FF6666}%s {FF4444}%s:{FFFFFF} %s",
        rankname,
        gPlayerAccountUsername[playerid],
        message
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        SendClientMessage(i, COLOR_WHITE, output);
    }

    return 1;
}


// ============================================================
// MAIN PANEL
// ============================================================

stock CRP_AdminShowMainPanel(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    format(
        list,
        sizeof(list),
        "Admin List\n\
        Admin Duty\n\
        Admins\n\
        Logs\n\
        Reports"
    );

    // Rank 9 / 10 only.
    if(CRP_AdminCanAccessAdminSettings(playerid))
    {
        strcat(
            list,
            "\nAdmin Settings"
        );
    }

    // Rank 9 / 10 only.
    if(CRP_AdminCanAccessMoneySettings(playerid))
    {
        strcat(
            list,
            "\nMoney Settings"
        );
    }

    // Rank 9 / 10 only.
    if(CRP_AdminCanAccessAdminDivision(playerid))
    {
        strcat(
            list,
            "\nAdmin Division"
        );
    }

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_MAIN;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_MAIN,
        DIALOG_STYLE_LIST,
        "ADMIN PANEL",
        list,
        "PILIH",
        "TUTUP"
    );

    return 1;
}


// ============================================================
// ADMIN LIST PANEL
// ============================================================

stock CRP_AdminShowList(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    CRP_AdminBuildList(
        list,
        sizeof(list)
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_LIST;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        "ADMIN LIST",
        list,
        "TUTUP",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// DUTY ONLINE
// ============================================================

stock CRP_AdminShowDuty(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    format(
        list,
        sizeof(list),
        "Account Username\tDuty Time\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        if(!gPlayerAdminDuty[i])
        {
            continue;
        }

        new seconds = CRP_AdminGetDutySeconds(i);
        new hours = seconds / 3600;
        new minutes = (seconds % 3600) / 60;

        new line[96];

        format(
            line,
            sizeof(line),
            "%s\t%02d:%02d\n",
            gPlayerAccountUsername[i],
            hours,
            minutes
        );

        strcat(list, line);
    }

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_DUTY;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_DUTY,
        DIALOG_STYLE_TABLIST_HEADERS,
        "DUTY ONLINE",
        list,
        "TUTUP",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ADMINS
// ============================================================

stock CRP_AdminShowAdmins(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    format(
        list,
        sizeof(list),
        "Rank\tAccount Username\tStatus\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        new rankname[ADMIN_RANKNAME_LENGTH];
        new status[16];
        new line[128];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        if(gPlayerAdminDuty[i])
        {
            format(status, sizeof(status), "ON DUTY");
        }
        else
        {
            format(status, sizeof(status), "OFF DUTY");
        }

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\n",
            rankname,
            gPlayerAccountUsername[i],
            status
        );

        strcat(list, line);
    }

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ADMINS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ADMINS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "ADMINS",
        list,
        "TUTUP",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// LOGS MAIN
// ============================================================

stock CRP_AdminShowLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[1024];

    format(
        list,
        sizeof(list),
        "Ban\n\
        Kick\n\
        Jail\n\
        Warning\n\
        Mute\n\
        Reports\n\
        Faction and Families"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_LOGS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_LOGS,
        DIALOG_STYLE_LIST,
        "ADMIN LOGS",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// REPORT LOG ACCESS
// ============================================================

stock CRP_AdminShowReportLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    // Report persistence is owned by crp_admin_logs.pwn.
    // This panel only routes the UI request.

    CallRemoteFunction(
        "CRP_AdminLogsOpenReportLogs",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// FACTION AND FAMILIES LOG MENU
// ============================================================

stock CRP_AdminShowFactionFamilyLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    // Rank 9 / 10 may access.
    // Assigned handlers may access relevant logs.

    if(
        gPlayerAdminRank[playerid] < ADMIN_SERVER_DIRECTOR &&
        !CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "Admin: Anda tidak memiliki akses ke Faction and Families Logs."
        );

        return 0;
    }

    new list[256];

    format(
        list,
        sizeof(list),
        "Faction\n\
        Families"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_LOG_FACTION;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_LOG_FACTION,
        DIALOG_STYLE_LIST,
        "FACTION AND FAMILIES",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ADMIN SETTINGS
// ============================================================

stock CRP_AdminShowAdminSettings(playerid)
{
    if(!CRP_AdminCanAccessAdminSettings(playerid))
    {
        return 0;
    }

    new list[1024];

    format(
        list,
        sizeof(list),
        "Admin\n\
        Helper Staff\n\
        Intern Staff"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ADMIN_SETTINGS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_SETTINGS,
        DIALOG_STYLE_LIST,
        "ADMIN SETTINGS",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// MONEY SETTINGS
// ============================================================

stock CRP_AdminShowMoneySettings(playerid)
{
    if(!CRP_AdminCanAccessMoneySettings(playerid))
    {
        return 0;
    }

    new list[512];

    format(
        list,
        sizeof(list),
        "Set Cash\n\
        Give Money\n\
        Money For All"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_MONEY_SETTINGS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_MONEY_SETTINGS,
        DIALOG_STYLE_LIST,
        "MONEY SETTINGS",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ADMIN DIVISION
// ============================================================

stock CRP_AdminShowAdminDivision(playerid)
{
    if(!CRP_AdminCanAccessAdminDivision(playerid))
    {
        return 0;
    }

    new list[512];

    format(
        list,
        sizeof(list),
        "Factions and Families\n\
        Houses and Business"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ADMIN_DIVISION;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_DIVISION,
        DIALOG_STYLE_LIST,
        "ADMIN DIVISION",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// FACTIONS AND FAMILIES DIVISION
// ============================================================

stock CRP_AdminShowFaction(playerid)
{
    if(!CRP_AdminCanAccessAdminDivision(playerid))
    {
        return 0;
    }

    new list[512];

    format(
        list,
        sizeof(list),
        "Factions and Families\n\
        Choose Admin Handler\n\
        Handler List"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_FACTION;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_FACTION,
        DIALOG_STYLE_LIST,
        "FACTIONS AND FAMILIES",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// HOUSES AND BUSINESS DIVISION
// ============================================================

stock CRP_AdminShowHouseBusiness(playerid)
{
    if(!CRP_AdminCanAccessAdminDivision(playerid))
    {
        return 0;
    }

    new list[512];

    format(
        list,
        sizeof(list),
        "Houses and Business\n\
        Choose Admin Handler\n\
        Handler List"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_HOUSE_BUSINESS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_HOUSE_BUSINESS,
        DIALOG_STYLE_LIST,
        "HOUSES AND BUSINESS",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// FACTION MENU
// ============================================================
//
// IN / OUT is for the handler themselves.
//
// A handler can only be IN one faction at a time.
//
// ============================================================

stock CRP_AdminShowFactionList(playerid)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid))
        {
            return 0;
        }
    }

    new list[512];

    format(
        list,
        sizeof(list),
        "LSPD\n\
        LSMD\n\
        LAN\n\
        GOV"
    );

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_FACTION,
        DIALOG_STYLE_LIST,
        "FACTION",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// FAMILY MENU
// ============================================================

stock CRP_AdminShowFamilyList(playerid)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid))
        {
            return 0;
        }
    }

    new list[2048];

    format(
        list,
        sizeof(list),
        "Family Slot 1\n\
        Family Slot 2\n\
        Family Slot 3\n\
        Family Slot 4\n\
        Family Slot 5\n\
        Family Slot 6\n\
        Family Slot 7\n\
        Family Slot 8\n\
        Family Slot 9\n\
        Family Slot 10"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_FAMILIES;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_FAMILIES,
        DIALOG_STYLE_LIST,
        "FAMILIES",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// HANDLER LIST
// ============================================================

stock CRP_AdminShowHandlerList(playerid, division)
{
    if(!CRP_AdminCanAccessAdminDivision(playerid))
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    format(
        list,
        sizeof(list),
        "Handler\tDivision\n"
    );

    if(division == ADMIN_DIVISION_FACTION_FAMILY)
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!CRP_AdminIsValidPlayer(i))
            {
                continue;
            }

            if(!gFactionFamilyHandler[i])
            {
                continue;
            }

            new line[128];

            format(
                line,
                sizeof(line),
                "%s\tFaction & Families\n",
                gPlayerAccountUsername[i]
            );

            strcat(list, line);
        }
    }
    else if(division == ADMIN_DIVISION_HOUSE_BUSINESS)
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!CRP_AdminIsValidPlayer(i))
            {
                continue;
            }

            if(!gHouseBusinessHandler[i])
            {
                continue;
            }

            new line[128];

            format(
                line,
                sizeof(line),
                "%s\tHouses & Business\n",
                gPlayerAccountUsername[i]
            );

            strcat(list, line);
        }
    }

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ADMIN_DIVISION;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_HANDLER_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        "HANDLER LIST",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// HANDLER ASSIGNMENT VALIDATION
// ============================================================

stock CRP_AdminCanAssignHandler(actorid, targetid)
{
    if(!CRP_AdminCanAccessAdminDivision(actorid))
    {
        return 0;
    }

    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(!CRP_AdminCanBecomeHandler(targetid))
    {
        return 0;
    }

    if(!CRP_AdminCanTarget(actorid, targetid))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// ASSIGN FACTION/FAMILY HANDLER
// ============================================================

stock CRP_AdminSetFactionFamilyHandler(targetid, state)
{
    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(state)
    {
        if(!CRP_AdminCanBecomeHandler(targetid))
        {
            return 0;
        }

        gFactionFamilyHandler[targetid] = 1;
    }
    else
    {
        gFactionFamilyHandler[targetid] = 0;

        // Leaving handler role also removes active faction/family.
        gPlayerActiveFaction[targetid] = ADMIN_FACTION_NONE;
        gPlayerActiveFamily[targetid] = ADMIN_FAMILY_NONE;
    }

    return 1;
}


// ============================================================
// ASSIGN HOUSE/BUSINESS HANDLER
// ============================================================

stock CRP_AdminSetHouseBusinessHandler(targetid, state)
{
    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(state)
    {
        if(!CRP_AdminCanBecomeHandler(targetid))
        {
            return 0;
        }

        gHouseBusinessHandler[targetid] = 1;
    }
    else
    {
        gHouseBusinessHandler[targetid] = 0;
    }

    return 1;
}


// ============================================================
// FACTION IN
// ============================================================
//
// Handler enters faction at Rank 10.
// Default faction rank name:
// Police Admin / Medical Admin / Legal Admin / Government Admin
//
// Only one faction at a time.
//
// ============================================================

stock CRP_AdminFactionIn(playerid, faction)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        return 0;
    }

    if(faction < ADMIN_FACTION_LSPD ||
       faction > ADMIN_FACTION_GOV)
    {
        return 0;
    }

    if(
        gPlayerActiveFaction[playerid] != ADMIN_FACTION_NONE &&
        gPlayerActiveFaction[playerid] != faction
    )
    {
        return 0;
    }

    // Cannot simultaneously be active in a family.
    gPlayerActiveFamily[playerid] = ADMIN_FAMILY_NONE;

    gPlayerActiveFaction[playerid] = faction;

    return 1;
}


// ============================================================
// FACTION OUT
// ============================================================

stock CRP_AdminFactionOut(playerid)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        return 0;
    }

    gPlayerActiveFaction[playerid] = ADMIN_FACTION_NONE;

    return 1;
}


// ============================================================
// FAMILY IN
// ============================================================
//
// Family rank:
// Level 10
//
// Rank name:
// Admin:
//
// Only one family at a time.
//
// ============================================================

stock CRP_AdminFamilyIn(playerid, family)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        return 0;
    }

    if(family < ADMIN_FAMILY_SLOT_1 ||
       family > ADMIN_FAMILY_SLOT_10)
    {
        return 0;
    }

    if(
        gPlayerActiveFamily[playerid] != ADMIN_FAMILY_NONE &&
        gPlayerActiveFamily[playerid] != family
    )
    {
        return 0;
    }

    // Cannot simultaneously be active in a faction.
    gPlayerActiveFaction[playerid] = ADMIN_FACTION_NONE;

    gPlayerActiveFamily[playerid] = family;

    return 1;
}


// ============================================================
// FAMILY OUT
// ============================================================

stock CRP_AdminFamilyOut(playerid)
{
    if(!CRP_AdminIsFactionFamilyHandler(playerid))
    {
        return 0;
    }

    gPlayerActiveFamily[playerid] = ADMIN_FAMILY_NONE;

    return 1;
}


// ============================================================
// REMOTE FUNCTION:
// GET RANK
// ============================================================

public CRP_AdminGetRank(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_NO_STAFF;
    }

    return gPlayerAdminRank[playerid];
}


// ============================================================
// REMOTE FUNCTION:
// IS STAFF
// ============================================================

public CRP_AdminIsStaffRemote(playerid)
{
    return CRP_AdminIsStaff(playerid);
}


// ============================================================
// REMOTE FUNCTION:
// IS DEVELOPER
// ============================================================

public CRP_AdminIsDeveloperRemote(playerid)
{
    return CRP_AdminIsDeveloper(playerid);
}


// ============================================================
// REMOTE FUNCTION:
// TARGET VALIDATION
// ============================================================

public CRP_AdminCanTargetRemote(actorid, targetid)
{
    return CRP_AdminCanTarget(
        actorid,
        targetid
    );
}


// ============================================================
// REMOTE FUNCTION:
// GET DIVISION
// ============================================================

public CRP_AdminGetDivision(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_DIVISION_NONE;
    }

    if(gFactionFamilyHandler[playerid])
    {
        return ADMIN_DIVISION_FACTION_FAMILY;
    }

    if(gHouseBusinessHandler[playerid])
    {
        return ADMIN_DIVISION_HOUSE_BUSINESS;
    }

    return ADMIN_DIVISION_NONE;
}


// ============================================================
// REMOTE FUNCTION:
// GET ACTIVE FACTION
// ============================================================

public CRP_AdminGetFaction(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_FACTION_NONE;
    }

    return gPlayerActiveFaction[playerid];
}


// ============================================================
// REMOTE FUNCTION:
// GET ACTIVE FAMILY
// ============================================================

public CRP_AdminGetFamily(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_FAMILY_NONE;
    }

    return gPlayerActiveFamily[playerid];
}


// ============================================================
// REMOTE FUNCTION:
// GET HANDLER TYPE
// ============================================================

public CRP_AdminGetHandlerType(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_HANDLER_NONE;
    }

    if(gFactionFamilyHandler[playerid])
    {
        return ADMIN_HANDLER_FACTION;
    }

    if(gHouseBusinessHandler[playerid])
    {
        return ADMIN_HANDLER_HOUSE;
    }

    return ADMIN_HANDLER_NONE;
}


// ============================================================
// REMOTE FUNCTION:
// GET ACCOUNT USERNAME
// ============================================================

public CRP_AdminGetAccountUsername(
    playerid,
    output[],
    size
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        output[0] = EOS;
        return 0;
    }

    format(
        output,
        size,
        "%s",
        gPlayerAccountUsername[playerid]
    );

    return 1;
}


// ============================================================
// REMOTE FUNCTION:
// SET RANK
// ============================================================
//
// Rank 10 is intentionally blocked here.
// Developer must only be set internally.
//
// ============================================================

public CRP_AdminSetRankRemote(playerid, rank)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(rank < ADMIN_NO_STAFF || rank >= ADMIN_DEVELOPER)
    {
        return 0;
    }

    gPlayerAdminRank[playerid] = rank;

    return 1;
}


// ============================================================
// REMOTE FUNCTION:
// SET FACTION
// ============================================================

public CRP_AdminSetFactionRemote(playerid, faction)
{
    return CRP_AdminFactionIn(
        playerid,
        faction
    );
}


// ============================================================
// REMOTE FUNCTION:
// SET FAMILY
// ============================================================

public CRP_AdminSetFamilyRemote(playerid, family)
{
    return CRP_AdminFamilyIn(
        playerid,
        family
    );
}


// ============================================================
// DIALOG RESPONSE
// ============================================================

public OnDialogResponse(
    playerid,
    dialogid,
    response,
    listitem,
    inputtext[]
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(!response)
    {
        // Main panel closed.
        if(dialogid == DIALOG_ADMIN_MAIN)
        {
            gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;
            return 1;
        }

        // Return to main panel for navigation dialogs.
        if(
            dialogid == DIALOG_ADMIN_LIST ||
            dialogid == DIALOG_ADMIN_DUTY ||
            dialogid == DIALOG_ADMIN_ADMINS ||
            dialogid == DIALOG_ADMIN_LOGS ||
            dialogid == DIALOG_ADMIN_REPORTS ||
            dialogid == DIALOG_ADMIN_SETTINGS ||
            dialogid == DIALOG_ADMIN_MONEY_SETTINGS ||
            dialogid == DIALOG_ADMIN_DIVISION ||
            dialogid == DIALOG_ADMIN_FACTION ||
            dialogid == DIALOG_ADMIN_FAMILIES ||
            dialogid == DIALOG_ADMIN_HOUSE_BUSINESS
        )
        {
            CRP_AdminShowMainPanel(playerid);
            return 1;
        }

        return 0;
    }


    // ========================================================
    // MAIN PANEL
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MAIN)
    {
        switch(listitem)
        {
            case 0:
            {
                CRP_AdminShowList(playerid);
            }

            case 1:
            {
                CRP_AdminShowDuty(playerid);
            }

            case 2:
            {
                CRP_AdminShowAdmins(playerid);
            }

            case 3:
            {
                CRP_AdminShowLogs(playerid);
            }

            case 4:
            {
                // Reports.
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenReports",
                    "i",
                    playerid
                );
            }

            case 5:
            {
                if(CRP_AdminCanAccessAdminSettings(playerid))
                {
                    CRP_AdminShowAdminSettings(playerid);
                }
                else if(CRP_AdminCanAccessMoneySettings(playerid))
                {
                    CRP_AdminShowMoneySettings(playerid);
                }
                else if(CRP_AdminCanAccessAdminDivision(playerid))
                {
                    CRP_AdminShowAdminDivision(playerid);
                }
            }

            case 6:
            {
                if(CRP_AdminCanAccessMoneySettings(playerid))
                {
                    CRP_AdminShowMoneySettings(playerid);
                }
                else if(CRP_AdminCanAccessAdminDivision(playerid))
                {
                    CRP_AdminShowAdminDivision(playerid);
                }
            }

            case 7:
            {
                if(CRP_AdminCanAccessAdminDivision(playerid))
                {
                    CRP_AdminShowAdminDivision(playerid);
                }
            }
        }

        return 1;
    }


    // ========================================================
    // LOGS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_LOGS)
    {
        switch(listitem)
        {
            case 0:
            {
                CallRemoteFunction(
                    "CRP_AdminLogsOpenCategory",
                    "ii",
                    playerid,
                    ADMIN_LOG_BAN
                );
            }

            case 1:
            {
                CallRemoteFunction(
                    "CRP_AdminLogsOpenCategory",
                    "ii",
                    playerid,
                    ADMIN_LOG_KICK
                );
            }

            case 2:
            {
                CallRemoteFunction(
                    "CRP_AdminLogsOpenCategory",
                    "ii",
                    playerid,
                    ADMIN_LOG_JAIL
                );
            }

            case 3:
            {
                CallRemoteFunction(
                    "CRP_AdminLogsOpenCategory",
                    "ii",
                    playerid,
                    ADMIN_LOG_WARNING
                );
            }

            case 4:
            {
                CallRemoteFunction(
                    "CRP_AdminLogsOpenCategory",
                    "ii",
                    playerid,
                    ADMIN_LOG_MUTE
                );
            }

            case 5:
            {
                CRP_AdminShowReportLogs(playerid);
            }

            case 6:
            {
                CRP_AdminShowFactionFamilyLogs(playerid);
            }
        }

        return 1;
    }


    // ========================================================
    // FACTION / FAMILY LOGS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_LOG_FACTION)
    {
        if(listitem == 0)
        {
            CallRemoteFunction(
                "CRP_AdminLogsOpenFactionLogs",
                "i",
                playerid
            );

            return 1;
        }

        if(listitem == 1)
        {
            CallRemoteFunction(
                "CRP_AdminLogsOpenFamilyLogs",
                "i",
                playerid
            );

            return 1;
        }

        return 1;
    }


    // ========================================================
    // ADMIN SETTINGS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_SETTINGS)
    {
        if(!CRP_AdminCanAccessAdminSettings(playerid))
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                // Admin
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenAdminPromotion",
                    "i",
                    playerid
                );
            }

            case 1:
            {
                // Helper Staff
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenHelperPromotion",
                    "i",
                    playerid
                );
            }

            case 2:
            {
                // Intern Staff
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenInternSettings",
                    "i",
                    playerid
                );
            }
        }

        return 1;
    }


    // ========================================================
    // MONEY SETTINGS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MONEY_SETTINGS)
    {
        if(!CRP_AdminCanAccessMoneySettings(playerid))
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenSetCash",
                    "i",
                    playerid
                );
            }

            case 1:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenGiveMoney",
                    "i",
                    playerid
                );
            }

            case 2:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenMoneyForAll",
                    "i",
                    playerid
                );
            }
        }

        return 1;
    }


    // ========================================================
    // ADMIN DIVISION
    // ========================================================

    if(dialogid == DIALOG_ADMIN_DIVISION)
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid))
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CRP_AdminShowFaction(playerid);
            }

            case 1:
            {
                CRP_AdminShowHouseBusiness(playerid);
            }
        }

        return 1;
    }


    // ========================================================
    // FACTIONS AND FAMILIES
    // ========================================================

    if(dialogid == DIALOG_ADMIN_FACTION)
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid) &&
           !CRP_AdminIsFactionFamilyHandler(playerid))
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                // Factions
                CRP_AdminShowFactionList(playerid);
            }

            case 1:
            {
                // Choose Handler
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenFactionHandler",
                    "i",
                    playerid
                );
            }

            case 2:
            {
                // Handler List
                CRP_AdminShowHandlerList(
                    playerid,
                    ADMIN_DIVISION_FACTION_FAMILY
                );
            }
        }

        return 1;
    }


    // ========================================================
    // FAMILIES
    // ========================================================

    if(dialogid == DIALOG_ADMIN_FAMILIES)
    {
        if(
            !CRP_AdminIsFactionFamilyHandler(playerid) &&
            !CRP_AdminCanAccessAdminDivision(playerid)
        )
        {
            return 1;
        }

        // Family slot selection.
        if(listitem >= 0 && listitem <= 9)
        {
            gSelectedFamily[playerid] = listitem + 1;

            CallRemoteFunction(
                "CRP_AdminCommandsOpenFamilyAction",
                "ii",
                playerid,
                gSelectedFamily[playerid]
            );

            return 1;
        }

        return 1;
    }


    // ========================================================
    // HOUSES AND BUSINESS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_HOUSE_BUSINESS)
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid))
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenHouseBusinessHandler",
                    "i",
                    playerid
                );
            }

            case 1:
            {
                CRP_AdminShowHandlerList(
                    playerid,
                    ADMIN_DIVISION_HOUSE_BUSINESS
                );
            }

            case 2:
            {
                // Reserved for future House/Business submenu.
                // No implementation added yet.
                SendClientMessage(
                    playerid,
                    COLOR_GREY,
                    "Admin Division: Houses and Business sedang disiapkan."
                );
            }
        }

        return 1;
    }


    // ========================================================
    // HANDLER LIST
    // ========================================================

    if(dialogid == DIALOG_ADMIN_HANDLER_LIST)
    {
        if(!CRP_AdminCanAccessAdminDivision(playerid))
        {
            return 1;
        }

        // Selection will be resolved by crp_admin_cmd.pwn.
        gSelectedHandlerTarget[playerid] = listitem;

        CallRemoteFunction(
            "CRP_AdminCommandsHandleHandlerSelection",
            "ii",
            playerid,
            listitem
        );

        return 1;
    }


    return 0;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    gPlayerAdminRank[playerid] = ADMIN_NO_STAFF;

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;
    gPlayerAdminDutyTotal[playerid] = 0;

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;

    gFactionFamilyHandler[playerid] = 0;
    gHouseBusinessHandler[playerid] = 0;

    gPlayerActiveFaction[playerid] = ADMIN_FACTION_NONE;
    gPlayerActiveFamily[playerid] = ADMIN_FAMILY_NONE;

    gSelectedAdminTarget[playerid] = INVALID_PLAYER_ID;
    gSelectedHandlerTarget[playerid] = INVALID_PLAYER_ID;

    gSelectedFaction[playerid] = ADMIN_FACTION_NONE;
    gSelectedFamily[playerid] = ADMIN_FAMILY_NONE;

    CRP_AdminLoadAccountIdentity(playerid);

    return 1;
}


// ============================================================
// PLAYER DISCONNECT
// ============================================================

public OnPlayerDisconnect(playerid, reason)
{
    gPlayerAdminRank[playerid] = ADMIN_NO_STAFF;

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;
    gPlayerAdminDutyTotal[playerid] = 0;

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;

    gFactionFamilyHandler[playerid] = 0;
    gHouseBusinessHandler[playerid] = 0;

    gPlayerActiveFaction[playerid] = ADMIN_FACTION_NONE;
    gPlayerActiveFamily[playerid] = ADMIN_FAMILY_NONE;

    gSelectedAdminTarget[playerid] = INVALID_PLAYER_ID;
    gSelectedHandlerTarget[playerid] = INVALID_PLAYER_ID;

    gSelectedFaction[playerid] = ADMIN_FACTION_NONE;
    gSelectedFamily[playerid] = ADMIN_FAMILY_NONE;

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("--------------------------------------------------");
    print("Crystal Roleplay Admin Panel v3.0");
    print("Admin Panel System loaded.");
    print("Command system : crp_admin_cmd.pwn");
    print("Log system     : crp_admin_logs.pwn");
    print("Archives       : REMOVED");
    print("Admin Division : ENABLED");
    print("--------------------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    return 1;
}


// ============================================================
// REMOTE PANEL OPEN
// ============================================================

public CRP_AdminOpenPanel(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    return CRP_AdminShowMainPanel(playerid);
}


// ============================================================
// OPTIONAL DIRECT PUBLIC HELPERS
// ============================================================
//
// These are intentionally public so other filterscripts can
// access the Admin Panel system using CallRemoteFunction.
//
// Example:
//
// CallRemoteFunction(
//     "CRP_AdminOpenPanel",
//     "i",
//     playerid
// );
//
// ============================================================


// ============================================================
// END OF FILE
// ============================================================