#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Commands System v1.3
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
// ============================================================
// FOKUS
// ============================================================
// - Command dispatcher
// - Permission / rank validation
// - Admin duty validation
// - Target hierarchy protection
// - Admin Panel bridge
// - ASK Panel bridge
// - Admin chat
// - Admin list
// - Basic player inspection
// - Basic teleport
// - Basic vehicle administration
// - Set Skin
// - Future command foundation
//
// ============================================================
// IMPORTANT
// ============================================================
// - Admin Rank = ACCOUNT BASED
// - Duty state = crp_admin.pwn
// - Hierarchy = crp_admin.pwn
// - ASK = crp_admin.pwn
// - Panel = crp_admin.pwn
// - Tidak ada crp_admin_logs.pwn
// - Tidak ada Archives
// - Money Settings bukan command
// - /eject bukan admin command
//
// ============================================================


// ============================================================
// COLORS
// ============================================================

#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_GREY              0xBFC0C2FF
#define COLOR_RED               0xE74C3CFF
#define COLOR_GREEN             0x2ECC71FF
#define COLOR_YELLOW            0xF1C40FFF
#define COLOR_GOLD              0xD8B56AFF
#define COLOR_EMERALD           0x09261FFF


// ============================================================
// ADMIN RANK
// Sinkron dengan crp_admin.pwn
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
// COMMAND BUFFER
// ============================================================

#define CRP_CMD_NAME_LENGTH     32
#define CRP_CMD_PARAMS_LENGTH   256


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
// DUTY API
// Source of truth:
// crp_admin.pwn
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
    {
        return false;
    }

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
    if(
        targetid < 0 ||
        targetid >= MAX_PLAYERS ||
        !IsPlayerConnected(targetid)
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Player tidak ditemukan."
        );

        return false;
    }

    if(playerid == targetid)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu tidak dapat menargetkan diri sendiri."
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
            "AdminCmd: Target memiliki rank yang sama atau lebih tinggi."
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
    {
        return false;
    }

    for(new i = 0; text[i] != EOS; i++)
    {
        if(
            text[i] < '0' ||
            text[i] > '9'
        )
        {
            return false;
        }
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
    new start = 0;
    new length = strlen(source);

    output[0] = EOS;

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
                {
                    tokenLength = size - 1;
                }

                if(tokenLength <= 0)
                {
                    return 0;
                }

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
// PLAYER FINDER
// ============================================================

stock CRP_AdminFindPlayer(
    const input[]
)
{
    if(!strlen(input))
    {
        return INVALID_PLAYER_ID;
    }

    if(CRP_IsNumeric(input))
    {
        new id = strval(input);

        if(
            id >= 0 &&
            id < MAX_PLAYERS &&
            IsPlayerConnected(id)
        )
        {
            return id;
        }
    }

    new name[MAX_PLAYER_NAME + 1];

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i))
        {
            continue;
        }

        GetPlayerName(
            i,
            name,
            sizeof(name)
        );

        if(!strcmp(
            name,
            input,
            true
        ))
        {
            return i;
        }
    }

    return INVALID_PLAYER_ID;
}


// ============================================================
// /AP
// R1+
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
// R1+
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

    CallRemoteFunction(
        "CRP_AskOpenAdminQueue",
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
            message
        );
    }

    return 1;
}


// ============================================================
// /ADMINS
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
    new username[64];
    new rankName[64];
    new line[192];

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

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

        switch(rank)
        {
            case ADMIN_DEVELOPER:
                format(rankName, sizeof(rankName), "Developer");

            case ADMIN_SERVER_DIRECTOR:
                format(rankName, sizeof(rankName), "Server Director");

            case ADMIN_ADMIN_DIRECTOR:
                format(rankName, sizeof(rankName), "Admin Director");

            case ADMIN_HIGH_ADMIN:
                format(rankName, sizeof(rankName), "High Admin");

            case ADMIN_SUPERVISOR:
                format(rankName, sizeof(rankName), "Supervisor Admin");

            case ADMIN_SENIOR_ADMIN:
                format(rankName, sizeof(rankName), "Senior Admin");

            case ADMIN_ADMIN:
                format(rankName, sizeof(rankName), "Admin");

            case ADMIN_SENIOR_HELPER:
                format(rankName, sizeof(rankName), "Senior Helper");

            case ADMIN_HELPER:
                format(rankName, sizeof(rankName), "Helper");

            case ADMIN_INTERN:
                format(rankName, sizeof(rankName), "Intern Staff");

            default:
                format(rankName, sizeof(rankName), "No Staff");
        }

        format(
            line,
            sizeof(line),
            "%s | %s | %s | %s",
            name,
            username,
            rankName,
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
        "========================================"
    );

    return 1;
}


// ============================================================
// /AON
// R2+
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

    if(!CRP_AdminSetDuty(
        playerid,
        true
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Gagal mengaktifkan Admin Duty."
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

    if(!CRP_AdminSetDuty(
        playerid,
        false
    ))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Gagal menonaktifkan Admin Duty."
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

    new targetid =
        CRP_AdminFindPlayer(token);

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1];
    new account[64];
    new Float:health;
    new Float:armor;
    new Float:x;
    new Float:y;
    new Float:z;

    GetPlayerName(
        targetid,
        name,
        sizeof(name)
    );

    CRP_AdminGetAccountUsername(
        targetid,
        account,
        sizeof(account)
    );

    GetPlayerHealth(
        targetid,
        health
    );

    GetPlayerArmour(
        targetid,
        armor
    );

    GetPlayerPos(
        targetid,
        x,
        y,
        z
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== PLAYER CHECK =========="
    );

    new line[192];

    format(
        line,
        sizeof(line),
        "ID: %d | Name: %s",
        targetid,
        name
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Account: %s | Rank: R%d",
        account,
        CRP_AdminGetRank(targetid)
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Health: %.1f | Armour: %.1f",
        health,
        armor
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Interior: %d | Virtual World: %d",
        GetPlayerInterior(targetid),
        GetPlayerVirtualWorld(targetid)
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Position: %.2f, %.2f, %.2f",
        x,
        y,
        z
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "=================================="
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

    new targetid =
        CRP_AdminFindPlayer(token);

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1];
    new account[64];
    new ip[16];

    GetPlayerName(
        targetid,
        name,
        sizeof(name)
    );

    CRP_AdminGetAccountUsername(
        targetid,
        account,
        sizeof(account)
    );

    GetPlayerIp(
        targetid,
        ip,
        sizeof(ip)
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== ADMIN INSPECT =========="
    );

    new line[192];

    format(
        line,
        sizeof(line),
        "Player: %s | ID: %d",
        name,
        targetid
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Account: %s | IP: %s",
        account,
        ip
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    format(
        line,
        sizeof(line),
        "Ping: %d | Interior: %d | VW: %d",
        GetPlayerPing(targetid),
        GetPlayerInterior(targetid),
        GetPlayerVirtualWorld(targetid)
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "=================================="
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

    new targetid =
        CRP_AdminFindPlayer(token);

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
        "AdminCmd: Kamu telah teleport ke player."
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

    new targetid =
        CRP_AdminFindPlayer(token);

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
        "AdminCmd: Player telah dipindahkan ke lokasi kamu."
    );

    SendClientMessage(
        targetid,
        COLOR_YELLOW,
        "AdminCmd: Kamu telah dipindahkan oleh Admin."
    );

    return 1;
}


// ============================================================
// /FLIP
// R2+
// ============================================================

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

    new vehicleid =
        GetPlayerVehicleID(playerid);

    if(!vehicleid)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu harus berada di dalam kendaraan."
        );

        return 1;
    }

    new Float:x;
    new Float:y;
    new Float:z;

    GetVehiclePos(
        vehicleid,
        x,
        y,
        z
    );

    SetVehiclePos(
        vehicleid,
        x,
        y,
        z + 0.5
    );

    SetVehicleZAngle(
        vehicleid,
        0.0
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

    new targetid =
        CRP_AdminFindPlayer(token);

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1];

    GetPlayerName(
        targetid,
        name,
        sizeof(name)
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== ADMIN FRISK =========="
    );

    new line[160];

    format(
        line,
        sizeof(line),
        "Target: %s (%d)",
        name,
        targetid
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        line
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Inventory/storage frisk belum terhubung."
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "================================="
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

    new targetid =
        CRP_AdminFindPlayer(token);

    if(!CRP_AdminRequireTarget(
        playerid,
        targetid
    ))
    {
        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== CHECK MASK =========="
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Character mask system belum terhubung."
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "================================"
    );

    return 1;
}


// ============================================================
// /FIXVEH
// R3+
// ============================================================

stock CRP_AdminCommand_FixVeh(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    new vehicleid =
        GetPlayerVehicleID(playerid);

    if(!vehicleid)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu harus berada di dalam kendaraan."
        );

        return 1;
    }

    RepairVehicle(
        vehicleid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil diperbaiki."
    );

    return 1;
}


// ============================================================
// /RESPAWNCAR
// R3+
// ============================================================

stock CRP_AdminCommand_RespawnCar(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    new vehicleid =
        GetPlayerVehicleID(playerid);

    if(!vehicleid)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu harus berada di dalam kendaraan."
        );

        return 1;
    }

    SetVehicleToRespawn(
        vehicleid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil di-respawn."
    );

    return 1;
}


// ============================================================
// /DESTROYCAR
// R3+
// ============================================================

stock CRP_AdminCommand_DestroyCar(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    new vehicleid =
        GetPlayerVehicleID(playerid);

    if(!vehicleid)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu harus berada di dalam kendaraan."
        );

        return 1;
    }

    RemovePlayerFromVehicle(
        playerid
    );

    DestroyVehicle(
        vehicleid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil dihancurkan."
    );

    return 1;
}


// ============================================================
// /RESPAWNALLCARS
// R3+
// ============================================================

stock CRP_AdminCommand_RespawnAllCars(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    for(new vehicleid = 1;
        vehicleid <= MAX_VEHICLES;
        vehicleid++)
    {
        SetVehicleToRespawn(
            vehicleid
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Seluruh kendaraan berhasil di-respawn."
    );

    return 1;
}


// ============================================================
// /AFILL
// R3+
// ============================================================
//
// Foundation note:
// Sistem fuel belum tersedia.
// Untuk sementara command hanya melakukan vehicle repair.
// ============================================================

stock CRP_AdminCommand_AFill(
    playerid
)
{
    if(!CRP_AdminRequireDuty(
        playerid,
        ADMIN_ADMIN
    ))
    {
        return 1;
    }

    new vehicleid =
        GetPlayerVehicleID(playerid);

    if(!vehicleid)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "AdminCmd: Kamu harus berada di dalam kendaraan."
        );

        return 1;
    }

    RepairVehicle(
        vehicleid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: Kendaraan berhasil diisi/diperbaiki."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Catatan: Fuel backend belum terhubung ke foundation."
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
            "USAGE: /setskin [ID] [skin]"
        );

        return 1;
    }

    new targetid =
        CRP_AdminFindPlayer(targetToken);

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
            "AdminCmd: Skin harus berupa angka."
        );

        return 1;
    }

    new skinid =
        strval(skinToken);

    if(
        skinid < 0 ||
        skinid > 311
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Skin ID harus 0-311."
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
        "AdminCmd: Skin karakter kamu telah diubah oleh Admin."
    );

    return 1;
}


// ============================================================
// /CHARREMOVE
// R9-R10
// ============================================================
//
// Foundation note:
// Character deletion/removal membutuhkan Character Storage API.
// Command sudah dikunci pada R9-R10.
// Backend removal sengaja belum dilakukan di sini.
// ============================================================

stock CRP_AdminCommand_CharRemove(
    playerid,
    const params[]
)
{
    new rank =
        CRP_AdminGetRank(playerid);

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

    if(!strlen(params))
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "USAGE: /charremove [ID]"
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: Character removal backend belum terhubung."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Command ini sengaja belum menghapus data karakter."
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
    new rank =
        CRP_AdminGetRank(playerid);

    if(rank < ADMIN_INTERN)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "AdminCmd: Kamu tidak memiliki akses."
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "========== CRYSTAL ROLEPLAY ADMIN =========="
    );

    // --------------------------------------------------------
    // R1+
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "R1+: /ap /asks /a /ahelp /admins"
    );

    // --------------------------------------------------------
    // R2+
    // --------------------------------------------------------

    if(rank >= ADMIN_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R2+: /aon /aoff /check /ainspect /goto /gethere"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R2+: /flip /afrisk /checkmask"
        );
    }

    // --------------------------------------------------------
    // R3+
    // --------------------------------------------------------

    if(rank >= ADMIN_SENIOR_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R3+: /fixveh /respawncar /destroycar"
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R3+: /respawnallcars /afill"
        );
    }

    // --------------------------------------------------------
    // R4+
    // --------------------------------------------------------

    if(rank >= ADMIN_ADMIN)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R4+: /setskin"
        );
    }

    // --------------------------------------------------------
    // R9-R10
    // --------------------------------------------------------

    if(
        rank >= ADMIN_SERVER_DIRECTOR &&
        rank <= ADMIN_DEVELOPER
    )
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "R9-R10: /charremove"
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Beberapa command menunggu Character/Storage backend."
    );

    SendClientMessage(
        playerid,
        COLOR_GOLD,
        "==========================================="
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
    if(cmdtext[0] != '/')
    {
        return 0;
    }

    new command[CRP_CMD_NAME_LENGTH];
    new params[CRP_CMD_PARAMS_LENGTH];

    command[0] = EOS;
    params[0] = EOS;

    new length =
        strlen(cmdtext);

    new start = 1;
    new position = 0;

    for(new i = 1; i <= length; i++)
    {
        if(
            cmdtext[i] == ' ' ||
            cmdtext[i] == EOS
        )
        {
            new commandLength =
                i - start;

            if(commandLength <= 0)
            {
                return 0;
            }

            if(commandLength >= CRP_CMD_NAME_LENGTH)
            {
                commandLength =
                    CRP_CMD_NAME_LENGTH - 1;
            }

            strmid(
                command,
                cmdtext,
                start,
                start + commandLength,
                sizeof(command)
            );

            position = i + 1;

            while(
                cmdtext[position] == ' '
            )
            {
                position++;
            }

            if(
                cmdtext[position] != EOS
            )
            {
                strmid(
                    params,
                    cmdtext,
                    position,
                    length,
                    sizeof(params)
                );
            }

            break;
        }
    }

    if(!strlen(command))
    {
        return 0;
    }


    // ========================================================
    // R1+
    // ========================================================

    if(!strcmp(
        command,
        "ap",
        true
    ))
    {
        return CRP_AdminCommand_AP(
            playerid
        );
    }

    if(!strcmp(
        command,
        "asks",
        true
    ))
    {
        return CRP_AdminCommand_Asks(
            playerid
        );
    }

    if(!strcmp(
        command,
        "a",
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
        "ahelp",
        true
    ))
    {
        return CRP_AdminCommand_AHelp(
            playerid
        );
    }

    if(!strcmp(
        command,
        "admins",
        true
    ))
    {
        return CRP_AdminCommand_Admins(
            playerid
        );
    }


    // ========================================================
    // R2+
    // ========================================================

    if(!strcmp(
        command,
        "aon",
        true
    ))
    {
        return CRP_AdminCommand_AOn(
            playerid
        );
    }

    if(!strcmp(
        command,
        "aoff",
        true
    ))
    {
        return CRP_AdminCommand_AOff(
            playerid
        );
    }

    if(!strcmp(
        command,
        "check",
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
        "ainspect",
        true
    ))
    {
        return CRP_AdminCommand_AInspect(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "goto",
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
        "gethere",
        true
    ))
    {
        return CRP_AdminCommand_GetHere(
            playerid,
            params
        );
    }

    if(!strcmp(
        command,
        "flip",
        true
    ))
    {
        return CRP_AdminCommand_Flip(
            playerid
        );
    }

    if(!strcmp(
        command,
        "afrisk",
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
        "checkmask",
        true
    ))
    {
        return CRP_AdminCommand_CheckMask(
            playerid,
            params
        );
    }


    // ========================================================
    // R3+
    // ========================================================

    if(!strcmp(
        command,
        "fixveh",
        true
    ))
    {
        return CRP_AdminCommand_FixVeh(
            playerid
        );
    }

    if(!strcmp(
        command,
        "respawncar",
        true
    ))
    {
        return CRP_AdminCommand_RespawnCar(
            playerid
        );
    }

    if(!strcmp(
        command,
        "destroycar",
        true
    ))
    {
        return CRP_AdminCommand_DestroyCar(
            playerid
        );
    }

    if(!strcmp(
        command,
        "respawnallcars",
        true
    ))
    {
        return CRP_AdminCommand_RespawnAllCars(
            playerid
        );
    }

    if(!strcmp(
        command,
        "afill",
        true
    ))
    {
        return CRP_AdminCommand_AFill(
            playerid
        );
    }


    // ========================================================
    // R4+
    // ========================================================

    if(!strcmp(
        command,
        "setskin",
        true
    ))
    {
        return CRP_AdminCommand_SetSkin(
            playerid,
            params
        );
    }


    // ========================================================
    // R9-R10
    // ========================================================

    if(!strcmp(
        command,
        "charremove",
        true
    ))
    {
        return CRP_AdminCommand_CharRemove(
            playerid,
            params
        );
    }


    // ========================================================
    // UNKNOWN COMMAND
    // ========================================================

    return 0;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("--------------------------------------------------");
    print("Crystal Roleplay Admin Commands v1.3");
    print("Command layer initialized.");
    print("R1: /ap /asks /a /ahelp /admins");
    print("R2: /aon /aoff /check /ainspect /goto /gethere");
    print("R2: /flip /afrisk /checkmask");
    print("R3: /fixveh /respawncar /destroycar");
    print("R3: /respawnallcars /afill");
    print("R4: /setskin");
    print("R9-R10: /charremove");
    print("--------------------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print("Crystal Roleplay Admin Commands unloaded.");

    return 1;
}


// ============================================================
// END OF FILE
// ============================================================