#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Panel System v3.2
//
// File      : filterscripts/features/crp_admin.pwn
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fokus v3.2:
// - Admin Panel Foundation
// - Account Username Identity
// - RankName + Account Username Admin Identity
// - Admin Duty Foundation
// - Admin List
// - Duty Online
// - Admins
// - My Bans
// - Character Ban Management
// - UCP Ban / Block Management
// - Logs
// - Ban / Kick / Jail / Warning / Mute / Reports
// - Faction and Families Logs
// - Admin Settings
// - Money Settings
// - Admin Division
// - Faction Handler
// - Families Handler
// - Houses & Business Handler
// - Account-based Handler Assignment
// - Developer Protection
// - Hierarchy Protection
// - Handler Access Protection
// - RemoteFunction Bridge
//
// ASK SYSTEM v3.2:
// - ASK Queue
// - Permanent Queue ID
// - ASK Logs
// - ANSWERED Logs
// - EXPIRED Logs
// - 10 Minute Queue Expiration
// - AskBot Similar Question Foundation
// - AskBot reads ANSWERED ASK Logs only
// - Admin /asks Bridge
// - Player /ask Bridge
//
// IMPORTANT:
// Admin Rank is ACCOUNT based.
// Admin Rank is NOT Character based.
//
// IMPORTANT:
// Command implementation belongs to:
// filterscripts/features/crp_admin_cmd.pwn
//
// IMPORTANT:
// Player /ask command will later belong to:
// filterscripts/features/crp_basic_player_cmd.pwn
//
// ASK data is intentionally stored in THIS FILE.
// There is NO crp_admin_logs.pwn.
//
// No Archives.
// No Archived Reports.
// No command implementation in this file.
// ============================================================


// ============================================================
// INTERNAL CONFIGURATION
// ============================================================

#define ADMIN_USERNAME_LENGTH       25
#define ADMIN_RANKNAME_LENGTH       32
#define ADMIN_DIALOG_SIZE           4096
#define ADMIN_HANDLER_MAX            10

#define ASK_MATCH_MAX_RESULTS        20


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
#define ADMIN_PANEL_MY_BANS         5
#define ADMIN_PANEL_LOGS            6
#define ADMIN_PANEL_REPORTS         7
#define ADMIN_PANEL_ADMIN_SETTINGS  8
#define ADMIN_PANEL_MONEY_SETTINGS 9
#define ADMIN_PANEL_ADMIN_DIVISION  10
#define ADMIN_PANEL_FACTION_DIV     11
#define ADMIN_PANEL_FAMILIES        12
#define ADMIN_PANEL_HOUSE_BUSINESS  13
#define ADMIN_PANEL_LOG_FACTION     14
#define ADMIN_PANEL_LOG_FAMILIES    15
#define ADMIN_PANEL_FACTION_LIST    16
#define ADMIN_PANEL_HANDLER_LIST    17
#define ADMIN_PANEL_HANDLER_CONFIRM 18
#define ADMIN_PANEL_ASKS            19
#define ADMIN_PANEL_ASK_DETAIL      20
#define ADMIN_PANEL_ASK_LOGS        21
#define ADMIN_PANEL_ASK_BOT          22
#define ADMIN_PANEL_ASK_BOT_DETAIL  23


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
// MY BANS TYPE
// ============================================================

#define ADMIN_MY_BANS_CHARACTER     1
#define ADMIN_MY_BANS_UCP           2


// ============================================================
// MY BANS ACTION
// ============================================================

#define ADMIN_BAN_ACTION_NONE       0
#define ADMIN_BAN_ACTION_UNBAN      1
#define ADMIN_BAN_ACTION_UNBLOCK    2


// ============================================================
// ASK SYSTEM
// ============================================================

#define ASK_STATUS_NONE             0
#define ASK_STATUS_ACTIVE           1
#define ASK_STATUS_ANSWERED         2
#define ASK_STATUS_EXPIRED          3

#define ASK_MAX_QUEUE               100
#define ASK_MAX_LOG                 500

#define ASK_QUESTION_LENGTH         192
#define ASK_ANSWER_LENGTH           192
#define ASK_USERNAME_LENGTH         25

#define ASK_QUEUE_TIMEOUT           600

#define ASK_STORAGE_DIRECTORY       "scriptfiles/crp_ask"
#define ASK_QUEUE_FILE              "scriptfiles/crp_ask/queue.txt"
#define ASK_LOG_FILE                "scriptfiles/crp_ask/logs.txt"
#define ASK_COUNTER_FILE            "scriptfiles/crp_ask/counter.txt"

#define ASK_MATCH_MIN_WORDS         2

#define ASK_SCORE_NONE              0
#define ASK_SCORE_LOW               1
#define ASK_SCORE_MEDIUM            2
#define ASK_SCORE_HIGH              3


// ============================================================
// ASK DIALOG IDS
// ============================================================

#define DIALOG_ADMIN_ASKS           3060
#define DIALOG_ADMIN_ASK_DETAIL     3061
#define DIALOG_ADMIN_ASK_ANSWER     3062
#define DIALOG_ADMIN_ASK_LOGS       3063
#define DIALOG_ADMIN_ASK_LOG_DETAIL 3064


// ============================================================
// DIALOG IDS
// ============================================================

#define DIALOG_ADMIN_MAIN                  3000
#define DIALOG_ADMIN_LIST                  3001
#define DIALOG_ADMIN_DUTY                  3002
#define DIALOG_ADMIN_ADMINS                3003
#define DIALOG_ADMIN_MY_BANS               3004
#define DIALOG_ADMIN_LOGS                  3005
#define DIALOG_ADMIN_REPORTS               3006

#define DIALOG_ADMIN_SETTINGS              3010
#define DIALOG_ADMIN_MONEY_SETTINGS        3011
#define DIALOG_ADMIN_DIVISION              3012

#define DIALOG_ADMIN_FACTION_DIV           3020
#define DIALOG_ADMIN_FAMILIES              3021
#define DIALOG_ADMIN_HOUSE_BUSINESS        3022
#define DIALOG_ADMIN_FACTION_LIST          3023

#define DIALOG_ADMIN_LOG_FACTION           3030
#define DIALOG_ADMIN_LOG_FAMILIES          3031

#define DIALOG_ADMIN_HANDLER_LIST          3040
#define DIALOG_ADMIN_HANDLER_CONFIRM       3041

#define DIALOG_ADMIN_MY_BANS_CHARACTER     3050
#define DIALOG_ADMIN_MY_BANS_UCP           3051
#define DIALOG_ADMIN_MY_BANS_ACTION        3052
#define DIALOG_ADMIN_MY_BANS_CONFIRM       3053


// ============================================================
// ASK RUNTIME QUEUE
// ============================================================

new gAskQueueID[ASK_MAX_QUEUE];
new gAskQueueStatus[ASK_MAX_QUEUE];
new gAskQueueCreated[ASK_MAX_QUEUE];
new gAskQueuePlayerID[ASK_MAX_QUEUE];

new gAskQueueRequester[ASK_MAX_QUEUE][ASK_USERNAME_LENGTH];
new gAskQueueAccount[ASK_MAX_QUEUE][ASK_USERNAME_LENGTH];
new gAskQueueQuestion[ASK_MAX_QUEUE][ASK_QUESTION_LENGTH];

new gAskQueueCount;
new gAskNextQueueID;


// ============================================================
// ASK LOG DATA
// ============================================================

new gAskLogID[ASK_MAX_LOG];
new gAskLogStatus[ASK_MAX_LOG];
new gAskLogCreated[ASK_MAX_LOG];
new gAskLogAnswered[ASK_MAX_LOG];

new gAskLogRequester[ASK_MAX_LOG][ASK_USERNAME_LENGTH];
new gAskLogAccount[ASK_MAX_LOG][ASK_USERNAME_LENGTH];

new gAskLogQuestion[ASK_MAX_LOG][ASK_QUESTION_LENGTH];
new gAskLogAnswer[ASK_MAX_LOG][ASK_ANSWER_LENGTH];

new gAskLogAdminRank[ASK_MAX_LOG][ADMIN_RANKNAME_LENGTH];
new gAskLogAdminUsername[ASK_MAX_LOG][ASK_USERNAME_LENGTH];

new gAskLogCount;


// ============================================================
// ASK UI CACHE
// ============================================================

new gSelectedAskQueue[MAX_PLAYERS];
new gSelectedAskLog[MAX_PLAYERS];


// ============================================================
// ASK MATCH CACHE
// ============================================================

new gAskMatchLogIndex[MAX_PLAYERS][ASK_MATCH_MAX_RESULTS];
new gAskMatchScore[MAX_PLAYERS][ASK_MATCH_MAX_RESULTS];
new gAskMatchCount[MAX_PLAYERS];


// ============================================================
// PLAYER ADMIN DATA
// ============================================================

new gPlayerAdminRank[MAX_PLAYERS];

new gPlayerAccountUsername[MAX_PLAYERS][ADMIN_USERNAME_LENGTH];

new bool:gPlayerAdminDuty[MAX_PLAYERS];
new gPlayerAdminDutyStart[MAX_PLAYERS];
new gPlayerAdminDutyTotal[MAX_PLAYERS];

new gPlayerAdminPanel[MAX_PLAYERS];


// ============================================================
// ACCOUNT-BASED HANDLER DATA
// ============================================================

new gFactionFamilyHandlerAccount[ADMIN_HANDLER_MAX][ADMIN_USERNAME_LENGTH];
new gHouseBusinessHandlerAccount[ADMIN_HANDLER_MAX][ADMIN_USERNAME_LENGTH];

new gFactionHandlerAccount[5][ADMIN_USERNAME_LENGTH];
new gFamilyHandlerAccount[11][ADMIN_USERNAME_LENGTH];

new gHouseHandlerAccount[ADMIN_USERNAME_LENGTH];
new gBusinessHandlerAccount[ADMIN_USERNAME_LENGTH];

new gPlayerActiveFaction[MAX_PLAYERS];
new gPlayerActiveFamily[MAX_PLAYERS];


// ============================================================
// PLAYER UI CACHE
// ============================================================

new gSelectedAdminTarget[MAX_PLAYERS];

new gSelectedHandlerTarget[MAX_PLAYERS];
new gSelectedHandlerDivision[MAX_PLAYERS];

new gSelectedFaction[MAX_PLAYERS];
new gSelectedFamily[MAX_PLAYERS];

new gSelectedMyBanType[MAX_PLAYERS];
new gSelectedMyBanAction[MAX_PLAYERS];


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
forward CRP_AdminIsOnDutyRemote(playerid);
forward CRP_AdminSetDutyRemote(playerid, duty_state);


// ============================================================
// ASK FORWARDS
// ============================================================

forward CRP_AskOpenAdminQueue(playerid);

forward CRP_AskCreateQueue(
    playerid,
    const requester[],
    const account[],
    const question[]
);

forward CRP_AskAnswerQueue(
    playerid,
    queueid,
    const answer[]
);

forward CRP_AskGetSimilarQuestions(
    playerid,
    const question[]
);

forward CRP_AskGetMatchCount(playerid);

forward CRP_AskGetMatchLog(
    playerid,
    match_index
);

forward CRP_AskGetLogQuestion(
    log_index,
    output[],
    size
);

forward CRP_AskGetLogAnswer(
    log_index,
    output[],
    size
);

forward CRP_AskGetLogRequester(
    log_index,
    output[],
    size
);

forward CRP_AskGetLogAdmin(
    log_index,
    output[],
    size
);

forward CRP_AskConfirmFallback(
    playerid,
    const requester[],
    const account[],
    const question[]
);

forward CRP_AskGetQueueIDForPlayer(playerid);

forward CRP_AskExpireQueues();


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

    if(CRP_AdminIsDeveloper(targetid))
    {
        return 0;
    }

    if(CRP_AdminIsDeveloper(actorid))
    {
        return 1;
    }

    if(gPlayerAdminRank[targetid] >= gPlayerAdminRank[actorid])
    {
        return 0;
    }

    return 1;
}


// ============================================================
// ADMIN SETTINGS ACCESS
// ============================================================

stock CRP_AdminCanAccessAdminSettings(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR;
}


// ============================================================
// MONEY SETTINGS ACCESS
// ============================================================

stock CRP_AdminCanAccessMoneySettings(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR;
}


// ============================================================
// ADMIN DIVISION ACCESS
// ============================================================

stock CRP_AdminCanAccessAdminDivision(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] >= ADMIN_SERVER_DIRECTOR;
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

    if(gPlayerAdminRank[playerid] < ADMIN_SUPERVISOR)
    {
        return 0;
    }

    if(CRP_AdminIsDeveloper(playerid))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// STRING ACCOUNT HELPER
// ============================================================

stock CRP_AdminIsAccountEmpty(const account[])
{
    return account[0] == EOS;
}


stock CRP_AdminFindOnlineAccount(const account[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!strcmp(
            gPlayerAccountUsername[i],
            account,
            true
        ))
        {
            return i;
        }
    }

    return INVALID_PLAYER_ID;
}


// ============================================================
// HANDLER ACCOUNT STORAGE HELPERS
// ============================================================

stock CRP_AdminSetHandlerAccount(
    division,
    slot,
    const account[]
)
{
    if(
        slot < 0 ||
        slot >= ADMIN_HANDLER_MAX
    )
    {
        return 0;
    }

    if(division == ADMIN_DIVISION_FACTION_FAMILY)
    {
        format(
            gFactionFamilyHandlerAccount[slot],
            ADMIN_USERNAME_LENGTH,
            "%s",
            account
        );

        return 1;
    }

    if(division == ADMIN_DIVISION_HOUSE_BUSINESS)
    {
        format(
            gHouseBusinessHandlerAccount[slot],
            ADMIN_USERNAME_LENGTH,
            "%s",
            account
        );

        return 1;
    }

    return 0;
}


stock CRP_AdminRemoveHandlerAccount(
    division,
    const account[]
)
{
    if(division == ADMIN_DIVISION_FACTION_FAMILY)
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(!strcmp(
                gFactionFamilyHandlerAccount[i],
                account,
                true
            ))
            {
                gFactionFamilyHandlerAccount[i][0] = EOS;
            }
        }

        return 1;
    }

    if(division == ADMIN_DIVISION_HOUSE_BUSINESS)
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(!strcmp(
                gHouseBusinessHandlerAccount[i],
                account,
                true
            ))
            {
                gHouseBusinessHandlerAccount[i][0] = EOS;
            }
        }

        return 1;
    }

    return 0;
}


stock CRP_AdminIsFactionFamilyHandler(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
    {
        if(!strcmp(
            gFactionFamilyHandlerAccount[i],
            gPlayerAccountUsername[playerid],
            true
        ))
        {
            return 1;
        }
    }

    return 0;
}


stock CRP_AdminIsHouseBusinessHandler(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
    {
        if(!strcmp(
            gHouseBusinessHandlerAccount[i],
            gPlayerAccountUsername[playerid],
            true
        ))
        {
            return 1;
        }
    }

    return 0;
}


// ============================================================
// HANDLER LIST COUNT
// ============================================================

stock CRP_AdminGetHandlerCount(division)
{
    new count = 0;

    if(division == ADMIN_DIVISION_FACTION_FAMILY)
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(!CRP_AdminIsAccountEmpty(
                gFactionFamilyHandlerAccount[i]
            ))
            {
                count++;
            }
        }
    }
    else if(division == ADMIN_DIVISION_HOUSE_BUSINESS)
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(!CRP_AdminIsAccountEmpty(
                gHouseBusinessHandlerAccount[i]
            ))
            {
                count++;
            }
        }
    }

    return count;
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
        total +=
            gettime() -
            gPlayerAdminDutyStart[playerid];
    }

    return total;
}


// ============================================================
// DUTY ON
// ============================================================

stock CRP_AdminDutyOn(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] < ADMIN_HELPER)
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

    if(gPlayerAdminRank[playerid] < ADMIN_HELPER)
    {
        return 0;
    }

    if(!gPlayerAdminDuty[playerid])
    {
        return 1;
    }

    gPlayerAdminDutyTotal[playerid] +=
        gettime() -
        gPlayerAdminDutyStart[playerid];

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;

    return 1;
}


// ============================================================
// ADMIN CHAT
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

        SendClientMessage(
            i,
            COLOR_WHITE,
            output
        );
    }

    return 1;
}


// ============================================================
// ASK STORAGE
// ============================================================

stock CRP_AskSanitize(
    const input[],
    output[],
    size
)
{
    new length = strlen(input);
    new position = 0;

    for(
        new i = 0;
        i < length &&
        position < size - 1;
        i++
    )
    {
        if(input[i] == '|')
        {
            output[position++] = '/';
        }
        else
        {
            output[position++] = input[i];
        }
    }

    output[position] = EOS;

    return 1;
}


// ============================================================
// ASK STORAGE INITIALIZATION
// ============================================================

stock CRP_AskEnsureStorage()
{
    new File:file;

    /*
     * The directory scriptfiles/crp_ask must exist on disk.
     * SA-MP's standard fopen does not create directories.
     */

    file = fopen(
        ASK_COUNTER_FILE,
        io_read
    );

    if(file)
    {
        fclose(file);
        return 1;
    }

    file = fopen(
        ASK_COUNTER_FILE,
        io_write
    );

    if(file)
    {
        fwrite(file, "0");
        fclose(file);
    }

    return 1;
}


// ============================================================
// ASK COUNTER LOAD
// ============================================================

stock CRP_AskLoadCounter()
{
    new File:file = fopen(
        ASK_COUNTER_FILE,
        io_read
    );

    if(!file)
    {
        gAskNextQueueID = 1;
        return 1;
    }

    new line[32];

    if(fread(file, line))
    {
        gAskNextQueueID =
            strval(line) + 1;
    }
    else
    {
        gAskNextQueueID = 1;
    }

    fclose(file);

    if(gAskNextQueueID < 1)
    {
        gAskNextQueueID = 1;
    }

    return 1;
}


// ============================================================
// ASK COUNTER SAVE
// ============================================================

stock CRP_AskSaveCounter()
{
    new File:file = fopen(
        ASK_COUNTER_FILE,
        io_write
    );

    if(!file)
    {
        return 0;
    }

    new line[32];

    format(
        line,
        sizeof(line),
        "%d",
        gAskNextQueueID - 1
    );

    fwrite(file, line);
    fclose(file);

    return 1;
}


// ============================================================
// ASK LOG SAVE
// ============================================================

stock CRP_AskSaveLog(index)
{
    if(
        index < 0 ||
        index >= ASK_MAX_LOG
    )
    {
        return 0;
    }

    new File:file = fopen(
        ASK_LOG_FILE,
        io_append
    );

    if(!file)
    {
        return 0;
    }

    new line[1024];

    format(
        line,
        sizeof(line),
        "%d|%d|%d|%d|%s|%s|%s|%s|%s|%s",
        gAskLogID[index],
        gAskLogStatus[index],
        gAskLogCreated[index],
        gAskLogAnswered[index],
        gAskLogRequester[index],
        gAskLogAccount[index],
        gAskLogQuestion[index],
        gAskLogAnswer[index],
        gAskLogAdminRank[index],
        gAskLogAdminUsername[index]
    );

    fwrite(file, line);
    fclose(file);

    return 1;
}


// ============================================================
// ASK LOG LOAD
// ============================================================

stock CRP_AskLoadLogs()
{
    gAskLogCount = 0;

    new File:file = fopen(
        ASK_LOG_FILE,
        io_read
    );

    if(!file)
    {
        return 1;
    }

    new line[1024];

    while(fread(file, line))
    {
        if(gAskLogCount >= ASK_MAX_LOG)
        {
            break;
        }

        new fields[10][256];
        new field = 0;
        new start = 0;
        new length = strlen(line);

        for(new i = 0; i <= length; i++)
        {
            if(
                line[i] == '|' ||
                line[i] == EOS
            )
            {
                if(field < 10)
                {
                    new count = i - start;

                    if(count >= 255)
                    {
                        count = 255;
                    }

                    strmid(
                        fields[field],
                        line,
                        start,
                        i,
                        256
                    );

                    fields[field][count] = EOS;
                    field++;
                }

                start = i + 1;
            }
        }

        if(field < 10)
        {
            continue;
        }

        new index = gAskLogCount;

        gAskLogID[index] =
            strval(fields[0]);

        gAskLogStatus[index] =
            strval(fields[1]);

        gAskLogCreated[index] =
            strval(fields[2]);

        gAskLogAnswered[index] =
            strval(fields[3]);

        format(
            gAskLogRequester[index],
            ASK_USERNAME_LENGTH,
            "%s",
            fields[4]
        );

        format(
            gAskLogAccount[index],
            ASK_USERNAME_LENGTH,
            "%s",
            fields[5]
        );

        format(
            gAskLogQuestion[index],
            ASK_QUESTION_LENGTH,
            "%s",
            fields[6]
        );

        format(
            gAskLogAnswer[index],
            ASK_ANSWER_LENGTH,
            "%s",
            fields[7]
        );

        format(
            gAskLogAdminRank[index],
            ADMIN_RANKNAME_LENGTH,
            "%s",
            fields[8]
        );

        format(
            gAskLogAdminUsername[index],
            ASK_USERNAME_LENGTH,
            "%s",
            fields[9]
        );

        gAskLogCount++;
    }

    fclose(file);

    return 1;
}


// ============================================================
// ASK ADD LOG
// ============================================================

stock CRP_AskAddLog(
    queue_index,
    status,
    const answer[],
    const admin_rank[],
    const admin_username[]
)
{
    if(
        queue_index < 0 ||
        queue_index >= ASK_MAX_QUEUE
    )
    {
        return -1;
    }

    if(gAskLogCount >= ASK_MAX_LOG)
    {
        return -1;
    }

    new index = gAskLogCount;

    gAskLogID[index] =
        gAskQueueID[queue_index];

    gAskLogStatus[index] =
        status;

    gAskLogCreated[index] =
        gAskQueueCreated[queue_index];

    if(status == ASK_STATUS_ANSWERED)
    {
        gAskLogAnswered[index] = gettime();
    }
    else
    {
        gAskLogAnswered[index] = 0;
    }

    format(
        gAskLogRequester[index],
        ASK_USERNAME_LENGTH,
        "%s",
        gAskQueueRequester[queue_index]
    );

    format(
        gAskLogAccount[index],
        ASK_USERNAME_LENGTH,
        "%s",
        gAskQueueAccount[queue_index]
    );

    format(
        gAskLogQuestion[index],
        ASK_QUESTION_LENGTH,
        "%s",
        gAskQueueQuestion[queue_index]
    );

    format(
        gAskLogAnswer[index],
        ASK_ANSWER_LENGTH,
        "%s",
        answer
    );

    format(
        gAskLogAdminRank[index],
        ADMIN_RANKNAME_LENGTH,
        "%s",
        admin_rank
    );

    format(
        gAskLogAdminUsername[index],
        ASK_USERNAME_LENGTH,
        "%s",
        admin_username
    );

    gAskLogCount++;

    CRP_AskSaveLog(index);

    return index;
}


// ============================================================
// ASK REMOVE QUEUE SLOT
// ============================================================

stock CRP_AskRemoveQueue(index)
{
    if(
        index < 0 ||
        index >= gAskQueueCount
    )
    {
        return 0;
    }

    for(
        new i = index;
        i < gAskQueueCount - 1;
        i++
    )
    {
        gAskQueueID[i] =
            gAskQueueID[i + 1];

        gAskQueueStatus[i] =
            gAskQueueStatus[i + 1];

        gAskQueueCreated[i] =
            gAskQueueCreated[i + 1];

        gAskQueuePlayerID[i] =
            gAskQueuePlayerID[i + 1];

        format(
            gAskQueueRequester[i],
            ASK_USERNAME_LENGTH,
            "%s",
            gAskQueueRequester[i + 1]
        );

        format(
            gAskQueueAccount[i],
            ASK_USERNAME_LENGTH,
            "%s",
            gAskQueueAccount[i + 1]
        );

        format(
            gAskQueueQuestion[i],
            ASK_QUESTION_LENGTH,
            "%s",
            gAskQueueQuestion[i + 1]
        );
    }

    gAskQueueCount--;

    if(gAskQueueCount < 0)
    {
        gAskQueueCount = 0;
    }

    return 1;
}


// ============================================================
// ASK EXPIRE QUEUES
// ============================================================

public CRP_AskExpireQueues()
{
    new now = gettime();

    for(
        new i = gAskQueueCount - 1;
        i >= 0;
        i--
    )
    {
        if(
            gAskQueueStatus[i] !=
            ASK_STATUS_ACTIVE
        )
        {
            continue;
        }

        if(
            now -
            gAskQueueCreated[i] <
            ASK_QUEUE_TIMEOUT
        )
        {
            continue;
        }

        CRP_AskAddLog(
            i,
            ASK_STATUS_EXPIRED,
            "",
            "",
            ""
        );

        new targetid =
            gAskQueuePlayerID[i];

        if(
            targetid != INVALID_PLAYER_ID &&
            CRP_AdminIsValidPlayer(targetid)
        )
        {
            SendClientMessage(
                targetid,
                COLOR_YELLOW,
                "ASK: Pertanyaan kamu telah berakhir karena tidak dijawab dalam 10 menit."
            );
        }

        CRP_AskRemoveQueue(i);
    }

    return 1;
}


// ============================================================
// ASK CREATE QUEUE
// ============================================================

public CRP_AskCreateQueue(
    playerid,
    const requester[],
    const account[],
    const question[]
)
{
    if(
        gAskQueueCount >=
        ASK_MAX_QUEUE
    )
    {
        return 0;
    }

    new sanitized_question[
        ASK_QUESTION_LENGTH
    ];

    CRP_AskSanitize(
        question,
        sanitized_question,
        sizeof(sanitized_question)
    );

    if(sanitized_question[0] == EOS)
    {
        return 0;
    }

    new index =
        gAskQueueCount;

    gAskQueueID[index] =
        gAskNextQueueID;

    gAskNextQueueID++;

    CRP_AskSaveCounter();

    gAskQueueStatus[index] =
        ASK_STATUS_ACTIVE;

    gAskQueueCreated[index] =
        gettime();

    gAskQueuePlayerID[index] =
        playerid;

    format(
        gAskQueueRequester[index],
        ASK_USERNAME_LENGTH,
        "%s",
        requester
    );

    format(
        gAskQueueAccount[index],
        ASK_USERNAME_LENGTH,
        "%s",
        account
    );

    format(
        gAskQueueQuestion[index],
        ASK_QUESTION_LENGTH,
        "%s",
        sanitized_question
    );

    gAskQueueCount++;

    new notice[256];

    format(
        notice,
        sizeof(notice),
        "BotCmd: ASK #%03d masuk ke queue dari %s.",
        gAskQueueID[index],
        gAskQueueRequester[index]
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

        SendClientMessage(
            i,
            COLOR_YELLOW,
            notice
        );
    }

    return gAskQueueID[index];
}


// ============================================================
// ASK FIND QUEUE BY ID
// ============================================================

stock CRP_AskFindQueue(queueid)
{
    for(new i = 0; i < gAskQueueCount; i++)
    {
        if(gAskQueueID[i] == queueid)
        {
            return i;
        }
    }

    return -1;
}


// ============================================================
// ASK FIND QUEUE BY PLAYER
// ============================================================

public CRP_AskGetQueueIDForPlayer(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    for(new i = 0; i < gAskQueueCount; i++)
    {
        if(
            gAskQueuePlayerID[i] == playerid &&
            gAskQueueStatus[i] ==
            ASK_STATUS_ACTIVE
        )
        {
            return gAskQueueID[i];
        }
    }

    return 0;
}


// ============================================================
// ASK ANSWER QUEUE
// ============================================================

public CRP_AskAnswerQueue(
    playerid,
    queueid,
    const answer[]
)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new index =
        CRP_AskFindQueue(queueid);

    if(index == -1)
    {
        return 0;
    }

    if(
        gAskQueueStatus[index] !=
        ASK_STATUS_ACTIVE
    )
    {
        return 0;
    }

    new sanitized_answer[
        ASK_ANSWER_LENGTH
    ];

    CRP_AskSanitize(
        answer,
        sanitized_answer,
        sizeof(sanitized_answer)
    );

    if(sanitized_answer[0] == EOS)
    {
        return 0;
    }

    new rankname[
        ADMIN_RANKNAME_LENGTH
    ];

    CRP_GetAdminRankName(
        gPlayerAdminRank[playerid],
        rankname,
        sizeof(rankname)
    );

    new admin_identity[64];

    format(
        admin_identity,
        sizeof(admin_identity),
        "%s %s",
        rankname,
        gPlayerAccountUsername[playerid]
    );

    CRP_AskAddLog(
        index,
        ASK_STATUS_ANSWERED,
        sanitized_answer,
        rankname,
        gPlayerAccountUsername[playerid]
    );

    new targetid =
        gAskQueuePlayerID[index];

    if(
        targetid != INVALID_PLAYER_ID &&
        CRP_AdminIsValidPlayer(targetid)
    )
    {
        new message[256];

        format(
            message,
            sizeof(message),
            "ASK: %s telah menjawab pertanyaan kamu.",
            admin_identity
        );

        SendClientMessage(
            targetid,
            COLOR_GREEN,
            message
        );

        format(
            message,
            sizeof(message),
            "ANSWER: %s",
            sanitized_answer
        );

        SendClientMessage(
            targetid,
            COLOR_WHITE,
            message
        );
    }

    new logmessage[256];

    format(
        logmessage,
        sizeof(logmessage),
        "AdminCmd: %s %s menjawab ASK #%03d.",
        rankname,
        gPlayerAccountUsername[playerid],
        queueid
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

        SendClientMessage(
            i,
            COLOR_GREY,
            logmessage
        );
    }

    CRP_AskRemoveQueue(index);

    return 1;
}


// ============================================================
// ASK ADMIN QUEUE
// ============================================================

public CRP_AskOpenAdminQueue(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    CRP_AskExpireQueues();

    new list[4096];

    format(
        list,
        sizeof(list),
        "QUEUE\tDescription\tQuestioned\n"
    );

    new count = 0;

    for(new i = 0; i < gAskQueueCount; i++)
    {
        if(
            gAskQueueStatus[i] !=
            ASK_STATUS_ACTIVE
        )
        {
            continue;
        }

        new line[320];

        format(
            line,
            sizeof(line),
            "#%03d\t%s\t%s\n",
            gAskQueueID[i],
            gAskQueueQuestion[i],
            gAskQueueRequester[i]
        );

        strcat(
            list,
            line
        );

        count++;
    }

    if(count == 0)
    {
        format(
            list,
            sizeof(list),
            "QUEUE\tDescription\tQuestioned\n"
            "-\tTidak ada ASK aktif\t-"
        );
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ASKS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ASKS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "ASK",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ASK DETAIL
// ============================================================

stock CRP_AskShowQueueDetail(
    playerid,
    queue_index
)
{
    if(
        queue_index < 0 ||
        queue_index >= gAskQueueCount
    )
    {
        return 0;
    }

    if(
        gAskQueueStatus[queue_index] !=
        ASK_STATUS_ACTIVE
    )
    {
        return 0;
    }

    gSelectedAskQueue[playerid] =
        queue_index;

    new message[512];

    format(
        message,
        sizeof(message),
        "QUEUE #%03d - %s\n\n%s\n\nJawab",
        gAskQueueID[queue_index],
        gAskQueueRequester[queue_index],
        gAskQueueQuestion[queue_index]
    );

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ASK_DETAIL;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ASK_DETAIL,
        DIALOG_STYLE_LIST,
        "ASK DETAIL",
        message,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ASK ANSWER DIALOG
// ============================================================

stock CRP_AskShowAnswerDialog(playerid)
{
    new index =
        gSelectedAskQueue[playerid];

    if(
        index < 0 ||
        index >= gAskQueueCount
    )
    {
        return 0;
    }

    if(
        gAskQueueStatus[index] !=
        ASK_STATUS_ACTIVE
    )
    {
        return 0;
    }

    new title[64];

    format(
        title,
        sizeof(title),
        "JAWAB ASK #%03d",
        gAskQueueID[index]
    );

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ASK_ANSWER,
        DIALOG_STYLE_INPUT,
        title,
        "Masukkan jawaban untuk pertanyaan ini:",
        "KIRIM",
        "BATAL"
    );

    return 1;
}


// ============================================================
// ASK BOT FILLER WORD
// ============================================================

stock CRP_AskIsFillerWord(const word[])
{
    if(!strcmp(word, "aku", true)) return 1;
    if(!strcmp(word, "saya", true)) return 1;
    if(!strcmp(word, "bang", true)) return 1;
    if(!strcmp(word, "kak", true)) return 1;
    if(!strcmp(word, "min", true)) return 1;
    if(!strcmp(word, "admin", true)) return 1;
    if(!strcmp(word, "duh", true)) return 1;
    if(!strcmp(word, "dong", true)) return 1;
    if(!strcmp(word, "ya", true)) return 1;
    if(!strcmp(word, "yah", true)) return 1;
    if(!strcmp(word, "deh", true)) return 1;
    if(!strcmp(word, "nih", true)) return 1;
    if(!strcmp(word, "ini", true)) return 1;
    if(!strcmp(word, "itu", true)) return 1;

    return 0;
}


// ============================================================
// ASK BOT WORD CLEANER
// ============================================================

stock CRP_AskCleanWord(
    const input[],
    output[],
    size
)
{
    new position = 0;

    for(
        new i = 0;
        input[i] != EOS &&
        position < size - 1;
        i++
    )
    {
        if(
            input[i] == '?' ||
            input[i] == '!' ||
            input[i] == '.' ||
            input[i] == ',' ||
            input[i] == ':' ||
            input[i] == ';' ||
            input[i] == '(' ||
            input[i] == ')'
        )
        {
            continue;
        }

        output[position++] =
            tolower(input[i]);
    }

    output[position] = EOS;

    return 1;
}


// ============================================================
// ASK BOT QUESTION SCORE
// ============================================================

stock CRP_AskQuestionScore(
    const question_a[],
    const question_b[]
)
{
    new words_a[24][32];
    new words_b[24][32];

    new count_a = 0;
    new count_b = 0;

    new start = 0;
    new length = strlen(question_a);

    for(
        new i = 0;
        i <= length &&
        count_a < 24;
        i++
    )
    {
        if(
            question_a[i] == ' ' ||
            question_a[i] == EOS
        )
        {
            if(i > start)
            {
                new raw[32];

                strmid(
                    raw,
                    question_a,
                    start,
                    i,
                    sizeof(raw)
                );

                new cleaned[32];

                CRP_AskCleanWord(
                    raw,
                    cleaned,
                    sizeof(cleaned)
                );

                if(
                    cleaned[0] != EOS &&
                    !CRP_AskIsFillerWord(cleaned)
                )
                {
                    format(
                        words_a[count_a],
                        sizeof(words_a[]),
                        "%s",
                        cleaned
                    );

                    count_a++;
                }
            }

            start = i + 1;
        }
    }

    start = 0;
    length = strlen(question_b);

    for(
        new i = 0;
        i <= length &&
        count_b < 24;
        i++
    )
    {
        if(
            question_b[i] == ' ' ||
            question_b[i] == EOS
        )
        {
            if(i > start)
            {
                new raw[32];

                strmid(
                    raw,
                    question_b,
                    start,
                    i,
                    sizeof(raw)
                );

                new cleaned[32];

                CRP_AskCleanWord(
                    raw,
                    cleaned,
                    sizeof(cleaned)
                );

                if(
                    cleaned[0] != EOS &&
                    !CRP_AskIsFillerWord(cleaned)
                )
                {
                    format(
                        words_b[count_b],
                        sizeof(words_b[]),
                        "%s",
                        cleaned
                    );

                    count_b++;
                }
            }

            start = i + 1;
        }
    }

    if(
        count_a == 0 ||
        count_b == 0
    )
    {
        return ASK_SCORE_NONE;
    }

    new matches = 0;

    for(new a = 0; a < count_a; a++)
    {
        for(new b = 0; b < count_b; b++)
        {
            if(!strcmp(
                words_a[a],
                words_b[b],
                true
            ))
            {
                matches++;
                break;
            }
        }
    }

    if(matches >= 4)
    {
        return ASK_SCORE_HIGH;
    }

    if(matches >= ASK_MATCH_MIN_WORDS)
    {
        return ASK_SCORE_MEDIUM;
    }

    if(matches == 1)
    {
        return ASK_SCORE_LOW;
    }

    return ASK_SCORE_NONE;
}


// ============================================================
// ASK BOT INSERT MATCH
// ============================================================

stock CRP_AskInsertMatch(
    playerid,
    log_index,
    score
)
{
    if(
        !CRP_AdminIsValidPlayer(playerid)
    )
    {
        return 0;
    }

    if(score <= ASK_SCORE_NONE)
    {
        return 0;
    }

    new count =
        gAskMatchCount[playerid];

    if(count >= ASK_MATCH_MAX_RESULTS)
    {
        if(
            score <=
            gAskMatchScore[playerid][count - 1]
        )
        {
            return 0;
        }

        count =
            ASK_MATCH_MAX_RESULTS - 1;
    }

    new position = count;

    for(new i = 0; i < count; i++)
    {
        if(
            score >
            gAskMatchScore[playerid][i]
        )
        {
            position = i;
            break;
        }
    }

    if(position < ASK_MATCH_MAX_RESULTS)
    {
        for(
            new i = ASK_MATCH_MAX_RESULTS - 1;
            i > position;
            i--
        )
        {
            gAskMatchScore[playerid][i] =
                gAskMatchScore[playerid][i - 1];

            gAskMatchLogIndex[playerid][i] =
                gAskMatchLogIndex[playerid][i - 1];
        }

        gAskMatchScore[playerid][position] =
            score;

        gAskMatchLogIndex[playerid][position] =
            log_index;
    }

    if(
        gAskMatchCount[playerid] <
        ASK_MATCH_MAX_RESULTS
    )
    {
        gAskMatchCount[playerid]++;
    }

    return 1;
}


// ============================================================
// ASK BOT SIMILAR QUESTION SEARCH
// ============================================================
//
// ONLY ANSWERED logs are searched.
//
// ACTIVE = ignored
// EXPIRED = ignored
//
// ============================================================

public CRP_AskGetSimilarQuestions(
    playerid,
    const question[]
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    gAskMatchCount[playerid] = 0;

    for(new i = 0; i < ASK_MATCH_MAX_RESULTS; i++)
    {
        gAskMatchLogIndex[playerid][i] = -1;
        gAskMatchScore[playerid][i] = 0;
    }

    for(new i = 0; i < gAskLogCount; i++)
    {
        if(
            gAskLogStatus[i] !=
            ASK_STATUS_ANSWERED
        )
        {
            continue;
        }

        new score =
            CRP_AskQuestionScore(
                question,
                gAskLogQuestion[i]
            );

        if(score <= ASK_SCORE_NONE)
        {
            continue;
        }

        CRP_AskInsertMatch(
            playerid,
            i,
            score
        );
    }

    return gAskMatchCount[playerid];
}


// ============================================================
// ASK BOT MATCH COUNT
// ============================================================

public CRP_AskGetMatchCount(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gAskMatchCount[playerid];
}


// ============================================================
// ASK BOT MATCH INDEX
// ============================================================

public CRP_AskGetMatchLog(
    playerid,
    match_index
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return -1;
    }

    if(
        match_index < 0 ||
        match_index >=
        gAskMatchCount[playerid]
    )
    {
        return -1;
    }

    return gAskMatchLogIndex[
        playerid
    ][match_index];
}


// ============================================================
// ASK LOG GET QUESTION
// ============================================================

public CRP_AskGetLogQuestion(
    log_index,
    output[],
    size
)
{
    if(
        log_index < 0 ||
        log_index >= gAskLogCount
    )
    {
        output[0] = EOS;
        return 0;
    }

    format(
        output,
        size,
        "%s",
        gAskLogQuestion[log_index]
    );

    return 1;
}


// ============================================================
// ASK LOG GET ANSWER
// ============================================================

public CRP_AskGetLogAnswer(
    log_index,
    output[],
    size
)
{
    if(
        log_index < 0 ||
        log_index >= gAskLogCount
    )
    {
        output[0] = EOS;
        return 0;
    }

    format(
        output,
        size,
        "%s",
        gAskLogAnswer[log_index]
    );

    return 1;
}


// ============================================================
// ASK LOG GET REQUESTER
// ============================================================

public CRP_AskGetLogRequester(
    log_index,
    output[],
    size
)
{
    if(
        log_index < 0 ||
        log_index >= gAskLogCount
    )
    {
        output[0] = EOS;
        return 0;
    }

    format(
        output,
        size,
        "%s",
        gAskLogRequester[log_index]
    );

    return 1;
}


// ============================================================
// ASK LOG GET ADMIN
// ============================================================

public CRP_AskGetLogAdmin(
    log_index,
    output[],
    size
)
{
    if(
        log_index < 0 ||
        log_index >= gAskLogCount
    )
    {
        output[0] = EOS;
        return 0;
    }

    if(
        gAskLogStatus[log_index] !=
        ASK_STATUS_ANSWERED
    )
    {
        output[0] = EOS;
        return 0;
    }

    format(
        output,
        size,
        "%s %s",
        gAskLogAdminRank[log_index],
        gAskLogAdminUsername[log_index]
    );

    return 1;
}


// ============================================================
// ASK FALLBACK CONFIRMATION BRIDGE
// ============================================================

public CRP_AskConfirmFallback(
    playerid,
    const requester[],
    const account[],
    const question[]
)
{
    return CRP_AskCreateQueue(
        playerid,
        requester,
        account,
        question
    );
}


// ============================================================
// ASK ADMIN LOG VIEW
// ============================================================

stock CRP_AskShowLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new list[4096];

    format(
        list,
        sizeof(list),
        "QUEUE\tQuestion\tQuestioned\tStatus\n"
    );

    new count = 0;

    for(
        new i = gAskLogCount - 1;
        i >= 0;
        i--
    )
    {
        new status[16];

        if(
            gAskLogStatus[i] ==
            ASK_STATUS_ANSWERED
        )
        {
            format(
                status,
                sizeof(status),
                "ANSWERED"
            );
        }
        else if(
            gAskLogStatus[i] ==
            ASK_STATUS_EXPIRED
        )
        {
            format(
                status,
                sizeof(status),
                "EXPIRED"
            );
        }
        else
        {
            continue;
        }

        new line[320];

        format(
            line,
            sizeof(line),
            "#%03d\t%s\t%s\t%s\n",
            gAskLogID[i],
            gAskLogQuestion[i],
            gAskLogRequester[i],
            status
        );

        strcat(
            list,
            line
        );

        count++;
    }

    if(count == 0)
    {
        format(
            list,
            sizeof(list),
            "QUEUE\tQuestion\tQuestioned\tStatus\n"
            "-\tBelum ada ASK Logs\t-\t-"
        );
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ASK_LOGS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ASK_LOGS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "ASK LOGS",
        list,
        "LIHAT",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// ASK LOG DETAIL
// ============================================================

stock CRP_AskShowLogDetail(
    playerid,
    log_index
)
{
    if(
        log_index < 0 ||
        log_index >= gAskLogCount
    )
    {
        return 0;
    }

    gSelectedAskLog[playerid] =
        log_index;

    new status[16];

    if(
        gAskLogStatus[log_index] ==
        ASK_STATUS_ANSWERED
    )
    {
        format(
            status,
            sizeof(status),
            "ANSWERED"
        );
    }
    else
    {
        format(
            status,
            sizeof(status),
            "EXPIRED"
        );
    }

    new message[768];

    format(
        message,
        sizeof(message),
        "QUEUE #%03d\n\
STATUS: %s\n\
QUESTIONED: %s\n\n\
QUESTION:\n%s\n\n\
ANSWER:\n%s\n\n\
ADMIN:\n%s %s",
        gAskLogID[log_index],
        status,
        gAskLogRequester[log_index],
        gAskLogQuestion[log_index],
        gAskLogAnswer[log_index],
        gAskLogAdminRank[log_index],
        gAskLogAdminUsername[log_index]
    );

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ASK_LOGS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ASK_LOG_DETAIL,
        DIALOG_STYLE_MSGBOX,
        "ASK LOG",
        message,
        "TUTUP",
        ""
    );

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

    list[0] = EOS;

    strcat(
        list,
        "Admin List\n"
    );

    if(
        gPlayerAdminRank[playerid] >=
        ADMIN_HELPER
    )
    {
        strcat(
            list,
            "Admin Duty\n"
        );
    }

    strcat(
        list,
        "Admins\n"
    );

    if(
        gPlayerAdminRank[playerid] >=
        ADMIN_HELPER
    )
    {
        strcat(
            list,
            "My Bans\n"
        );
    }

    strcat(
        list,
        "Logs\n"
    );

    strcat(
        list,
        "Reports"
    );

    if(
        CRP_AdminCanAccessAdminSettings(playerid)
    )
    {
        strcat(
            list,
            "\nAdmin Settings"
        );
    }

    if(
        CRP_AdminCanAccessMoneySettings(playerid)
    )
    {
        strcat(
            list,
            "\nMoney Settings"
        );
    }

    if(
        CRP_AdminCanAccessAdminDivision(playerid)
    )
    {
        strcat(
            list,
            "\nAdmin Division"
        );
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_MAIN;

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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_LIST;

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


stock CRP_AdminBuildList(
    output[],
    size
)
{
    output[0] = EOS;

    format(
        output,
        size,
        "Account Username\tRank\tDuty\tTime\n"
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

        new rankname[
            ADMIN_RANKNAME_LENGTH
        ];

        new dutyname[16];
        new line[128];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        if(gPlayerAdminDuty[i])
        {
            format(
                dutyname,
                sizeof(dutyname),
                "ON"
            );
        }
        else
        {
            format(
                dutyname,
                sizeof(dutyname),
                "OFF"
            );
        }

        new seconds =
            CRP_AdminGetDutySeconds(i);

        new hours =
            seconds / 3600;

        new minutes =
            (seconds % 3600) / 60;

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\t%02d:%02d\n",
            gPlayerAccountUsername[i],
            rankname,
            dutyname,
            hours,
            minutes
        );

        strcat(
            output,
            line
        );
    }

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

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_HELPER
    )
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

        new seconds =
            CRP_AdminGetDutySeconds(i);

        new hours =
            seconds / 3600;

        new minutes =
            (seconds % 3600) / 60;

        new line[96];

        format(
            line,
            sizeof(line),
            "%s\t%02d:%02d\n",
            gPlayerAccountUsername[i],
            hours,
            minutes
        );

        strcat(
            list,
            line
        );
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_DUTY;

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
        "Rank\tAccount Username\tStatus\tDuty Time\n"
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

        new rankname[
            ADMIN_RANKNAME_LENGTH
        ];

        new status[16];
        new line[160];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        if(gPlayerAdminDuty[i])
        {
            format(
                status,
                sizeof(status),
                "ON DUTY"
            );
        }
        else
        {
            format(
                status,
                sizeof(status),
                "OFF DUTY"
            );
        }

        new seconds =
            CRP_AdminGetDutySeconds(i);

        new hours =
            seconds / 3600;

        new minutes =
            (seconds % 3600) / 60;

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\t%02d:%02d\n",
            rankname,
            gPlayerAccountUsername[i],
            status,
            hours,
            minutes
        );

        strcat(
            list,
            line
        );
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ADMINS;

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
// MY BANS MAIN
// ============================================================

stock CRP_AdminShowMyBans(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_HELPER
    )
    {
        return 0;
    }

    new list[256];

    format(
        list,
        sizeof(list),
        "Character\n\
UCP"
    );

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_MY_BANS;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_MY_BANS,
        DIALOG_STYLE_LIST,
        "MY BANS",
        list,
        "PILIH",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// MY BANS CHARACTER
// ============================================================

stock CRP_AdminShowMyCharacterBans(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_HELPER
    )
    {
        return 0;
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_MY_BANS;

    CallRemoteFunction(
        "CRP_AdminLogsOpenMyBansCharacter",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// MY BANS UCP
// ============================================================

stock CRP_AdminShowMyUCPBans(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_HELPER
    )
    {
        return 0;
    }

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_MY_BANS;

    CallRemoteFunction(
        "CRP_AdminLogsOpenMyBansUCP",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// MY BAN ACTION
// ============================================================

forward CRP_AdminMyBanAction(
    playerid,
    type,
    action
);

public CRP_AdminMyBanAction(
    playerid,
    type,
    action
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_HELPER
    )
    {
        return 0;
    }

    gSelectedMyBanType[playerid] =
        type;

    gSelectedMyBanAction[playerid] =
        action;

    new actionname[32];

    if(
        action ==
        ADMIN_BAN_ACTION_UNBAN
    )
    {
        format(
            actionname,
            sizeof(actionname),
            "Unban"
        );
    }
    else if(
        action ==
        ADMIN_BAN_ACTION_UNBLOCK
    )
    {
        format(
            actionname,
            sizeof(actionname),
            "Unblock"
        );
    }
    else
    {
        return 0;
    }

    new message[256];

    format(
        message,
        sizeof(message),
        "%s\n\nApakah Anda yakin ingin menjalankan tindakan ini?",
        actionname
    );

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_MY_BANS_CONFIRM,
        DIALOG_STYLE_MSGBOX,
        "KONFIRMASI",
        message,
        "KONFIRMASI",
        "BATAL"
    );

    return 1;
}


// ============================================================
// MY BAN CONFIRMATION
// ============================================================

stock CRP_AdminConfirmMyBanAction(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    new type =
        gSelectedMyBanType[playerid];

    new action =
        gSelectedMyBanAction[playerid];

    CallRemoteFunction(
        "CRP_AdminLogsExecuteMyBanAction",
        "iii",
        playerid,
        type,
        action
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
Faction and Families\n\
ASK"
    );

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_LOGS;

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

    CallRemoteFunction(
        "CRP_AdminLogsOpenReportLogs",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// FACTION / FAMILIES LOG MENU
// ============================================================

stock CRP_AdminShowFactionFamilyLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(
        gPlayerAdminRank[playerid] <
        ADMIN_SERVER_DIRECTOR &&
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_LOG_FACTION;

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
    if(
        !CRP_AdminCanAccessAdminSettings(playerid)
    )
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ADMIN_SETTINGS;

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
    if(
        !CRP_AdminCanAccessMoneySettings(playerid)
    )
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_MONEY_SETTINGS;

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
    if(
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_ADMIN_DIVISION;

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

stock CRP_AdminShowFactionDivision(playerid)
{
    if(
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_FACTION_DIV;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_FACTION_DIV,
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
    if(
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_HOUSE_BUSINESS;

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
// FACTION LIST
// ============================================================

stock CRP_AdminShowFactionList(playerid)
{
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid) &&
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
    {
        return 0;
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_FACTION_LIST;

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_FACTION_LIST,
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
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid) &&
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
    {
        return 0;
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

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_FAMILIES;

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

stock CRP_AdminShowHandlerList(
    playerid,
    division
)
{
    if(
        !CRP_AdminCanAccessAdminDivision(playerid)
    )
    {
        return 0;
    }

    new list[ADMIN_DIALOG_SIZE];

    format(
        list,
        sizeof(list),
        "Account Username\tDivision\n"
    );

    if(
        division ==
        ADMIN_DIVISION_FACTION_FAMILY
    )
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                CRP_AdminIsAccountEmpty(
                    gFactionFamilyHandlerAccount[i]
                )
            )
            {
                continue;
            }

            new line[128];

            format(
                line,
                sizeof(line),
                "%s\tFaction & Families\n",
                gFactionFamilyHandlerAccount[i]
            );

            strcat(
                list,
                line
            );
        }
    }
    else if(
        division ==
        ADMIN_DIVISION_HOUSE_BUSINESS
    )
    {
        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                CRP_AdminIsAccountEmpty(
                    gHouseBusinessHandlerAccount[i]
                )
            )
            {
                continue;
            }

            new line[128];

            format(
                line,
                sizeof(line),
                "%s\tHouses & Business\n",
                gHouseBusinessHandlerAccount[i]
            );

            strcat(
                list,
                line
            );
        }
    }

    gSelectedHandlerDivision[playerid] =
        division;

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_HANDLER_LIST;

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

stock CRP_AdminCanAssignHandler(
    actorid,
    targetid
)
{
    if(
        !CRP_AdminCanAccessAdminDivision(actorid)
    )
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

    if(
        !CRP_AdminCanTarget(
            actorid,
            targetid
        )
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// ASSIGN FACTION / FAMILY HANDLER
// ============================================================

stock CRP_AdminSetFactionFamilyHandle(
    targetid,
    handler_state
)
{
    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(handler_state)
    {
        if(
            !CRP_AdminCanBecomeHandler(targetid)
        )
        {
            return 0;
        }

        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                !CRP_AdminIsAccountEmpty(
                    gFactionFamilyHandlerAccount[i]
                ) &&
                !strcmp(
                    gFactionFamilyHandlerAccount[i],
                    gPlayerAccountUsername[targetid],
                    true
                )
            )
            {
                return 1;
            }
        }

        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                CRP_AdminIsAccountEmpty(
                    gFactionFamilyHandlerAccount[i]
                )
            )
            {
                format(
                    gFactionFamilyHandlerAccount[i],
                    ADMIN_USERNAME_LENGTH,
                    "%s",
                    gPlayerAccountUsername[targetid]
                );

                return 1;
            }
        }

        return 0;
    }

    CRP_AdminRemoveHandlerAccount(
        ADMIN_DIVISION_FACTION_FAMILY,
        gPlayerAccountUsername[targetid]
    );

    gPlayerActiveFaction[targetid] =
        ADMIN_FACTION_NONE;

    gPlayerActiveFamily[targetid] =
        ADMIN_FAMILY_NONE;

    return 1;
}


// ============================================================
// ASSIGN HOUSE / BUSINESS HANDLER
// ============================================================

stock CRP_AdminSetHouseBusinessHandle(
    targetid,
    handler_state
)
{
    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(handler_state)
    {
        if(
            !CRP_AdminCanBecomeHandler(targetid)
        )
        {
            return 0;
        }

        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                !CRP_AdminIsAccountEmpty(
                    gHouseBusinessHandlerAccount[i]
                ) &&
                !strcmp(
                    gHouseBusinessHandlerAccount[i],
                    gPlayerAccountUsername[targetid],
                    true
                )
            )
            {
                return 1;
            }
        }

        for(new i = 0; i < ADMIN_HANDLER_MAX; i++)
        {
            if(
                CRP_AdminIsAccountEmpty(
                    gHouseBusinessHandlerAccount[i]
                )
            )
            {
                format(
                    gHouseBusinessHandlerAccount[i],
                    ADMIN_USERNAME_LENGTH,
                    "%s",
                    gPlayerAccountUsername[targetid]
                );

                return 1;
            }
        }

        return 0;
    }

    CRP_AdminRemoveHandlerAccount(
        ADMIN_DIVISION_HOUSE_BUSINESS,
        gPlayerAccountUsername[targetid]
    );

    return 1;
}


// ============================================================
// FACTION IN
// ============================================================

stock CRP_AdminFactionIn(
    playerid,
    faction
)
{
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        return 0;
    }

    if(
        faction < ADMIN_FACTION_LSPD ||
        faction > ADMIN_FACTION_GOV
    )
    {
        return 0;
    }

    if(
        gPlayerActiveFaction[playerid] !=
        ADMIN_FACTION_NONE &&
        gPlayerActiveFaction[playerid] !=
        faction
    )
    {
        return 0;
    }

    gPlayerActiveFamily[playerid] =
        ADMIN_FAMILY_NONE;

    gPlayerActiveFaction[playerid] =
        faction;

    return 1;
}


// ============================================================
// FACTION OUT
// ============================================================

stock CRP_AdminFactionOut(playerid)
{
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        return 0;
    }

    gPlayerActiveFaction[playerid] =
        ADMIN_FACTION_NONE;

    return 1;
}


// ============================================================
// FAMILY IN
// ============================================================

stock CRP_AdminFamilyIn(
    playerid,
    family
)
{
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        return 0;
    }

    if(
        family < ADMIN_FAMILY_SLOT_1 ||
        family > ADMIN_FAMILY_SLOT_10
    )
    {
        return 0;
    }

    if(
        gPlayerActiveFamily[playerid] !=
        ADMIN_FAMILY_NONE &&
        gPlayerActiveFamily[playerid] !=
        family
    )
    {
        return 0;
    }

    gPlayerActiveFaction[playerid] =
        ADMIN_FACTION_NONE;

    gPlayerActiveFamily[playerid] =
        family;

    return 1;
}


// ============================================================
// FAMILY OUT
// ============================================================

stock CRP_AdminFamilyOut(playerid)
{
    if(
        !CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        return 0;
    }

    gPlayerActiveFamily[playerid] =
        ADMIN_FAMILY_NONE;

    return 1;
}


// ============================================================
// REMOTE FUNCTIONS
// ============================================================

public CRP_AdminGetRank(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_NO_STAFF;
    }

    return gPlayerAdminRank[playerid];
}


public CRP_AdminIsStaffRemote(playerid)
{
    return CRP_AdminIsStaff(playerid);
}


public CRP_AdminIsDeveloperRemote(playerid)
{
    return CRP_AdminIsDeveloper(playerid);
}


public CRP_AdminCanTargetRemote(
    actorid,
    targetid
)
{
    return CRP_AdminCanTarget(
        actorid,
        targetid
    );
}


public CRP_AdminGetDivision(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_DIVISION_NONE;
    }

    if(
        CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        return ADMIN_DIVISION_FACTION_FAMILY;
    }

    if(
        CRP_AdminIsHouseBusinessHandler(playerid)
    )
    {
        return ADMIN_DIVISION_HOUSE_BUSINESS;
    }

    return ADMIN_DIVISION_NONE;
}


public CRP_AdminGetFaction(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_FACTION_NONE;
    }

    return gPlayerActiveFaction[playerid];
}


public CRP_AdminGetFamily(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_FAMILY_NONE;
    }

    return gPlayerActiveFamily[playerid];
}


public CRP_AdminGetHandlerType(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return ADMIN_HANDLER_NONE;
    }

    if(
        CRP_AdminIsFactionFamilyHandler(playerid)
    )
    {
        if(
            gPlayerActiveFamily[playerid] !=
            ADMIN_FAMILY_NONE
        )
        {
            return ADMIN_HANDLER_FAMILY;
        }

        return ADMIN_HANDLER_FACTION;
    }

    if(
        CRP_AdminIsHouseBusinessHandler(playerid)
    )
    {
        return ADMIN_HANDLER_HOUSE;
    }

    return ADMIN_HANDLER_NONE;
}


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


public CRP_AdminSetRankRemote(
    playerid,
    rank
)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(
        rank < ADMIN_NO_STAFF ||
        rank >= ADMIN_DEVELOPER
    )
    {
        return 0;
    }

    gPlayerAdminRank[playerid] =
        rank;

    return 1;
}


public CRP_AdminSetFactionRemote(
    playerid,
    faction
)
{
    return CRP_AdminFactionIn(
        playerid,
        faction
    );
}


public CRP_AdminSetFamilyRemote(
    playerid,
    family
)
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


    // ========================================================
    // CANCEL / BACK
    // ========================================================

    if(!response)
    {
        switch(dialogid)
        {
            case DIALOG_ADMIN_MAIN:
            {
                gPlayerAdminPanel[playerid] =
                    ADMIN_PANEL_NONE;

                return 1;
            }

            case DIALOG_ADMIN_MY_BANS:
            case DIALOG_ADMIN_LOGS:
            case DIALOG_ADMIN_SETTINGS:
            case DIALOG_ADMIN_MONEY_SETTINGS:
            case DIALOG_ADMIN_DIVISION:
            {
                CRP_AdminShowMainPanel(playerid);
                return 1;
            }

            case DIALOG_ADMIN_LIST:
            case DIALOG_ADMIN_DUTY:
            case DIALOG_ADMIN_ADMINS:
            case DIALOG_ADMIN_REPORTS:
            {
                CRP_AdminShowMainPanel(playerid);
                return 1;
            }

            case DIALOG_ADMIN_FACTION_DIV:
            case DIALOG_ADMIN_HOUSE_BUSINESS:
            {
                CRP_AdminShowAdminDivision(playerid);
                return 1;
            }

            case DIALOG_ADMIN_FACTION_LIST:
            case DIALOG_ADMIN_FAMILIES:
            {
                CRP_AdminShowFactionDivision(playerid);
                return 1;
            }

            case DIALOG_ADMIN_LOG_FACTION:
            {
                CRP_AdminShowLogs(playerid);
                return 1;
            }

            case DIALOG_ADMIN_HANDLER_LIST:
            {
                if(
                    gSelectedHandlerDivision[playerid] ==
                    ADMIN_DIVISION_FACTION_FAMILY
                )
                {
                    CRP_AdminShowFactionDivision(playerid);
                }
                else if(
                    gSelectedHandlerDivision[playerid] ==
                    ADMIN_DIVISION_HOUSE_BUSINESS
                )
                {
                    CRP_AdminShowHouseBusiness(playerid);
                }

                return 1;
            }

            case DIALOG_ADMIN_MY_BANS_CHARACTER:
            case DIALOG_ADMIN_MY_BANS_UCP:
            {
                CRP_AdminShowMyBans(playerid);
                return 1;
            }

            case DIALOG_ADMIN_MY_BANS_ACTION:
            {
                if(
                    gSelectedMyBanType[playerid] ==
                    ADMIN_MY_BANS_UCP
                )
                {
                    CRP_AdminShowMyUCPBans(playerid);
                }
                else
                {
                    CRP_AdminShowMyCharacterBans(playerid);
                }

                return 1;
            }

            case DIALOG_ADMIN_MY_BANS_CONFIRM:
            {
                if(
                    gSelectedMyBanType[playerid] ==
                    ADMIN_MY_BANS_UCP
                )
                {
                    CRP_AdminShowMyUCPBans(playerid);
                }
                else
                {
                    CRP_AdminShowMyCharacterBans(playerid);
                }

                return 1;
            }

            case DIALOG_ADMIN_ASKS:
            {
                CRP_AdminShowMainPanel(playerid);
                return 1;
            }

            case DIALOG_ADMIN_ASK_DETAIL:
            {
                CRP_AskOpenAdminQueue(playerid);
                return 1;
            }

            case DIALOG_ADMIN_ASK_ANSWER:
            {
                CRP_AskShowQueueDetail(
                    playerid,
                    gSelectedAskQueue[playerid]
                );

                return 1;
            }

            case DIALOG_ADMIN_ASK_LOGS:
            {
                CRP_AdminShowLogs(playerid);
                return 1;
            }

            case DIALOG_ADMIN_ASK_LOG_DETAIL:
            {
                CRP_AskShowLogs(playerid);
                return 1;
            }
        }

        return 0;
    }


    // ========================================================
    // MAIN PANEL
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MAIN)
    {
        new index = 0;

        if(listitem == index)
        {
            CRP_AdminShowList(playerid);
            return 1;
        }

        index++;

        if(
            gPlayerAdminRank[playerid] >=
            ADMIN_HELPER
        )
        {
            if(listitem == index)
            {
                CRP_AdminShowDuty(playerid);
                return 1;
            }

            index++;
        }

        if(listitem == index)
        {
            CRP_AdminShowAdmins(playerid);
            return 1;
        }

        index++;

        if(
            gPlayerAdminRank[playerid] >=
            ADMIN_HELPER
        )
        {
            if(listitem == index)
            {
                CRP_AdminShowMyBans(playerid);
                return 1;
            }

            index++;
        }

        if(listitem == index)
        {
            CRP_AdminShowLogs(playerid);
            return 1;
        }

        index++;

        if(listitem == index)
        {
            CRP_AdminShowReportLogs(playerid);
            return 1;
        }

        index++;

        if(
            CRP_AdminCanAccessAdminSettings(playerid)
        )
        {
            if(listitem == index)
            {
                CRP_AdminShowAdminSettings(playerid);
                return 1;
            }

            index++;
        }

        if(
            CRP_AdminCanAccessMoneySettings(playerid)
        )
        {
            if(listitem == index)
            {
                CRP_AdminShowMoneySettings(playerid);
                return 1;
            }

            index++;
        }

        if(
            CRP_AdminCanAccessAdminDivision(playerid)
        )
        {
            if(listitem == index)
            {
                CRP_AdminShowAdminDivision(playerid);
                return 1;
            }
        }

        return 1;
    }


    // ========================================================
    // MY BANS MAIN
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MY_BANS)
    {
        if(
            gPlayerAdminRank[playerid] <
            ADMIN_HELPER
        )
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                gSelectedMyBanType[playerid] =
                    ADMIN_MY_BANS_CHARACTER;

                CRP_AdminShowMyCharacterBans(
                    playerid
                );
            }

            case 1:
            {
                gSelectedMyBanType[playerid] =
                    ADMIN_MY_BANS_UCP;

                CRP_AdminShowMyUCPBans(
                    playerid
                );
            }
        }

        return 1;
    }


    // ========================================================
    // MY BANS ACTION
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MY_BANS_ACTION)
    {
        if(
            gSelectedMyBanType[playerid] ==
            ADMIN_MY_BANS_CHARACTER
        )
        {
            if(listitem == 0)
            {
                CRP_AdminMyBanAction(
                    playerid,
                    ADMIN_MY_BANS_CHARACTER,
                    ADMIN_BAN_ACTION_UNBAN
                );
            }

            return 1;
        }

        if(
            gSelectedMyBanType[playerid] ==
            ADMIN_MY_BANS_UCP
        )
        {
            switch(listitem)
            {
                case 0:
                {
                    CRP_AdminMyBanAction(
                        playerid,
                        ADMIN_MY_BANS_UCP,
                        ADMIN_BAN_ACTION_UNBLOCK
                    );
                }

                case 1:
                {
                    CRP_AdminMyBanAction(
                        playerid,
                        ADMIN_MY_BANS_UCP,
                        ADMIN_BAN_ACTION_UNBAN
                    );
                }

                case 2:
                {
                    CRP_AdminShowMyUCPBans(
                        playerid
                    );
                }
            }

            return 1;
        }

        return 1;
    }


    // ========================================================
    // MY BANS CONFIRM
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MY_BANS_CONFIRM)
    {
        if(response)
        {
            CRP_AdminConfirmMyBanAction(
                playerid
            );
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
                CRP_AdminShowReportLogs(
                    playerid
                );
            }

            case 6:
            {
                CRP_AdminShowFactionFamilyLogs(
                    playerid
                );
            }

            case 7:
            {
                CRP_AskShowLogs(playerid);
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
        if(
            !CRP_AdminCanAccessAdminSettings(playerid)
        )
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenAdminPromotion",
                    "i",
                    playerid
                );
            }

            case 1:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenHelperPromotion",
                    "i",
                    playerid
                );
            }

            case 2:
            {
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
        if(
            !CRP_AdminCanAccessMoneySettings(playerid)
        )
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
        if(
            !CRP_AdminCanAccessAdminDivision(playerid)
        )
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CRP_AdminShowFactionDivision(
                    playerid
                );
            }

            case 1:
            {
                CRP_AdminShowHouseBusiness(
                    playerid
                );
            }
        }

        return 1;
    }


    // ========================================================
    // FACTIONS / FAMILIES DIVISION
    // ========================================================

    if(dialogid == DIALOG_ADMIN_FACTION_DIV)
    {
        if(
            !CRP_AdminCanAccessAdminDivision(playerid)
        )
        {
            return 1;
        }

        switch(listitem)
        {
            case 0:
            {
                CRP_AdminShowFactionList(
                    playerid
                );
            }

            case 1:
            {
                CallRemoteFunction(
                    "CRP_AdminCommandsOpenFactionHandler",
                    "i",
                    playerid
                );
            }

            case 2:
            {
                CRP_AdminShowHandlerList(
                    playerid,
                    ADMIN_DIVISION_FACTION_FAMILY
                );
            }
        }

        return 1;
    }


    // ========================================================
    // FACTION LIST
    // ========================================================

    if(dialogid == DIALOG_ADMIN_FACTION_LIST)
    {
        if(
            !CRP_AdminCanAccessAdminDivision(playerid) &&
            !CRP_AdminIsFactionFamilyHandler(playerid)
        )
        {
            return 1;
        }

        if(
            listitem < 0 ||
            listitem > 3
        )
        {
            return 1;
        }

        gSelectedFaction[playerid] =
            listitem + 1;

        CallRemoteFunction(
            "CRP_AdminCommandsOpenFactionAction",
            "ii",
            playerid,
            gSelectedFaction[playerid]
        );

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

        if(
            listitem >= 0 &&
            listitem <= 9
        )
        {
            gSelectedFamily[playerid] =
                listitem + 1;

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
    // HOUSES / BUSINESS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_HOUSE_BUSINESS)
    {
        if(
            !CRP_AdminCanAccessAdminDivision(playerid)
        )
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
        if(
            !CRP_AdminCanAccessAdminDivision(playerid)
        )
        {
            return 1;
        }

        if(
            listitem < 0 ||
            listitem >= ADMIN_HANDLER_MAX
        )
        {
            return 1;
        }

        gSelectedHandlerTarget[playerid] =
            listitem;

        CallRemoteFunction(
            "CRP_AdminCommandsHandleHandlerSelection",
            "iii",
            playerid,
            gSelectedHandlerDivision[playerid],
            listitem
        );

        return 1;
    }


    // ========================================================
    // ASK QUEUE
    // ========================================================

    if(dialogid == DIALOG_ADMIN_ASKS)
    {
        if(
            gPlayerAdminRank[playerid] <
            ADMIN_INTERN
        )
        {
            return 1;
        }

        if(listitem < 0)
        {
            return 1;
        }

        new current = -1;
        new row = 0;

        for(new i = 0; i < gAskQueueCount; i++)
        {
            if(
                gAskQueueStatus[i] !=
                ASK_STATUS_ACTIVE
            )
            {
                continue;
            }

            if(row == listitem)
            {
                current = i;
                break;
            }

            row++;
        }

        if(current == -1)
        {
            CRP_AskOpenAdminQueue(
                playerid
            );

            return 1;
        }

        CRP_AskShowQueueDetail(
            playerid,
            current
        );

        return 1;
    }


    // ========================================================
    // ASK DETAIL
    // ========================================================

    if(dialogid == DIALOG_ADMIN_ASK_DETAIL)
    {
        if(listitem == 0)
        {
            CRP_AskShowAnswerDialog(
                playerid
            );

            return 1;
        }

        CRP_AskOpenAdminQueue(
            playerid
        );

        return 1;
    }


    // ========================================================
    // ASK ANSWER
    // ========================================================

    if(dialogid == DIALOG_ADMIN_ASK_ANSWER)
    {
        if(inputtext[0] == EOS)
        {
            CRP_AskShowAnswerDialog(
                playerid
            );

            return 1;
        }

        new index =
            gSelectedAskQueue[playerid];

        if(
            index < 0 ||
            index >= gAskQueueCount
        )
        {
            return 1;
        }

        if(
            gAskQueueStatus[index] !=
            ASK_STATUS_ACTIVE
        )
        {
            CRP_AskOpenAdminQueue(
                playerid
            );

            return 1;
        }

        CRP_AskAnswerQueue(
            playerid,
            gAskQueueID[index],
            inputtext
        );

        CRP_AskOpenAdminQueue(
            playerid
        );

        return 1;
    }


    // ========================================================
    // ASK LOGS
    // ========================================================

    if(dialogid == DIALOG_ADMIN_ASK_LOGS)
    {
        if(listitem < 0)
        {
            return 1;
        }

        new current = -1;
        new row = 0;

        for(
            new i = gAskLogCount - 1;
            i >= 0;
            i--
        )
        {
            if(
                gAskLogStatus[i] !=
                ASK_STATUS_ANSWERED &&
                gAskLogStatus[i] !=
                ASK_STATUS_EXPIRED
            )
            {
                continue;
            }

            if(row == listitem)
            {
                current = i;
                break;
            }

            row++;
        }

        if(current == -1)
        {
            CRP_AskShowLogs(
                playerid
            );

            return 1;
        }

        CRP_AskShowLogDetail(
            playerid,
            current
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
    gPlayerAdminRank[playerid] =
        ADMIN_NO_STAFF;

    gPlayerAdminDuty[playerid] =
        false;

    gPlayerAdminDutyStart[playerid] =
        0;

    gPlayerAdminDutyTotal[playerid] =
        0;

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_NONE;

    gPlayerActiveFaction[playerid] =
        ADMIN_FACTION_NONE;

    gPlayerActiveFamily[playerid] =
        ADMIN_FAMILY_NONE;

    gSelectedAdminTarget[playerid] =
        INVALID_PLAYER_ID;

    gSelectedHandlerTarget[playerid] =
        INVALID_PLAYER_ID;

    gSelectedHandlerDivision[playerid] =
        ADMIN_DIVISION_NONE;

    gSelectedFaction[playerid] =
        ADMIN_FACTION_NONE;

    gSelectedFamily[playerid] =
        ADMIN_FAMILY_NONE;

    gSelectedMyBanType[playerid] =
        ADMIN_MY_BANS_CHARACTER;

    gSelectedMyBanAction[playerid] =
        ADMIN_BAN_ACTION_NONE;

    gSelectedAskQueue[playerid] =
        -1;

    gSelectedAskLog[playerid] =
        -1;

    gAskMatchCount[playerid] =
        0;

    for(
        new i = 0;
        i < ASK_MATCH_MAX_RESULTS;
        i++
    )
    {
        gAskMatchLogIndex[playerid][i] =
            -1;

        gAskMatchScore[playerid][i] =
            0;
    }

    CRP_AdminLoadAccountIdentity(
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER DISCONNECT
// ============================================================

public OnPlayerDisconnect(
    playerid,
    reason
)
{
    if(gPlayerAdminDuty[playerid])
    {
        gPlayerAdminDutyTotal[playerid] +=
            gettime() -
            gPlayerAdminDutyStart[playerid];

        gPlayerAdminDuty[playerid] =
            false;

        gPlayerAdminDutyStart[playerid] =
            0;
    }

    /*
     * Active ASK remains in queue.
     * The player reference is invalidated,
     * but the ASK itself remains until answered
     * or expired.
     */

    for(new i = 0; i < gAskQueueCount; i++)
    {
        if(
            gAskQueuePlayerID[i] ==
            playerid
        )
        {
            gAskQueuePlayerID[i] =
                INVALID_PLAYER_ID;
        }
    }

    gPlayerAdminRank[playerid] =
        ADMIN_NO_STAFF;

    gPlayerAdminDutyTotal[playerid] =
        0;

    gPlayerAdminPanel[playerid] =
        ADMIN_PANEL_NONE;

    gPlayerActiveFaction[playerid] =
        ADMIN_FACTION_NONE;

    gPlayerActiveFamily[playerid] =
        ADMIN_FAMILY_NONE;

    gSelectedAdminTarget[playerid] =
        INVALID_PLAYER_ID;

    gSelectedHandlerTarget[playerid] =
        INVALID_PLAYER_ID;

    gSelectedHandlerDivision[playerid] =
        ADMIN_DIVISION_NONE;

    gSelectedFaction[playerid] =
        ADMIN_FACTION_NONE;

    gSelectedFamily[playerid] =
        ADMIN_FAMILY_NONE;

    gSelectedMyBanType[playerid] =
        ADMIN_MY_BANS_CHARACTER;

    gSelectedMyBanAction[playerid] =
        ADMIN_BAN_ACTION_NONE;

    gSelectedAskQueue[playerid] =
        -1;

    gSelectedAskLog[playerid] =
        -1;

    gAskMatchCount[playerid] =
        0;

    for(
        new i = 0;
        i < ASK_MATCH_MAX_RESULTS;
        i++
    )
    {
        gAskMatchLogIndex[playerid][i] =
            -1;

        gAskMatchScore[playerid][i] =
            0;
    }

    gPlayerAccountUsername[playerid][0] =
        EOS;

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("--------------------------------------------------");
    print("Crystal Roleplay Admin Panel v3.2");
    print("Admin Panel System loaded.");
    print("Command system : crp_admin_cmd.pwn");
    print("ASK system     : INTERNAL");
    print("ASK logs       : INTERNAL");
    print("ASK queue      : ENABLED");
    print("ASK expiration : 10 MINUTES");
    print("ASK Bot        : ENABLED");
    print("Archives       : REMOVED");
    print("My Bans        : ENABLED");
    print("UCP Unban      : ENABLED");
    print("UCP Unblock    : ENABLED");
    print("Admin Division : ENABLED");
    print("Handler Model  : ACCOUNT BASED");
    print("--------------------------------------------------");

    gAskQueueCount = 0;
    gAskLogCount = 0;
    gAskNextQueueID = 1;

    CRP_AskEnsureStorage();
    CRP_AskLoadCounter();
    CRP_AskLoadLogs();

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

    return CRP_AdminShowMainPanel(
        playerid
    );
}

// ============================================================
// REMOTE DUTY API
// ============================================================
//
// Command layer:
// filterscripts/features/admin/crp_admin_cmd.pwn
//
// Single source of truth:
// gPlayerAdminDuty
// ============================================================

public CRP_AdminIsOnDutyRemote(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminDuty[playerid];
}


public CRP_AdminSetDutyRemote(playerid, duty_state)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    if(duty_state)
    {
        if(gPlayerAdminRank[playerid] < ADMIN_HELPER)
        {
            return 0;
        }

        if(!gPlayerAdminDuty[playerid])
        {
            gPlayerAdminDuty[playerid] = true;
            gPlayerAdminDutyStart[playerid] = gettime();
        }

        return 1;
    }

    if(gPlayerAdminDuty[playerid])
    {
        gPlayerAdminDutyTotal[playerid] +=
            gettime() - gPlayerAdminDutyStart[playerid];

        gPlayerAdminDutyStart[playerid] = 0;
        gPlayerAdminDuty[playerid] = false;
    }

    return 1;
}

// ============================================================
// END OF FILE
// ============================================================