#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Commands System v1.2
//
// File:
// filterscripts/features/admin/crp_admin_cmd.pwn
//
// Developer:
// Muhammad Rizal
//
// Dependency:
// - crp_admin.pwn
//
// Fungsi:
// - Admin command dispatcher
// - Permission / rank validation
// - Target hierarchy protection
// - Admin duty validation
// - Admin command routing
// - Admin command logging
// - /asks command entry point
//
// CATATAN:
// - Admin Panel tetap dimiliki crp_admin.pwn
// - ASK Foundation tetap dimiliki crp_admin.pwn
// - AskBot tetap dimiliki crp_admin.pwn
// - Persistent ASK logs tetap dimiliki crp_admin.pwn
// - Money Settings TIDAK dibuat sebagai command
// - /eject bukan admin command
// - Developer tidak dapat ditargetkan admin lain
// - Admin Rank bersifat ACCOUNT-BASED
// - Handler bersifat ACCOUNT-BASED
// - /asks dapat digunakan R1+
// - /admins dapat digunakan R1+
// ============================================================


// ============================================================
// COLORS
// ============================================================

#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_GREY              0xBFC0C2FF
#define COLOR_RED               0xE74C3CFF
#define COLOR_GREEN             0x2ECC71FF
#define COLOR_YELLOW            0xF1C40FFF
#define COLOR_ORANGE            0xE67E22FF
#define COLOR_GOLD              0xD8B56AFF
#define COLOR_EMERALD           0x09261FFF


// ============================================================
// ADMIN RANK
// ============================================================

#define ADMIN_NONE              0
#define ADMIN_INTERN            1
#define ADMIN_HELPER            2
#define ADMIN_SENIOR_HELPER     3
#define ADMIN_ADMIN             4
#define ADMIN_SENIOR_ADMIN      5
#define ADMIN_SUPERVISOR        6
#define ADMIN_HIGH_ADMIN        7
#define ADMIN_DIRECTOR          8
#define ADMIN_SERVER_DIRECTOR   9
#define ADMIN_DEVELOPER         10


// ============================================================
// COMMAND RESULT
// ============================================================

#define ADMIN_CMD_FAIL          0
#define ADMIN_CMD_OK            1


// ============================================================
// COMMAND BUFFER
// ============================================================

static gAdminCommand[32];
static gAdminParams[256];


// ============================================================
// FORWARDS
// ============================================================

forward CRP_AdminCommandLog(playerid, const command[], const target[]);
forward CRP_AdminCommandMessage(playerid, const message[]);

forward CRP_AdminOpenMyBansCharacter(playerid);
forward CRP_AdminOpenMyBansUCP(playerid);


// ============================================================
// INITIALIZATION
// ============================================================

public OnFilterScriptInit()
{
    print("============================================================");
    print("Crystal Roleplay - Admin Commands System v1.2");
    print("Command layer initialized.");
    print("ASK command available for R1+.");
    print("ADMINS command available for R1+.");
    print("============================================================");

    return 1;
}


public OnFilterScriptExit()
{
    print("Crystal Roleplay - Admin Commands System unloaded.");

    return 1;
}


// ============================================================
// REMOTE ADMIN API
// ============================================================

stock CRP_AdminGetRank(playerid)
{
    return CallRemoteFunction(
        "CRP_AdminGetRank",
        "i",
        playerid
    );
}


stock bool:CRP_AdminIsStaff(playerid)
{
    return bool:CallRemoteFunction(
        "CRP_AdminIsStaffRemote",
        "i",
        playerid
    );
}


stock bool:CRP_AdminIsDeveloper(playerid)
{
    return bool:CallRemoteFunction(
        "CRP_AdminIsDeveloperRemote",
        "i",
        playerid
    );
}


stock bool:CRP_AdminCanTarget(playerid, targetid)
{
    return bool:CallRemoteFunction(
        "CRP_AdminCanTargetRemote",
        "ii",
        playerid,
        targetid
    );
}


stock CRP_AdminGetFaction(playerid)
{
    return CallRemoteFunction(
        "CRP_AdminGetFaction",
        "i",
        playerid
    );
}


stock CRP_AdminGetFamily(playerid)
{
    return CallRemoteFunction(
        "CRP_AdminGetFamily",
        "i",
        playerid
    );
}


stock CRP_AdminGetDivision(playerid)
{
    return CallRemoteFunction(
        "CRP_AdminGetDivision",
        "i",
        playerid
    );
}


stock CRP_AdminGetHandlerType(playerid)
{
    return CallRemoteFunction(
        "CRP_AdminGetHandlerType",
        "i",
        playerid
    );
}


stock CRP_AdminGetAccountUsername(
    playerid,
    output[],
    size = 64
)
{
    output[0] = EOS;

    CallRemoteFunction(
        "CRP_AdminGetAccountUsername",
        "iis",
        playerid,
        size,
        output
    );

    return 1;
}


// ============================================================
// ADMIN DUTY
// ============================================================

stock bool:CRP_AdminIsOnDuty(playerid)
{
    return bool:CallRemoteFunction(
        "CRP_AdminIsOnDutyRemote",
        "i",
        playerid
    );
}


stock CRP_AdminSetDuty(playerid, bool:state)
{
    return CallRemoteFunction(
        "CRP_AdminSetDutyRemote",
        "ii",
        playerid,
        _:state
    );
}


// ============================================================
// BASIC VALIDATION
// ============================================================

stock bool:CRP_AdminRequireStaff(
    playerid,
    minimum_rank
)
{
    if(!IsPlayerConnected(playerid))
        return false;

    if(!CRP_AdminIsStaff(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu bukan bagian dari staff."
        );

        return false;
    }

    new rank = CRP_AdminGetRank(playerid);

    if(rank < minimum_rank)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu tidak memiliki akses untuk command ini."
        );

        return false;
    }

    return true;
}


stock bool:CRP_AdminRequireDuty(
    playerid,
    minimum_rank
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        minimum_rank
    ))
    {
        return false;
    }

    if(!CRP_AdminIsOnDuty(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu harus berada dalam Admin Duty."
        );

        return false;
    }

    return true;
}


stock bool:CRP_AdminRequireTarget(
    playerid,
    targetid
)
{
    if(targetid == INVALID_PLAYER_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Player tersebut tidak ditemukan atau sudah offline."
        );

        return false;
    }

    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Player tersebut tidak ditemukan atau sudah offline."
        );

        return false;
    }

    if(playerid == targetid)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu tidak dapat menggunakan command ini kepada diri sendiri."
        );

        return false;
    }

    if(CRP_AdminIsDeveloper(targetid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Developer tidak dapat ditargetkan oleh admin lain."
        );

        return false;
    }

    if(!CRP_AdminCanTarget(
        playerid,
        targetid
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu tidak dapat menargetkan admin dengan rank yang sama atau lebih tinggi."
        );

        return false;
    }

    return true;
}


// ============================================================
// NUMERIC CHECK
// ============================================================

stock bool:CRP_AdminIsNumeric(
    const text[]
)
{
    if(!strlen(text))
        return false;

    for(new i = 0; text[i] != EOS; i++)
    {
        if(text[i] < '0' || text[i] > '9')
            return false;
    }

    return true;
}


// ============================================================
// PLAYER FINDER
// ============================================================

stock CRP_AdminFindPlayer(
    const input[]
)
{
    if(!strlen(input))
        return INVALID_PLAYER_ID;

    new targetid;

    if(CRP_AdminIsNumeric(input))
    {
        targetid = strval(input);

        if(
            targetid >= 0 &&
            targetid < MAX_PLAYERS &&
            IsPlayerConnected(targetid)
        )
        {
            return targetid;
        }
    }

    new playerName[MAX_PLAYER_NAME + 1];

    for(
        new playerid = 0;
        playerid < MAX_PLAYERS;
        playerid++
    )
    {
        if(!IsPlayerConnected(playerid))
            continue;

        GetPlayerName(
            playerid,
            playerName,
            sizeof(playerName)
        );

        if(!strcmp(
            playerName,
            input,
            true
        ))
        {
            return playerid;
        }
    }

    return INVALID_PLAYER_ID;
}


// ============================================================
// TOKEN PARSER
// ============================================================

stock CRP_AdminGetToken(
    const source[],
    index,
    output[],
    size
)
{
    output[0] = EOS;

    new current;
    new start;
    new length = strlen(source);

    for(new i = 0; i <= length; i++)
    {
        if(
            source[i] == ' ' ||
            source[i] == EOS
        )
        {
            if(current == index)
            {
                new tokenLength = i - start;

                if(tokenLength >= size)
                    tokenLength = size - 1;

                if(tokenLength <= 0)
                    return 0;

                strmid(
                    output,
                    source,
                    start,
                    start + tokenLength,
                    size
                );

                return 1;
            }

            current++;

            while(
                source[i + 1] == ' '
            )
            {
                i++;
            }

            start = i + 1;
        }
    }

    return 0;
}


// ============================================================
// REST PARSER
// ============================================================

stock CRP_AdminGetRest(
    const source[],
    startIndex,
    output[],
    size
)
{
    output[0] = EOS;

    new current;
    new position;
    new length = strlen(source);

    for(new i = 0; i <= length; i++)
    {
        if(
            source[i] == ' ' ||
            source[i] == EOS
        )
        {
            if(current == startIndex)
            {
                while(source[position] == ' ')
                    position++;

                strmid(
                    output,
                    source,
                    position,
                    length,
                    size
                );

                return 1;
            }

            current++;

            while(
                source[i + 1] == ' '
            )
            {
                i++;
            }

            position = i + 1;
        }
    }

    return 0;
}


// ============================================================
// ADMIN COMMAND LOG
// ============================================================

stock CRP_AdminWriteLog(
    playerid,
    const command[],
    const target[]
)
{
    new username[64];

    CRP_AdminGetAccountUsername(
        playerid,
        username,
        sizeof(username)
    );

    new line[256];

    format(
        line,
        sizeof(line),
        "AdminCmd: %s used /%s target=%s",
        username,
        command,
        target
    );

    CallRemoteFunction(
        "CRP_AdminCommandLog",
        "is",
        playerid,
        line
    );

    return 1;
}


// ============================================================
// /AP
// ============================================================

stock CRP_AdminCommand_AP(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminOpenPanel",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// /ASKS
//
// FINAL PERMISSION:
// R1+
//
// ASK Foundation:
// crp_admin.pwn
// ============================================================

stock CRP_AdminCommand_Asks(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    /*
        Primary API expected from crp_admin.pwn.
        Fallback compatibility is intentionally not duplicated here.
    */
    CallRemoteFunction(
        "CRP_AskOpenAdminQueue",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// /A
// ============================================================

stock CRP_AdminCommand_A(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    if(!strlen(params))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /a [message]"
        );

        return 1;
    }

    new username[64];

    CRP_AdminGetAccountUsername(
        playerid,
        username,
        sizeof(username)
    );

    new message[256];

    format(
        message,
        sizeof(message),
        "{D8B56A}[%s] {FFFFFF}%s",
        username,
        params
    );

    for(
        new i = 0;
        i < MAX_PLAYERS;
        i++
    )
    {
        if(!IsPlayerConnected(i))
            continue;

        if(!CRP_AdminIsStaff(i))
            continue;

        SendClientMessage(
            i,
            COLOR_WHITE,
            message
        );
    }

    CRP_AdminWriteLog(
        playerid,
        "a",
        params
    );

    return 1;
}


// ============================================================
// /AHELP
// ============================================================

stock CRP_AdminCommand_AHelp(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    new rank = CRP_AdminGetRank(playerid);

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== CRYSTAL ROLEPLAY ADMIN HELP =========="
    );

    // --------------------------------------------------------
    // R1
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Basic: /ap /asks /a /ahelp /admins"
    );

    if(rank >= ADMIN_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Duty: /aon /aoff"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Inspection: /check /ainspect /checkgun /checkweapons /checkwarn /checkjail /checkveh"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Teleport: /goto /gethere /p2p /sendtols /mark /gotomark /getpos /gotopos /gotocar /getcar /gettocar"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Control: /freeze /unfreeze /slap /heal /sethp /setarmor"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Punishment: /warn /unwarn /kick /jail /ojail /jailed /ban /tban /blockuser"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Investigation: /checkip /ocheckip /ip"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Utility: /flip /afrisk /checkmask"
        );
    }

    if(rank >= ADMIN_SENIOR_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Vehicle: /fixveh /respawncar /destroycar /respawnallcars /afill"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Movement: /fly"
        );
    }

    if(rank >= ADMIN_ADMIN)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Character: /setskin"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Ban Management: /unban /unblockuser"
        );
    }

    if(rank >= ADMIN_SENIOR_ADMIN)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Server: /announce"
        );
    }

    if(rank >= ADMIN_SUPERVISOR)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Chat: /cc /clearchat /giveweapon"
        );
    }

    if(rank >= ADMIN_HIGH_ADMIN)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Character: /changename /explode"
        );
    }

    if(rank >= ADMIN_DIRECTOR)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Character: /setjob /setage"
        );
    }

    if(rank >= ADMIN_SERVER_DIRECTOR)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Character: /charremove"
        );
    }

    if(rank >= ADMIN_DEVELOPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Server: /settime /gmx /reloadmap"
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "================================================="
    );

    return 1;
}


// ============================================================
// /ADMINS
//
// FINAL PERMISSION:
// R1+
// ============================================================

stock CRP_AdminCommand_Admins(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== ONLINE ADMIN STAFF =========="
    );

    new name[MAX_PLAYER_NAME + 1];
    new line[160];

    for(
        new i = 0;
        i < MAX_PLAYERS;
        i++
    )
    {
        if(!IsPlayerConnected(i))
            continue;

        if(!CRP_AdminIsStaff(i))
            continue;

        GetPlayerName(
            i,
            name,
            sizeof(name)
        );

        new rank = CRP_AdminGetRank(i);

        format(
            line,
            sizeof(line),
            "%s - Rank %d - %s",
            name,
            rank,
            CRP_AdminIsOnDuty(i)
                ? ("ON DUTY")
                : ("OFF DUTY")
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            line
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========================================="
    );

    CRP_AdminWriteLog(
        playerid,
        "admins",
        "self"
    );

    return 1;
}


// ============================================================
// /AON
// FINAL: R2+
// ============================================================

stock CRP_AdminCommand_AOn(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    if(CRP_AdminIsOnDuty(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu sudah berada dalam Admin Duty."
        );

        return 1;
    }

    CRP_AdminSetDuty(
        playerid,
        true
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Admin Duty ON."
    );

    CRP_AdminWriteLog(
        playerid,
        "aon",
        "self"
    );

    return 1;
}


// ============================================================
// /AOFF
// FINAL: R2+
// ============================================================

stock CRP_AdminCommand_AOff(
    playerid
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    if(!CRP_AdminIsOnDuty(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu sedang tidak berada dalam Admin Duty."
        );

        return 1;
    }

    CRP_AdminSetDuty(
        playerid,
        false
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Admin Duty OFF."
    );

    CRP_AdminWriteLog(
        playerid,
        "aoff",
        "self"
    );

    return 1;
}


// ============================================================
// GENERIC TARGET EXECUTOR
//
// Digunakan untuk command yang logic utamanya berada di
// crp_admin.pwn.
//
// Semua command tetap melakukan:
// - Rank validation
// - Duty validation
// - Target validation
// - Target hierarchy
// - Developer protection
// ============================================================

stock CRP_AdminExecuteTargetCommand(
    playerid,
    const params[],
    minimum_rank,
    const usage[],
    const remote_function[],
    const command_name[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        minimum_rank
    ))
    {
        return 1;
    }

    new token[32];

    if(!CRP_AdminGetToken(
        params,
        0,
        token,
        sizeof(token)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            usage
        );

        return 1;
    }

    new targetid = CRP_AdminFindPlayer(token);

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        remote_function,
        "ii",
        playerid,
        targetid
    );

    CRP_AdminWriteLog(
        playerid,
        command_name,
        token
    );

    return 1;
}


// ============================================================
// INSPECTION
// ============================================================

stock CRP_AdminCommand_Check(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /check [ID]",
        "CRP_AdminCommandCheck",
        "check"
    );
}


stock CRP_AdminCommand_AInspect(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /ainspect [ID]",
        "CRP_AdminCommandAInspect",
        "ainspect"
    );
}


stock CRP_AdminCommand_CheckGun(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkgun [ID]",
        "CRP_AdminCommandCheckGun",
        "checkgun"
    );
}


stock CRP_AdminCommand_CheckWeapons(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkweapons [ID]",
        "CRP_AdminCommandCheckWeapons",
        "checkweapons"
    );
}


stock CRP_AdminCommand_CheckWarn(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkwarn [ID]",
        "CRP_AdminCommandCheckWarn",
        "checkwarn"
    );
}


stock CRP_AdminCommand_CheckJail(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkjail [ID]",
        "CRP_AdminCommandCheckJail",
        "checkjail"
    );
}


stock CRP_AdminCommand_CheckVeh(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkveh [ID]",
        "CRP_AdminCommandCheckVeh",
        "checkveh"
    );
}


stock CRP_AdminCommand_Afrisk(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /afrisk [ID]",
        "CRP_AdminCommandAfrisk",
        "afrisk"
    );
}


stock CRP_AdminCommand_CheckMask(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /checkmask [ID]",
        "CRP_AdminCommandCheckMask",
        "checkmask"
    );
}


// ============================================================
// TELEPORT
// ============================================================

stock CRP_AdminCommand_Goto(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /goto [ID]",
        "CRP_AdminCommandGoto",
        "goto"
    );
}


stock CRP_AdminCommand_GetHere(
    playerid,
    const params[]
)
{
    return CRP_AdminExecuteTargetCommand(
        playerid,
        params,
        ADMIN_HELPER,
        "USAGE: /gethere [ID]",
        "CRP_AdminCommandGetHere",
        "gethere"
    );
}


// ============================================================
// VEHICLE
// ============================================================

// /flip
// FINAL: R2+

stock CRP_AdminCommand_Flip(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandFlip",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "flip",
        "self"
    );

    return 1;
}


// /fixveh
// FINAL: R3+

stock CRP_AdminCommand_FixVeh(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandFixVeh",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "fixveh",
        "self"
    );

    return 1;
}


// /respawncar
// FINAL: R3+

stock CRP_AdminCommand_RespawnCar(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandRespawnCar",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "respawncar",
        "self"
    );

    return 1;
}


// /destroycar
// FINAL: R3+

stock CRP_AdminCommand_DestroyCar(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandDestroyCar",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "destroycar",
        "self"
    );

    return 1;
}


// /respawnallcars
// FINAL: R3+

stock CRP_AdminCommand_RespawnAllCars(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandRespawnAllCars",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "respawnallcars",
        "server"
    );

    return 1;
}


// /afill
// FINAL: R3+

stock CRP_AdminCommand_Afill(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandAfill",
        "i",
        playerid
    );

    CRP_AdminWriteLog(
        playerid,
        "afill",
        "self"
    );

    return 1;
}


// ============================================================
// CHARACTER
// ============================================================

// /setskin
// FINAL: R4+

stock CRP_AdminCommand_SetSkin(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    new targetToken[32];
    new skinToken[16];

    if(!CRP_AdminGetToken(
        params,
        0,
        targetToken,
        sizeof(targetToken)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /setskin [ID] [skin]"
        );

        return 1;
    }

    if(!CRP_AdminGetToken(
        params,
        1,
        skinToken,
        sizeof(skinToken)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /setskin [ID] [skin]"
        );

        return 1;
    }

    new targetid = CRP_AdminFindPlayer(
        targetToken
    );

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    new skin = strval(skinToken);

    if(skin < 0 || skin > 311)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Skin ID harus berada pada range 0-311."
        );

        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandSetSkin",
        "iii",
        playerid,
        targetid,
        skin
    );

    CRP_AdminWriteLog(
        playerid,
        "setskin",
        targetToken
    );

    return 1;
}


// /charremove
// FINAL: R9-R10

stock CRP_AdminCommand_CharRemove(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SERVER_DIRECTOR
    ))
    {
        return 1;
    }

    if(!strlen(params))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /charremove [character]"
        );

        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandCharRemove",
        "is",
        playerid,
        params
    );

    CRP_AdminWriteLog(
        playerid,
        "charremove",
        params
    );

    return 1;
}


// ============================================================
// COMMAND ROUTER
// ============================================================

stock bool:CRP_AdminCommandMatch(
    const input[],
    const command[]
)
{
    return bool:(!strcmp(
        input,
        command,
        true
    ));
}


// ============================================================
// ON PLAYER COMMAND TEXT
// ============================================================

public OnPlayerCommandText(
    playerid,
    cmdtext[]
)
{
    if(cmdtext[0] != '/')
        return 0;

    gAdminCommand[0] = EOS;
    gAdminParams[0] = EOS;

    new length = strlen(cmdtext);

    if(length <= 1)
        return 0;

    new commandEnd = -1;

    for(new i = 1; i < length; i++)
    {
        if(cmdtext[i] == ' ')
        {
            commandEnd = i;
            break;
        }
    }

    if(commandEnd == -1)
    {
        strmid(
            gAdminCommand,
            cmdtext,
            1,
            length,
            sizeof(gAdminCommand)
        );
    }
    else
    {
        strmid(
            gAdminCommand,
            cmdtext,
            1,
            commandEnd,
            sizeof(gAdminCommand)
        );

        strmid(
            gAdminParams,
            cmdtext,
            commandEnd + 1,
            length,
            sizeof(gAdminParams)
        );
    }

    // --------------------------------------------------------
    // BASIC ADMIN
    // --------------------------------------------------------

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "ap"
    ))
    {
        return CRP_AdminCommand_AP(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "asks"
    ))
    {
        return CRP_AdminCommand_Asks(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "a"
    ))
    {
        return CRP_AdminCommand_A(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "ahelp"
    ))
    {
        return CRP_AdminCommand_AHelp(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "admins"
    ))
    {
        return CRP_AdminCommand_Admins(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "aon"
    ))
    {
        return CRP_AdminCommand_AOn(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "aoff"
    ))
    {
        return CRP_AdminCommand_AOff(
            playerid
        );
    }

    // --------------------------------------------------------
    // INSPECTION
    // --------------------------------------------------------

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "check"
    ))
    {
        return CRP_AdminCommand_Check(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "ainspect"
    ))
    {
        return CRP_AdminCommand_AInspect(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkgun"
    ))
    {
        return CRP_AdminCommand_CheckGun(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkweapons"
    ))
    {
        return CRP_AdminCommand_CheckWeapons(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkwarn"
    ))
    {
        return CRP_AdminCommand_CheckWarn(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkjail"
    ))
    {
        return CRP_AdminCommand_CheckJail(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkveh"
    ))
    {
        return CRP_AdminCommand_CheckVeh(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "afrisk"
    ))
    {
        return CRP_AdminCommand_Afrisk(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "checkmask"
    ))
    {
        return CRP_AdminCommand_CheckMask(
            playerid,
            gAdminParams
        );
    }

    // --------------------------------------------------------
    // TELEPORT
    // --------------------------------------------------------

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "goto"
    ))
    {
        return CRP_AdminCommand_Goto(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "gethere"
    ))
    {
        return CRP_AdminCommand_GetHere(
            playerid,
            gAdminParams
        );
    }

    // --------------------------------------------------------
    // VEHICLE
    // --------------------------------------------------------

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "flip"
    ))
    {
        return CRP_AdminCommand_Flip(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "fixveh"
    ))
    {
        return CRP_AdminCommand_FixVeh(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "respawncar"
    ))
    {
        return CRP_AdminCommand_RespawnCar(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "destroycar"
    ))
    {
        return CRP_AdminCommand_DestroyCar(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "respawnallcars"
    ))
    {
        return CRP_AdminCommand_RespawnAllCars(
            playerid
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "afill"
    ))
    {
        return CRP_AdminCommand_Afill(
            playerid
        );
    }

    // --------------------------------------------------------
    // CHARACTER
    // --------------------------------------------------------

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "setskin"
    ))
    {
        return CRP_AdminCommand_SetSkin(
            playerid,
            gAdminParams
        );
    }

    if(CRP_AdminCommandMatch(
        gAdminCommand,
        "charremove"
    ))
    {
        return CRP_AdminCommand_CharRemove(
            playerid,
            gAdminParams
        );
    }

    return 0;
}