#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Commands System v1.4
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
// Fokus v1.4:
// - Admin command dispatcher
// - Account-based admin identity
// - Rank validation
// - Duty validation melalui crp_admin.pwn
// - Target hierarchy protection
// - Admin Panel bridge
// - ASK Queue bridge
// - Admin chat
// - Admin list
// - Vehicle administration
// - Character administration foundation
//
// ARSITEKTUR:
// - Admin state / rank / duty / panel / ASK:
//   crp_admin.pwn
//
// - Command layer:
//   crp_admin_cmd.pwn
//
// CATATAN:
// - Money Settings bukan command
// - /eject bukan admin command
// - Tidak menggunakan crp_admin_logs.pwn
// - Tidak menggunakan Archives
// - Developer tidak dapat ditargetkan admin lain
// - Admin dengan rank sama/lebih tinggi tidak dapat ditargetkan
// - /check dan /ainspect belum memiliki backend inspection
//   sehingga command hanya menjalankan foundation validation
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
//
// HARUS SINKRON DENGAN crp_admin.pwn
// ============================================================

#define ADMIN_NO_STAFF          0
#define ADMIN_INTERN            1
#define ADMIN_HELPER            2
#define ADMIN_SENIOR_HELPER     3
#define ADMIN_ADMIN              4
#define ADMIN_SENIOR_ADMIN      5
#define ADMIN_SUPERVISOR        6
#define ADMIN_HIGH_ADMIN        7
#define ADMIN_ADMIN_DIRECTOR    8
#define ADMIN_SERVER_DIRECTOR   9
#define ADMIN_DEVELOPER         10


// ============================================================
// VEHICLE
// ============================================================

#define INVALID_VEHICLE_ID      0


// ============================================================
// REMOTE ADMIN API
//
// Semua state admin berasal dari crp_admin.pwn.
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
//
// SINGLE SOURCE OF TRUTH:
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
    if(
        targetid == INVALID_PLAYER_ID ||
        !IsPlayerConnected(targetid)
    )
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
    new position = 0;
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
                new tokenLength = i - position;

                if(tokenLength >= size)
                    tokenLength = size - 1;

                if(tokenLength < 0)
                    tokenLength = 0;

                strmid(
                    output,
                    source,
                    position,
                    position + tokenLength,
                    size
                );

                return 1;
            }

            current++;

            while(source[i + 1] == ' ')
                i++;

            position = i + 1;
        }
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

            while(source[i + 1] == ' ')
                i++;

            position = i + 1;
        }
    }

    return 0;
}


// ============================================================
// PLAYER FINDER
//
// Support:
// - Player ID
// - Exact player name
// ============================================================

stock CRP_AdminFindPlayer(
    const input[]
)
{
    if(!strlen(input))
        return INVALID_PLAYER_ID;

    new targetid;

    if(CRP_IsNumeric(input))
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
// VEHICLE FINDER
//
// Support:
// - Vehicle ID
// - Vehicle yang sedang dikendarai admin
// ============================================================

stock CRP_AdminFindVehicle(
    playerid,
    const params[]
)
{
    new token[32];

    if(CRP_AdminGetToken(
        params,
        0,
        token,
        sizeof(token)
    ))
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

    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        if(
            vehicleid > 0 &&
            IsValidVehicle(vehicleid)
        )
        {
            return vehicleid;
        }
    }

    return INVALID_VEHICLE_ID;
}


// ============================================================
// /AP
//
// Permission:
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
//
// Permission:
// R1+
//
// ASK Queue dimiliki crp_admin.pwn.
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
//
// Permission:
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

    return 1;
}


// ============================================================
// /ADMINS
//
// Permission:
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
        "========== CRYSTAL ROLEPLAY ADMIN STAFF =========="
    );

    new name[MAX_PLAYER_NAME + 1];
    new username[64];
    new line[192];

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
//
// Permission:
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
//
// Permission:
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
//
// Permission:
// R2+
//
// FOUNDATION ONLY
//
// Belum memanggil backend inspection.
// Tidak menggunakan RemoteFunction yang belum tersedia.
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

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Player inspection backend belum terhubung ke Admin Foundation."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: /check sudah memiliki permission R2+ dan target hierarchy protection."
    );

    return 1;
}


// ============================================================
// /AINSPECT
//
// Permission:
// R2+
//
// FOUNDATION ONLY
//
// Belum memanggil backend inspection.
// Tidak menggunakan RemoteFunction yang belum tersedia.
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

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Advanced inspection backend belum terhubung ke Admin Foundation."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: /ainspect sudah memiliki permission R2+ dan target hierarchy protection."
    );

    return 1;
}


// ============================================================
// /GOTO
//
// Permission:
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
    new interior;
    new world;

    GetPlayerPos(
        targetid,
        x,
        y,
        z
    );

    interior = GetPlayerInterior(targetid);
    world = GetPlayerVirtualWorld(targetid);

    SetPlayerInterior(
        playerid,
        interior
    );

    SetPlayerVirtualWorld(
        playerid,
        world
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
//
// Permission:
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
    new interior;
    new world;

    GetPlayerPos(
        playerid,
        x,
        y,
        z
    );

    interior = GetPlayerInterior(playerid);
    world = GetPlayerVirtualWorld(playerid);

    SetPlayerInterior(
        targetid,
        interior
    );

    SetPlayerVirtualWorld(
        targetid,
        world
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
//
// Permission:
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
//
// Permission:
// R2+
//
// FOUNDATION SAFE
// Inventory backend belum menjadi dependency.
// ============================================================

stock CRP_AdminCommand_AFriSK(
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

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Inventory/character backend belum terhubung ke Admin Foundation."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: /afrisk sudah memiliki permission R2+ dan siap menerima backend inventory."
    );

    return 1;
}


// ============================================================
// /CHECKMASK
//
// Permission:
// R2+
//
// FOUNDATION SAFE
// Character/mask backend belum menjadi dependency.
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

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Character/mask backend belum terhubung ke Admin Foundation."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: /checkmask sudah memiliki permission R2+ dan siap menerima backend character."
    );

    return 1;
}


// ============================================================
// /FIXVEH
//
// Permission:
// R3+
// ============================================================

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
            "USAGE: /fixveh [vehicleid] - kosongkan ID jika sedang berada di kendaraan."
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


// ============================================================
// /RESPAWNCAR
//
// Permission:
// R3+
// ============================================================

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
            "USAGE: /respawncar [vehicleid] - kosongkan ID jika sedang berada di kendaraan."
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


// ============================================================
// /DESTROYCAR
//
// Permission:
// R3+
// ============================================================

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
            "USAGE: /destroycar [vehicleid] - kosongkan ID jika sedang berada di kendaraan."
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


// ============================================================
// /RESPAWNALLCARS
//
// Permission:
// R3+
// ============================================================

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


// ============================================================
// /AFILL
//
// Permission:
// R3+
//
// IMPORTANT:
// Fuel system belum menjadi dependency Admin Foundation.
// Tidak mengarang perubahan fuel lokal.
// ============================================================

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
            "USAGE: /afill [vehicleid] - kosongkan ID jika sedang berada di kendaraan."
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Fuel backend belum terhubung ke Admin Foundation."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: /afill sudah tersedia dengan permission R3+."
    );

    return 1;
}


// ============================================================
// /SETSKIN
//
// Permission:
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
//
// Permission:
// R9-R10
//
// Character Storage belum menjadi dependency command layer.
// Tidak melakukan destructive action sebelum API tersedia.
// ============================================================

stock CRP_AdminCommand_CharRemove(
    playerid,
    const params[]
)
{
    if(!CRP_AdminRequireStaff(
        playerid,
        ADMIN_SERVER_DIRECTOR
    ))
    {
        return 1;
    }

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

    new token[64];

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
            "USAGE: /charremove [character]"
        );

        return 1;
    }

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "AdminCmd: Character Storage backend belum terhubung."
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "AdminCmd: Tidak ada data character yang dihapus. Command foundation sudah aktif untuk R9-R10."
    );

    return 1;
}


// ============================================================
// /AHELP
//
// Permission:
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
    }

    if(rank >= ADMIN_SENIOR_HELPER)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Vehicle: /fixveh /respawncar /destroycar /respawnallcars /afill"
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

    if(rank >= ADMIN_SERVER_DIRECTOR)
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Restricted Character: /charremove"
        );
    }

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "Catatan: Command backend yang belum tersedia tidak melakukan perubahan data."
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
//
// Semua command admin dipusatkan di sini.
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
        return CRP_AdminCommand_AFriSK(
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
    // BUKAN ADMIN COMMAND
    // ========================================================

    return 0;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("============================================================");
    print("Crystal Roleplay - Admin Commands System v1.4");
    print("Command layer initialized.");
    print("Account-based admin identity enabled.");
    print("Duty bridge: crp_admin.pwn");
    print("ASK Queue bridge: CRP_AskOpenAdminQueue");
    print("Permission foundation synchronized.");
    print("Inspection backend remains foundation-safe.");
    print("============================================================");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "Crystal Roleplay - Admin Commands System unloaded."
    );

    return 1;
}