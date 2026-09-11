#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Commands System v2.0
//
// File:
// filterscripts/features/admin/crp_admin_cmd.pwn
//
// Developer:
// Muhammad Rizal
//
// Architecture:
// - crp_admin.pwn         = Admin Foundation
// - crp_admin_cmd.pwn     = Command Layer
// - crp_admin_actions.pwn = Admin Actions Backend
//
// Fokus v2.0:
// - Account-based admin identity
// - Account-based admin rank
// - Admin Duty bridge
// - Target hierarchy protection
// - Developer protection
// - Admin command dispatcher
// - Admin action routing
//
// ACTION BACKEND:
// - Kick
// - Ban / OBan / Unban
// - Mute / Unmute
// - Warn / Unwarn
// - Jail / OJail / Unjail
// - TBan
// - BlockUser / Unblock
//
// Catatan:
// - Tidak ada crp_admin_logs.pwn
// - Archives tidak digunakan
// - Money Settings bukan command
// - /eject bukan admin command
// - Action logic tidak disimpan di file ini
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
// GENERAL
// ============================================================

#define INVALID_PLAYER_ID       65535
#define INVALID_VEHICLE_ID      0

#define CRP_ADMIN_MAX_REASON    192
#define CRP_ADMIN_MAX_NAME      64


// ============================================================
// FORWARDS
// ============================================================

forward CRP_AdminCommandLog(playerid, const command[], const target[]);


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("============================================================");
    print("Crystal Roleplay - Admin Commands System v2.0");
    print("Command Layer initialized.");
    print("Admin Foundation bridge: crp_admin.pwn");
    print("Admin Actions bridge: crp_admin_actions.pwn");
    print("Account-based admin identity enabled.");
    print("Account-based admin rank enabled.");
    print("Target hierarchy protection enabled.");
    print("Developer protection enabled.");
    print("============================================================");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

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


stock CRP_AdminSetDuty(
    playerid,
    bool:state
)
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
// STRING UTILITIES
// ============================================================

stock bool:CRP_IsNumeric(
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


stock CRP_AdminGetToken(
    const source[],
    index,
    output[],
    size
)
{
    new current = 0;
    new position = 0;
    new length = strlen(source);

    output[0] = EOS;

    while(position < length)
    {
        while(
            source[position] == ' ' ||
            source[position] == '\t'
        )
        {
            position++;
        }

        if(position >= length)
            break;

        new start = position;

        while(
            source[position] != ' ' &&
            source[position] != '\t' &&
            source[position] != EOS
        )
        {
            position++;
        }

        if(current == index)
        {
            new tokenLength = position - start;

            if(tokenLength >= size)
                tokenLength = size - 1;

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
    }

    return 0;
}


stock CRP_AdminGetRest(
    const source[],
    startIndex,
    output[],
    size
)
{
    new current = 0;
    new position = 0;
    new length = strlen(source);

    output[0] = EOS;

    while(position < length)
    {
        while(
            source[position] == ' ' ||
            source[position] == '\t'
        )
        {
            position++;
        }

        if(position >= length)
            break;

        new start = position;

        while(
            source[position] != ' ' &&
            source[position] != '\t' &&
            source[position] != EOS
        )
        {
            position++;
        }

        if(current == startIndex)
        {
            while(
                source[start] == ' ' ||
                source[start] == '\t'
            )
            {
                start++;
            }

            strmid(
                output,
                source,
                start,
                length,
                size
            );

            return 1;
        }

        current++;
    }

    return 0;
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

    if(CRP_IsNumeric(input))
    {
        new targetid = strval(input);

        if(
            targetid >= 0 &&
            targetid < MAX_PLAYERS &&
            IsPlayerConnected(targetid)
        )
        {
            return targetid;
        }
    }

    new name[MAX_PLAYER_NAME + 1];

    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if(!IsPlayerConnected(playerid))
            continue;

        GetPlayerName(
            playerid,
            name,
            sizeof(name)
        );

        if(!strcmp(
            name,
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
// VEHICLE FINDER
// ============================================================

stock CRP_AdminFindVehicle(
    playerid,
    const params[]
)
{
    new token[32];

    if(
        CRP_AdminGetToken(
            params,
            0,
            token,
            sizeof(token)
        )
    )
    {
        if(CRP_IsNumeric(token))
        {
            new vehicleid = strval(token);

            if(
                vehicleid > 0 &&
                vehicleid < MAX_VEHICLES &&
                IsValidVehicle(vehicleid)
            )
            {
                return vehicleid;
            }
        }
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if(
        vehicleid > 0 &&
        IsValidVehicle(vehicleid)
    )
    {
        return vehicleid;
    }

    return INVALID_VEHICLE_ID;
}


// ============================================================
// COMMAND LOG
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
// ACTION BACKEND BRIDGE
//
// Semua action di bawah ini adalah milik
// crp_admin_actions.pwn.
//
// crp_admin_cmd.pwn hanya melakukan:
// 1. Parse
// 2. Permission
// 3. Target validation
// 4. Routing
//
// ============================================================


// ============================================================
// KICK
// ============================================================

stock CRP_AdminAction_Kick(
    playerid,
    targetid,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionKick",
        "iis",
        playerid,
        targetid,
        reason
    );
}


// ============================================================
// BAN
// ============================================================

stock CRP_AdminAction_Ban(
    playerid,
    targetid,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionBan",
        "iis",
        playerid,
        targetid,
        reason
    );
}


// ============================================================
// OFFLINE BAN
// ============================================================

stock CRP_AdminAction_OfflineBan(
    playerid,
    const character[],
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionOfflineBan",
        "iss",
        playerid,
        character,
        reason
    );
}


// ============================================================
// UNBAN
// ============================================================

stock CRP_AdminAction_Unban(
    playerid,
    const character[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionUnban",
        "is",
        playerid,
        character
    );
}


// ============================================================
// MUTE
// ============================================================

stock CRP_AdminAction_Mute(
    playerid,
    targetid
)
{
    return CallRemoteFunction(
        "CRP_AdminActionMute",
        "ii",
        playerid,
        targetid
    );
}


// ============================================================
// UNMUTE
// ============================================================

stock CRP_AdminAction_Unmute(
    playerid,
    targetid
)
{
    return CallRemoteFunction(
        "CRP_AdminActionUnmute",
        "ii",
        playerid,
        targetid
    );
}


// ============================================================
// WARN
// ============================================================

stock CRP_AdminAction_Warn(
    playerid,
    targetid,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionWarn",
        "iis",
        playerid,
        targetid,
        reason
    );
}


// ============================================================
// UNWARN
// ============================================================

stock CRP_AdminAction_Unwarn(
    playerid,
    targetid
)
{
    return CallRemoteFunction(
        "CRP_AdminActionUnwarn",
        "ii",
        playerid,
        targetid
    );
}


// ============================================================
// JAIL
// ============================================================

stock CRP_AdminAction_Jail(
    playerid,
    targetid,
    minutes,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionJail",
        "iiis",
        playerid,
        targetid,
        minutes,
        reason
    );
}


// ============================================================
// OFFLINE JAIL
// ============================================================

stock CRP_AdminAction_OfflineJail(
    playerid,
    const character[],
    minutes,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionOfflineJail",
        "iiss",
        playerid,
        character,
        minutes,
        reason
    );
}


// ============================================================
// UNJAIL
// ============================================================

stock CRP_AdminAction_Unjail(
    playerid,
    targetid
)
{
    return CallRemoteFunction(
        "CRP_AdminActionUnjail",
        "ii",
        playerid,
        targetid
    );
}


// ============================================================
// TEMPORARY BAN
// ============================================================

stock CRP_AdminAction_TBan(
    playerid,
    targetid,
    minutes,
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionTBan",
        "iiis",
        playerid,
        targetid,
        minutes,
        reason
    );
}


// ============================================================
// ACCOUNT / UCP BLOCK
// ============================================================

stock CRP_AdminAction_BlockUser(
    playerid,
    const username[],
    const reason[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionBlockUser",
        "iss",
        playerid,
        username,
        reason
    );
}


stock CRP_AdminAction_Unblock(
    playerid,
    const username[]
)
{
    return CallRemoteFunction(
        "CRP_AdminActionUnblock",
        "is",
        playerid,
        username
    );
}


// ============================================================
// /AP
// R1+
// ============================================================

stock CRP_AdminCommand_AP(playerid)
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
// R1+
// ============================================================

stock CRP_AdminCommand_Asks(playerid)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_INTERN
    ))
    {
        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminOpenAskPanel",
        "i",
        playerid
    );

    return 1;
}


// ============================================================
// /A
// R1+
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

    for(new i = 0; i < MAX_PLAYERS; i++)
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

    return 1;
}


// ============================================================
// /ADMINS
// R1+
// ============================================================

stock CRP_AdminCommand_Admins(playerid)
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
        "========== CRYSTAL ROLEPLAY ADMIN STAFF =========="
    );

    new name[MAX_PLAYER_NAME + 1];
    new username[64];
    new line[192];

    for(new i = 0; i < MAX_PLAYERS; i++)
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

        CRP_AdminGetAccountUsername(
            i,
            username,
            sizeof(username)
        );

        new rank = CRP_AdminGetRank(i);

        format(
            line,
            sizeof(line),
            "%s | Account: %s | R%d | %s",
            name,
            username,
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
        "================================================="
    );

    return 1;
}


// ============================================================
// /AON
// R2+
// ============================================================

stock CRP_AdminCommand_AOn(playerid)
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

    if(!CRP_AdminSetDuty(
        playerid,
        true
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Admin Duty gagal diaktifkan."
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Admin Duty ON."
    );

    return 1;
}


// ============================================================
// /AOFF
// R2+
// ============================================================

stock CRP_AdminCommand_AOff(playerid)
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

    if(!CRP_AdminSetDuty(
        playerid,
        false
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Admin Duty gagal dinonaktifkan."
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Admin Duty OFF."
    );

    return 1;
}


// ============================================================
// /CHECK
// R2+
// ============================================================

stock CRP_AdminCommand_Check(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /check [ID]"
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
        "CRP_AdminCommandCheck",
        "ii",
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /AINSPECT
// R2+
// ============================================================

stock CRP_AdminCommand_AInspect(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /ainspect [ID]"
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
        "CRP_AdminCommandAInspect",
        "ii",
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /GOTO
// R2+
// ============================================================

stock CRP_AdminCommand_Goto(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /goto [ID]"
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

    new Float:x;
    new Float:y;
    new Float:z;

    GetPlayerPos(
        targetid,
        x,
        y,
        z
    );

    SetPlayerInterior(
        playerid,
        GetPlayerInterior(targetid)
    );

    SetPlayerVirtualWorld(
        playerid,
        GetPlayerVirtualWorld(targetid)
    );

    SetPlayerPos(
        playerid,
        x + 1.0,
        y,
        z
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kamu telah teleport ke player tersebut."
    );

    return 1;
}


// ============================================================
// /GETHERE
// R2+
// ============================================================

stock CRP_AdminCommand_GetHere(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /gethere [ID]"
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

    new Float:x;
    new Float:y;
    new Float:z;

    GetPlayerPos(
        playerid,
        x,
        y,
        z
    );

    SetPlayerInterior(
        targetid,
        GetPlayerInterior(playerid)
    );

    SetPlayerVirtualWorld(
        targetid,
        GetPlayerVirtualWorld(playerid)
    );

    SetPlayerPos(
        targetid,
        x + 1.0,
        y,
        z
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Player berhasil dipindahkan ke posisi kamu."
    );

    SendClientMessage(
        targetid,
        COLOR_YELLOW,
        "AdminCmd: Kamu telah dipindahkan oleh admin."
    );

    return 1;
}


// ============================================================
// /FLIP
// R2+
// ============================================================

stock CRP_AdminCommand_Flip(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new vehicleid = CRP_AdminFindVehicle(
        playerid,
        params
    );

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /flip [vehicleid] - kosongkan ID jika sedang berada di kendaraan."
        );

        return 1;
    }

    new Float:x;
    new Float:y;
    new Float:z;
    new Float:angle;

    GetVehiclePos(
        vehicleid,
        x,
        y,
        z
    );

    GetVehicleZAngle(
        vehicleid,
        angle
    );

    SetVehiclePos(
        vehicleid,
        x,
        y,
        z + 0.5
    );

    SetVehicleZAngle(
        vehicleid,
        angle
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil dibalikkan."
    );

    return 1;
}


// ============================================================
// /AFRISK
// R2+
// ============================================================

stock CRP_AdminCommand_AFrisk(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /afrisk [ID]"
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
        "CRP_AdminCommandAFRisk",
        "ii",
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /CHECKMASK
// R2+
// ============================================================

stock CRP_AdminCommand_CheckMask(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /checkmask [ID]"
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
        "CRP_AdminCommandCheckMask",
        "ii",
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// VEHICLE COMMANDS
// ============================================================


// /FIXVEH R3+
stock CRP_AdminCommand_FixVeh(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    new vehicleid = CRP_AdminFindVehicle(
        playerid,
        params
    );

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /fixveh [vehicleid]"
        );

        return 1;
    }

    RepairVehicle(vehicleid);

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil diperbaiki."
    );

    return 1;
}


// /RESPAWNCAR R3+
stock CRP_AdminCommand_RespawnCar(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    new vehicleid = CRP_AdminFindVehicle(
        playerid,
        params
    );

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /respawncar [vehicleid]"
        );

        return 1;
    }

    SetVehicleToRespawn(vehicleid);

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil di-respawn."
    );

    return 1;
}


// /DESTROYCAR R3+
stock CRP_AdminCommand_DestroyCar(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    new vehicleid = CRP_AdminFindVehicle(
        playerid,
        params
    );

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /destroycar [vehicleid]"
        );

        return 1;
    }

    if(IsPlayerInVehicle(
        playerid,
        vehicleid
    ))
    {
        RemovePlayerFromVehicle(playerid);
    }

    DestroyVehicle(vehicleid);

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil dihapus dari server."
    );

    return 1;
}


// /RESPAWNALLCARS R3+
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

    for(
        new vehicleid = 1;
        vehicleid < MAX_VEHICLES;
        vehicleid++
    )
    {
        if(!IsValidVehicle(vehicleid))
            continue;

        SetVehicleToRespawn(vehicleid);
    }

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Seluruh kendaraan valid berhasil di-respawn."
    );

    return 1;
}


// /AFILL R3+
stock CRP_AdminCommand_AFill(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_SENIOR_HELPER
    ))
    {
        return 1;
    }

    new vehicleid = CRP_AdminFindVehicle(
        playerid,
        params
    );

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /afill [vehicleid]"
        );

        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminCommandAFill",
        "ii",
        playerid,
        vehicleid
    );

    return 1;
}


// ============================================================
// /SETSKIN
// R4+
// ============================================================

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
    new skinToken[32];

    if(
        !CRP_AdminGetToken(
            params,
            0,
            targetToken,
            sizeof(targetToken)
        ) ||
        !CRP_AdminGetToken(
            params,
            1,
            skinToken,
            sizeof(skinToken)
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /setskin [ID] [skinid]"
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

    if(!CRP_IsNumeric(skinToken))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Skin ID harus berupa angka."
        );

        return 1;
    }

    new skinid = strval(skinToken);

    if(
        skinid < 0 ||
        skinid > 311
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Skin ID harus berada pada range 0-311."
        );

        return 1;
    }

    SetPlayerSkin(
        targetid,
        skinid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Skin player berhasil diubah."
    );

    SendClientMessage(
        targetid,
        COLOR_YELLOW,
        "AdminCmd: Skin kamu telah diubah oleh admin."
    );

    return 1;
}


// ============================================================
// /CHARREMOVE
// R9-R10
// ============================================================

stock CRP_AdminCommand_CharRemove(
    playerid,
    const params[]
)
{
    new rank = CRP_AdminGetRank(playerid);

    if(
        rank < ADMIN_SERVER_DIRECTOR ||
        rank > ADMIN_DEVELOPER
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: /charremove hanya tersedia untuk R9-R10."
        );

        return 1;
    }

    if(!CRP_AdminIsStaff(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu bukan bagian dari staff."
        );

        return 1;
    }

    new character[64];

    if(!CRP_AdminGetToken(
        params,
        0,
        character,
        sizeof(character)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /charremove [Firstname_Lastname]"
        );

        return 1;
    }

    CallRemoteFunction(
        "CRP_AdminActionCharacterRemove",
        "is",
        playerid,
        character
    );

    return 1;
}


// ============================================================
// ADMIN ACTION COMMANDS
// ============================================================


// ============================================================
// /KICK
// R2+
// ============================================================

stock CRP_AdminCommand_Kick(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new targetToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

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
            "USAGE: /kick [ID] [reason]"
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        1,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /kick [ID] [reason]"
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

    CRP_AdminAction_Kick(
        playerid,
        targetid,
        reason
    );

    return 1;
}


// ============================================================
// /BAN
// R2+
// ============================================================

stock CRP_AdminCommand_Ban(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new targetToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

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
            "USAGE: /ban [ID] [reason]"
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        1,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /ban [ID] [reason]"
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

    CRP_AdminAction_Ban(
        playerid,
        targetid,
        reason
    );

    return 1;
}


// ============================================================
// /OBAN
// R2+
// Offline Character Ban
// ============================================================

stock CRP_AdminCommand_OBan(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new character[64];
    new reason[CRP_ADMIN_MAX_REASON];

    if(!CRP_AdminGetToken(
        params,
        0,
        character,
        sizeof(character)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /oban [Firstname_Lastname] [reason]"
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        1,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /oban [Firstname_Lastname] [reason]"
        );

        return 1;
    }

    CRP_AdminAction_OfflineBan(
        playerid,
        character,
        reason
    );

    return 1;
}


// ============================================================
// /UNBAN
// R2+
// Character Ban
// ============================================================

stock CRP_AdminCommand_Unban(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new character[64];

    if(!CRP_AdminGetToken(
        params,
        0,
        character,
        sizeof(character)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /unban [Firstname_Lastname]"
        );

        return 1;
    }

    CRP_AdminAction_Unban(
        playerid,
        character
    );

    return 1;
}


// ============================================================
// /MUTE
// R2+
// ============================================================

stock CRP_AdminCommand_Mute(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /mute [ID]"
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

    CRP_AdminAction_Mute(
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /UNMUTE
// R2+
// ============================================================

stock CRP_AdminCommand_Unmute(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /unmute [ID]"
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

    CRP_AdminAction_Unmute(
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /WARN
// R2+
// ============================================================

stock CRP_AdminCommand_Warn(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new targetToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

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
            "USAGE: /warn [ID] [reason]"
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        1,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /warn [ID] [reason]"
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

    CRP_AdminAction_Warn(
        playerid,
        targetid,
        reason
    );

    return 1;
}


// ============================================================
// /UNWARN
// R2+
// ============================================================

stock CRP_AdminCommand_Unwarn(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /unwarn [ID]"
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

    CRP_AdminAction_Unwarn(
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /JAIL
// R2+
// Online Character Jail
// ============================================================

stock CRP_AdminCommand_Jail(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new targetToken[32];
    new minuteToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

    if(
        !CRP_AdminGetToken(
            params,
            0,
            targetToken,
            sizeof(targetToken)
        ) ||
        !CRP_AdminGetToken(
            params,
            1,
            minuteToken,
            sizeof(minuteToken)
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /jail [ID] [minutes] [reason]"
        );

        return 1;
    }

    if(!CRP_IsNumeric(minuteToken))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi jail harus berupa angka."
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        2,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /jail [ID] [minutes] [reason]"
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

    new minutes = strval(minuteToken);

    if(minutes <= 0)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi jail harus lebih dari 0 menit."
        );

        return 1;
    }

    CRP_AdminAction_Jail(
        playerid,
        targetid,
        minutes,
        reason
    );

    return 1;
}


// ============================================================
// /OJAIL
// R2+
// Offline Character Jail
// ============================================================

stock CRP_AdminCommand_OJail(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new character[64];
    new minuteToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

    if(
        !CRP_AdminGetToken(
            params,
            0,
            character,
            sizeof(character)
        ) ||
        !CRP_AdminGetToken(
            params,
            1,
            minuteToken,
            sizeof(minuteToken)
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /ojail [Firstname_Lastname] [minutes] [reason]"
        );

        return 1;
    }

    if(!CRP_IsNumeric(minuteToken))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi jail harus berupa angka."
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        2,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /ojail [Firstname_Lastname] [minutes] [reason]"
        );

        return 1;
    }

    new minutes = strval(minuteToken);

    if(minutes <= 0)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi jail harus lebih dari 0 menit."
        );

        return 1;
    }

    CRP_AdminAction_OfflineJail(
        playerid,
        character,
        minutes,
        reason
    );

    return 1;
}


// ============================================================
// /UNJAIL
// R2+
// ============================================================

stock CRP_AdminCommand_Unjail(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
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
            "USAGE: /unjail [ID]"
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

    CRP_AdminAction_Unjail(
        playerid,
        targetid
    );

    return 1;
}


// ============================================================
// /TBAN
// R2+
// ============================================================

stock CRP_AdminCommand_TBan(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new targetToken[32];
    new minuteToken[32];
    new reason[CRP_ADMIN_MAX_REASON];

    if(
        !CRP_AdminGetToken(
            params,
            0,
            targetToken,
            sizeof(targetToken)
        ) ||
        !CRP_AdminGetToken(
            params,
            1,
            minuteToken,
            sizeof(minuteToken)
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /tban [ID] [minutes] [reason]"
        );

        return 1;
    }

    if(!CRP_IsNumeric(minuteToken))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi ban harus berupa angka."
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        2,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /tban [ID] [minutes] [reason]"
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

    new minutes = strval(minuteToken);

    if(minutes <= 0)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Durasi ban harus lebih dari 0 menit."
        );

        return 1;
    }

    CRP_AdminAction_TBan(
        playerid,
        targetid,
        minutes,
        reason
    );

    return 1;
}


// ============================================================
// /BLOCKUSER
// R2+
// ACCOUNT / UCP
// ============================================================

stock CRP_AdminCommand_BlockUser(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new username[64];
    new reason[CRP_ADMIN_MAX_REASON];

    if(!CRP_AdminGetToken(
        params,
        0,
        username,
        sizeof(username)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /blockuser [AccountUsername] [reason]"
        );

        return 1;
    }

    if(!CRP_AdminGetRest(
        params,
        1,
        reason,
        sizeof(reason)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /blockuser [AccountUsername] [reason]"
        );

        return 1;
    }

    CRP_AdminAction_BlockUser(
        playerid,
        username,
        reason
    );

    return 1;
}


// ============================================================
// /UNBLOCK
// R2+
// ACCOUNT / UCP
// ============================================================

stock CRP_AdminCommand_Unblock(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_HELPER
    ))
    {
        return 1;
    }

    new username[64];

    if(!CRP_AdminGetToken(
        params,
        0,
        username,
        sizeof(username)
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /unblock [AccountUsername]"
        );

        return 1;
    }

    CRP_AdminAction_Unblock(
        playerid,
        username
    );

    return 1;
}


// ============================================================
// /AHELP
// R1+
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

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Core: /ap /asks /a /admins /ahelp"
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
            "Inspection: /check /ainspect"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Movement: /goto /gethere"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Control: /flip /afrisk /checkmask"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Action: /kick /ban /oban /unban"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Action: /mute /unmute /warn /unwarn"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Jail: /jail /ojail /unjail"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Account: /blockuser /unblock"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Temporary: /tban"
        );
    }

    if(rank >= ADMIN_SENIOR_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Vehicle: /fixveh /flip /respawncar /destroycar /respawnallcars /afill"
        );
    }

    if(rank >= ADMIN_ADMIN)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Character: /setskin"
        );
    }

    if(
        rank >= ADMIN_SERVER_DIRECTOR &&
        rank <= ADMIN_DEVELOPER
    )
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Restricted: /charremove"
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Admin identity dan rank menggunakan ACCOUNT."
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "================================================="
    );

    return 1;
}


// ============================================================
// COMMAND DISPATCHER
// ============================================================

public OnPlayerCommandText(
    playerid,
    cmdtext[]
)
{
    if(!strlen(cmdtext))
        return 0;

    if(cmdtext[0] != '/')
        return 0;

    new command[32];
    new params[256];

    command[0] = EOS;
    params[0] = EOS;

    CRP_AdminGetToken(
        cmdtext,
        0,
        command,
        sizeof(command)
    );

    CRP_AdminGetRest(
        cmdtext,
        1,
        params,
        sizeof(params)
    );


    // ========================================================
    // CORE
    // ========================================================

    if(!strcmp(
        command,
        "/ap",
        true
    ))
    {
        return CRP_AdminCommand_AP(playerid);
    }

    if(!strcmp(
        command,
        "/asks",
        true
    ))
    {
        return CRP_AdminCommand_Asks(playerid);
    }

    if(!strcmp(
        command,
        "/a",
        true
    ))
    {
        return CRP_AdminCommand_A(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/admins",
        true
    ))
    {
        return CRP_AdminCommand_Admins(playerid);
    }

    if(!strcmp(
        command,
        "/ahelp",
        true
    ))
    {
        return CRP_AdminCommand_AHelp(playerid);
    }


    // ========================================================
    // DUTY
    // ========================================================

    if(!strcmp(
        command,
        "/aon",
        true
    ))
    {
        return CRP_AdminCommand_AOn(playerid);
    }

    if(!strcmp(
        command,
        "/aoff",
        true
    ))
    {
        return CRP_AdminCommand_AOff(playerid);
    }


    // ========================================================
    // INSPECTION
    // ========================================================

    if(!strcmp(
        command,
        "/check",
        true
    ))
    {
        return CRP_AdminCommand_Check(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/ainspect",
        true
    ))
    {
        return CRP_AdminCommand_AInspect(
            playerid,
            params
        );
    }


    // ========================================================
    // MOVEMENT
    // ========================================================

    if(!strcmp(
        command,
        "/goto",
        true
    ))
    {
        return CRP_AdminCommand_Goto(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/gethere",
        true
    ))
    {
        return CRP_AdminCommand_GetHere(
            playerid,
            params
        );
    }


    // ========================================================
    // CONTROL
    // ========================================================

    if(!strcmp(
        command,
        "/flip",
        true
    ))
    {
        return CRP_AdminCommand_Flip(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/afrisk",
        true
    ))
    {
        return CRP_AdminCommand_AFrisk(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/checkmask",
        true
    ))
    {
        return CRP_AdminCommand_CheckMask(
            playerid,
            params
        );
    }


    // ========================================================
    // VEHICLE
    // ========================================================

    if(!strcmp(
        command,
        "/fixveh",
        true
    ))
    {
        return CRP_AdminCommand_FixVeh(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/respawncar",
        true
    ))
    {
        return CRP_AdminCommand_RespawnCar(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/destroycar",
        true
    ))
    {
        return CRP_AdminCommand_DestroyCar(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/respawnallcars",
        true
    ))
    {
        return CRP_AdminCommand_RespawnAllCars(
            playerid
        );
    }

    if(!strcmp(
        command,
        "/afill",
        true
    ))
    {
        return CRP_AdminCommand_AFill(
            playerid,
            params
        );
    }


    // ========================================================
    // CHARACTER
    // ========================================================

    if(!strcmp(
        command,
        "/setskin",
        true
    ))
    {
        return CRP_AdminCommand_SetSkin(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/charremove",
        true
    ))
    {
        return CRP_AdminCommand_CharRemove(
            playerid,
            params
        );
    }


    // ========================================================
    // ADMIN ACTIONS
    // ========================================================

    if(!strcmp(
        command,
        "/kick",
        true
    ))
    {
        return CRP_AdminCommand_Kick(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/ban",
        true
    ))
    {
        return CRP_AdminCommand_Ban(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/oban",
        true
    ))
    {
        return CRP_AdminCommand_OBan(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/unban",
        true
    ))
    {
        return CRP_AdminCommand_Unban(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/mute",
        true
    ))
    {
        return CRP_AdminCommand_Mute(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/unmute",
        true
    ))
    {
        return CRP_AdminCommand_Unmute(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/warn",
        true
    ))
    {
        return CRP_AdminCommand_Warn(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/unwarn",
        true
    ))
    {
        return CRP_AdminCommand_Unwarn(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/jail",
        true
    ))
    {
        return CRP_AdminCommand_Jail(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/ojail",
        true
    ))
    {
        return CRP_AdminCommand_OJail(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/unjail",
        true
    ))
    {
        return CRP_AdminCommand_Unjail(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/tban",
        true
    ))
    {
        return CRP_AdminCommand_TBan(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/blockuser",
        true
    ))
    {
        return CRP_AdminCommand_BlockUser(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "/unblock",
        true
    ))
    {
        return CRP_AdminCommand_Unblock(
            playerid,
            params
        );
    }


    // ========================================================
    // NOT ADMIN COMMAND
    // ========================================================

    return 0;
}