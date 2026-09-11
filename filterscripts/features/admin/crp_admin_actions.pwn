#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Actions Backend v1.0
//
// File:
// filterscripts/features/admin/crp_admin_actions.pwn
//
// Developer:
// Muhammad Rizal
//
// Architecture:
// - crp_admin.pwn         = Admin Foundation
// - crp_admin_cmd.pwn     = Command Layer
// - crp_admin_actions.pwn = Admin Actions Backend
//
// Fokus:
// - Centralized Admin Action Backend
// - Character-based punishment
// - Account-based block
// - Persistent flat-file state
// - Action event logging
// - OOC Admin Jail
// - Pending offline jail
// - Character ban validation
// - Account block validation
// - Character warning state
// - Character mute state
// - Character jail state
// - Character Remove bridge
//
// Storage:
// - scriptfiles/crp_admin_bans.txt
// - scriptfiles/crp_admin_warnings.txt
// - scriptfiles/crp_admin_mutes.txt
// - scriptfiles/crp_admin_jails.txt
// - scriptfiles/crp_admin_blocks.txt
// - scriptfiles/crp_admin_actions.log
//
// Catatan:
// - Tidak menggunakan MySQL
// - Tidak menggunakan Archives
// - Tidak menggunakan crp_admin_logs.pwn
// - Command logic tidak disimpan di file ini
// - Permission dasar tetap dilakukan oleh Command Layer
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
// CONSTANTS
// ============================================================

#define CRP_ADMIN_ACTION_MAX_REASON       192
#define CRP_ADMIN_ACTION_MAX_CHARACTER    64
#define CRP_ADMIN_ACTION_MAX_ACCOUNT      64

#define CRP_ADMIN_WARNING_LIMIT           20


// ============================================================
// OOC ADMIN JAIL
//
// Tidak menyimpan posisi terakhir player.
// Setelah jail selesai, player dilepas ke lokasi release.
// ============================================================

#define CRP_ADMIN_JAIL_INTERIOR           6
#define CRP_ADMIN_JAIL_WORLD              9001

#define Float:CRP_ADMIN_JAIL_X            263.8218
#define Float:CRP_ADMIN_JAIL_Y            77.8484
#define Float:CRP_ADMIN_JAIL_Z            1001.0391
#define Float:CRP_ADMIN_JAIL_A            267.4384


// ============================================================
// OOC ADMIN JAIL RELEASE
//
// LSPD Pershing Square
// ============================================================

#define CRP_ADMIN_RELEASE_INTERIOR        0
#define CRP_ADMIN_RELEASE_WORLD           0

#define Float:CRP_ADMIN_RELEASE_X         1550.6800
#define Float:CRP_ADMIN_RELEASE_Y         -1675.4900
#define Float:CRP_ADMIN_RELEASE_Z         14.5100
#define Float:CRP_ADMIN_RELEASE_A         90.0000


// ============================================================
// ACTION TYPE
// ============================================================

#define CRP_ACTION_BAN                    1
#define CRP_ACTION_TEMPBAN                2
#define CRP_ACTION_UNBAN                  3
#define CRP_ACTION_WARN                   4
#define CRP_ACTION_UNWARN                 5
#define CRP_ACTION_MUTE                   6
#define CRP_ACTION_UNMUTE                 7
#define CRP_ACTION_JAIL                   8
#define CRP_ACTION_UNJAIL                 9
#define CRP_ACTION_KICK                   10
#define CRP_ACTION_BLOCK                  11
#define CRP_ACTION_UNBLOCK                12
#define CRP_ACTION_CHARREMOVE             13


// ============================================================
// FILE PATHS
// ============================================================

#define CRP_ADMIN_BAN_FILE                "scriptfiles/crp_admin_bans.txt"
#define CRP_ADMIN_WARNING_FILE            "scriptfiles/crp_admin_warnings.txt"
#define CRP_ADMIN_MUTE_FILE               "scriptfiles/crp_admin_mutes.txt"
#define CRP_ADMIN_JAIL_FILE               "scriptfiles/crp_admin_jails.txt"
#define CRP_ADMIN_BLOCK_FILE              "scriptfiles/crp_admin_blocks.txt"
#define CRP_ADMIN_ACTION_LOG              "scriptfiles/crp_admin_actions.log"


// ============================================================
// PLAYER STATE
//
// Hanya runtime state.
// Persistent state tetap berada di scriptfiles.
// ============================================================

new bool:gCRP_AdminMuted[MAX_PLAYERS];
new bool:gCRP_AdminJailed[MAX_PLAYERS];

new gCRP_AdminJailEnd[MAX_PLAYERS];


// ============================================================
// FORWARDS
// ============================================================

forward CRP_AdminActionsJailTimer(playerid);


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("============================================================");
    print("Crystal Roleplay - Admin Actions Backend v1.0");
    print("Admin Actions Backend initialized.");
    print("Character punishment storage enabled.");
    print("Account block storage enabled.");
    print("Action event logging enabled.");
    print("OOC Admin Jail enabled.");
    print("Pending offline jail enabled.");
    print("Character Remove bridge enabled.");
    print("============================================================");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print("Crystal Roleplay - Admin Actions Backend unloaded.");

    return 1;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    gCRP_AdminMuted[playerid] = false;
    gCRP_AdminJailed[playerid] = false;
    gCRP_AdminJailEnd[playerid] = 0;

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
    gCRP_AdminMuted[playerid] = false;
    gCRP_AdminJailed[playerid] = false;
    gCRP_AdminJailEnd[playerid] = 0;

    return 1;
}


// ============================================================
// STRING HELPERS
// ============================================================

stock CRP_AdminActionsTrim(
    text[]
)
{
    new length = strlen(text);

    while(
        length > 0 &&
        (
            text[length - 1] == ' ' ||
            text[length - 1] == '\t' ||
            text[length - 1] == '\r' ||
            text[length - 1] == '\n'
        )
    )
    {
        text[length - 1] = EOS;
        length--;
    }

    while(
        text[0] == ' ' ||
        text[0] == '\t'
    )
    {
        strdel(
            text,
            0,
            1
        );
    }

    return 1;
}


stock bool:CRP_AdminActionsIsNumeric(
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


// ============================================================
// CURRENT ACCOUNT IDENTITY
//
// Foundation API:
// CRP_AdminGetAccountUsername
//
// Untuk sementara foundation menggunakan identity yang
// tersedia dari foundation. Backend tidak membuat sistem
// account baru.
// ============================================================

stock CRP_AdminActionsGetAccount(
    playerid,
    output[],
    size = CRP_ADMIN_ACTION_MAX_ACCOUNT
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

    if(!strlen(output))
    {
        GetPlayerName(
            playerid,
            output,
            size
        );
    }

    return 1;
}


// ============================================================
// CHARACTER IDENTITY
//
// Saat Character Activation API belum dijadikan dependency
// backend, foundation identity player digunakan sebagai
// fallback character identifier.
//
// Ketika Character Activation system sudah menyediakan
// remote API, helper ini menjadi satu titik penggantian.
// ============================================================

stock CRP_AdminActionsGetCharacter(
    playerid,
    output[],
    size = CRP_ADMIN_ACTION_MAX_CHARACTER
)
{
    output[0] = EOS;

    GetPlayerName(
        playerid,
        output,
        size
    );

    return 1;
}


// ============================================================
// ADMIN IDENTITY
// ============================================================

stock CRP_AdminActionsGetAdminName(
    playerid,
    output[],
    size = 64
)
{
    CRP_AdminActionsGetAccount(
        playerid,
        output,
        size
    );

    return 1;
}


// ============================================================
// UNIX TIME
// ============================================================

stock CRP_AdminActionsGetTime()
{
    return gettime();
}


// ============================================================
// FILE APPEND
// ============================================================

stock CRP_AdminActionsAppend(
    const filename[],
    const text[]
)
{
    new File:file = fopen(
        filename,
        io_append
    );

    if(!file)
    {
        file = fopen(
            filename,
            io_write
        );
    }

    if(!file)
        return 0;

    fwrite(
        file,
        text
    );

    fclose(file);

    return 1;
}


// ============================================================
// ACTION EVENT LOG
//
// Format:
// timestamp|admin|action|target|reason
// ============================================================

stock CRP_AdminActionsLog(
    playerid,
    const action[],
    const target[],
    const reason[]
)
{
    new adminName[64];
    new line[512];

    CRP_AdminActionsGetAdminName(
        playerid,
        adminName,
        sizeof(adminName)
    );

    format(
        line,
        sizeof(line),
        "%d|%s|%s|%s|%s\r\n",
        CRP_AdminActionsGetTime(),
        adminName,
        action,
        target,
        reason
    );

    CRP_AdminActionsAppend(
        CRP_ADMIN_ACTION_LOG,
        line
    );

    return 1;
}


// ============================================================
// ACTION BROADCAST
// ============================================================

stock CRP_AdminActionsBroadcast(
    const message[]
)
{
    SendClientMessageToAll(
        COLOR_WHITE,
        message
    );

    return 1;
}


// ============================================================
// BAN STATE
//
// Format:
// character|type|expires|admin|reason
//
// type:
// 1 = permanent
// 2 = temporary
// 0 = clear
//
// expires:
// -1 = permanent
// >0 = unix timestamp
// 0 = clear
// ============================================================

stock CRP_AdminActionsWriteBan(
    const character[],
    type,
    expires,
    const admin[],
    const reason[]
)
{
    new line[512];

    format(
        line,
        sizeof(line),
        "%s|%d|%d|%s|%s\r\n",
        character,
        type,
        expires,
        admin,
        reason
    );

    return CRP_AdminActionsAppend(
        CRP_ADMIN_BAN_FILE,
        line
    );
}


// ============================================================
// WARNING STATE
//
// Format:
// character|count|admin|reason|timestamp
// ============================================================

stock CRP_AdminActionsWriteWarning(
    const character[],
    count,
    const admin[],
    const reason[]
)
{
    new line[512];

    format(
        line,
        sizeof(line),
        "%s|%d|%s|%s|%d\r\n",
        character,
        count,
        admin,
        reason,
        CRP_AdminActionsGetTime()
    );

    return CRP_AdminActionsAppend(
        CRP_ADMIN_WARNING_FILE,
        line
    );
}


// ============================================================
// MUTE STATE
//
// Format:
// character|state|admin|timestamp
// ============================================================

stock CRP_AdminActionsWriteMute(
    const character[],
    state,
    const admin[]
)
{
    new line[256];

    format(
        line,
        sizeof(line),
        "%s|%d|%s|%d\r\n",
        character,
        state,
        admin,
        CRP_AdminActionsGetTime()
    );

    return CRP_AdminActionsAppend(
        CRP_ADMIN_MUTE_FILE,
        line
    );
}


// ============================================================
// JAIL STATE
//
// Format:
// character|endtime|admin|reason
//
// endtime:
// 0 = release
// >0 = unix timestamp
// ============================================================

stock CRP_AdminActionsWriteJail(
    const character[],
    endtime,
    const admin[],
    const reason[]
)
{
    new line[512];

    format(
        line,
        sizeof(line),
        "%s|%d|%s|%s\r\n",
        character,
        endtime,
        admin,
        reason
    );

    return CRP_AdminActionsAppend(
        CRP_ADMIN_JAIL_FILE,
        line
    );
}


// ============================================================
// ACCOUNT BLOCK STATE
//
// Format:
// account|state|admin|timestamp|reason
//
// state:
// 1 = blocked
// 0 = clear
// ============================================================

stock CRP_AdminActionsWriteBlock(
    const account[],
    state,
    const admin[],
    const reason[]
)
{
    new line[512];

    format(
        line,
        sizeof(line),
        "%s|%d|%s|%d|%s\r\n",
        account,
        state,
        admin,
        CRP_AdminActionsGetTime(),
        reason
    );

    return CRP_AdminActionsAppend(
        CRP_ADMIN_BLOCK_FILE,
        line
    );
}


// ============================================================
// FILE PARSER
// ============================================================

stock CRP_AdminActionsGetField(
    const source[],
    fieldIndex,
    output[],
    size
)
{
    new current = 0;
    new start = 0;
    new length = strlen(source);

    output[0] = EOS;

    for(
        new i = 0;
        i <= length;
        i++
    )
    {
        if(
            source[i] == '|' ||
            source[i] == EOS
        )
        {
            if(current == fieldIndex)
            {
                new fieldLength = i - start;

                if(fieldLength >= size)
                    fieldLength = size - 1;

                strmid(
                    output,
                    source,
                    start,
                    start + fieldLength,
                    size
                );

                return 1;
            }

            current++;
            start = i + 1;
        }
    }

    return 0;
}


// ============================================================
// CHARACTER BAN CHECK
//
// Membaca seluruh history.
// Record terakhir untuk character tersebut dianggap state
// terbaru.
// ============================================================

stock bool:CRP_AdminActionsCheckCharacterBan(
    playerid,
    const character[]
)
{
    #pragma unused playerid

    new File:file = fopen(
        CRP_ADMIN_BAN_FILE,
        io_read
    );

    if(!file)
        return false;

    new line[512];

    new latestType = 0;
    new latestExpires = 0;

    while(fread(
        file,
        line
    ))
    {
        CRP_AdminActionsTrim(line);

        if(!strlen(line))
            continue;

        new recordCharacter[64];

        CRP_AdminActionsGetField(
            line,
            0,
            recordCharacter,
            sizeof(recordCharacter)
        );

        if(strcmp(
            recordCharacter,
            character,
            true
        ))
        {
            continue;
        }

        new typeText[16];
        new expiresText[32];

        CRP_AdminActionsGetField(
            line,
            1,
            typeText,
            sizeof(typeText)
        );

        CRP_AdminActionsGetField(
            line,
            2,
            expiresText,
            sizeof(expiresText)
        );

        latestType = strval(typeText);
        latestExpires = strval(expiresText);
    }

    fclose(file);

    if(latestType == 0)
        return false;

    if(latestType == 1)
        return true;

    if(
        latestType == 2 &&
        latestExpires > CRP_AdminActionsGetTime()
    )
    {
        return true;
    }

    return false;
}


// ============================================================
// ACCOUNT BLOCK CHECK
// ============================================================

stock bool:CRP_AdminActionsCheckAccountBlock(
    playerid,
    const account[]
)
{
    #pragma unused playerid

    new File:file = fopen(
        CRP_ADMIN_BLOCK_FILE,
        io_read
    );

    if(!file)
        return false;

    new line[512];

    new latestState = 0;

    while(fread(
        file,
        line
    ))
    {
        CRP_AdminActionsTrim(line);

        if(!strlen(line))
            continue;

        new recordAccount[64];

        CRP_AdminActionsGetField(
            line,
            0,
            recordAccount,
            sizeof(recordAccount)
        );

        if(strcmp(
            recordAccount,
            account,
            true
        ))
        {
            continue;
        }

        new stateText[16];

        CRP_AdminActionsGetField(
            line,
            1,
            stateText,
            sizeof(stateText)
        );

        latestState = strval(stateText);
    }

    fclose(file);

    return bool:latestState;
}


// ============================================================
// CHARACTER WARNING COUNT
// ============================================================

stock CRP_AdminActionsGetCharacterWarnings(
    const character[]
)
{
    new File:file = fopen(
        CRP_ADMIN_WARNING_FILE,
        io_read
    );

    if(!file)
        return 0;

    new line[512];
    new latestCount = 0;

    while(fread(
        file,
        line
    ))
    {
        CRP_AdminActionsTrim(line);

        if(!strlen(line))
            continue;

        new recordCharacter[64];

        CRP_AdminActionsGetField(
            line,
            0,
            recordCharacter,
            sizeof(recordCharacter)
        );

        if(strcmp(
            recordCharacter,
            character,
            true
        ))
        {
            continue;
        }

        new countText[16];

        CRP_AdminActionsGetField(
            line,
            1,
            countText,
            sizeof(countText)
        );

        latestCount = strval(countText);
    }

    fclose(file);

    return latestCount;
}


// ============================================================
// CHARACTER MUTE CHECK
// ============================================================

stock bool:CRP_AdminActionsGetCharacterMute(
    const character[]
)
{
    new File:file = fopen(
        CRP_ADMIN_MUTE_FILE,
        io_read
    );

    if(!file)
        return false;

    new line[256];
    new latestState = 0;

    while(fread(
        file,
        line
    ))
    {
        CRP_AdminActionsTrim(line);

        if(!strlen(line))
            continue;

        new recordCharacter[64];

        CRP_AdminActionsGetField(
            line,
            0,
            recordCharacter,
            sizeof(recordCharacter)
        );

        if(strcmp(
            recordCharacter,
            character,
            true
        ))
        {
            continue;
        }

        new stateText[16];

        CRP_AdminActionsGetField(
            line,
            1,
            stateText,
            sizeof(stateText)
        );

        latestState = strval(stateText);
    }

    fclose(file);

    return bool:latestState;
}


// ============================================================
// PLAYER MUTE STATE
// ============================================================

stock bool:CRP_AdminActionsIsPlayerMuted(
    playerid
)
{
    if(
        playerid < 0 ||
        playerid >= MAX_PLAYERS ||
        !IsPlayerConnected(playerid)
    )
    {
        return false;
    }

    if(gCRP_AdminMuted[playerid])
        return true;

    new character[64];

    CRP_AdminActionsGetCharacter(
        playerid,
        character,
        sizeof(character)
    );

    if(CRP_AdminActionsGetCharacterMute(
        character
    ))
    {
        gCRP_AdminMuted[playerid] = true;
        return true;
    }

    return false;
}


// ============================================================
// JAIL STATE CHECK
// ============================================================

stock CRP_AdminActionsGetCharacterJailEnd(
    const character[]
)
{
    new File:file = fopen(
        CRP_ADMIN_JAIL_FILE,
        io_read
    );

    if(!file)
        return 0;

    new line[512];
    new latestEndTime = 0;

    while(fread(
        file,
        line
    ))
    {
        CRP_AdminActionsTrim(line);

        if(!strlen(line))
            continue;

        new recordCharacter[64];

        CRP_AdminActionsGetField(
            line,
            0,
            recordCharacter,
            sizeof(recordCharacter)
        );

        if(strcmp(
            recordCharacter,
            character,
            true
        ))
        {
            continue;
        }

        new endText[32];

        CRP_AdminActionsGetField(
            line,
            1,
            endText,
            sizeof(endText)
        );

        latestEndTime = strval(endText);
    }

    fclose(file);

    return latestEndTime;
}


// ============================================================
// CHARACTER JAIL CHECK
// ============================================================

stock bool:CRP_AdminActionsIsCharacterJailed(
    const character[]
)
{
    new endTime = CRP_AdminActionsGetCharacterJailEnd(
        character
    );

    if(endTime <= 0)
        return false;

    if(endTime <= CRP_AdminActionsGetTime())
        return false;

    return true;
}


// ============================================================
// OOC ADMIN JAIL APPLY
// ============================================================

stock CRP_AdminActionsApplyOOCJail(
    playerid
)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    gCRP_AdminJailed[playerid] = true;

    SetPlayerInterior(
        playerid,
        CRP_ADMIN_JAIL_INTERIOR
    );

    SetPlayerVirtualWorld(
        playerid,
        CRP_ADMIN_JAIL_WORLD
    );

    SetPlayerPos(
        playerid,
        CRP_ADMIN_JAIL_X,
        CRP_ADMIN_JAIL_Y,
        CRP_ADMIN_JAIL_Z
    );

    SetPlayerFacingAngle(
        playerid,
        CRP_ADMIN_JAIL_A
    );

    TogglePlayerControllable(
        playerid,
        true
    );

    return 1;
}


// ============================================================
// OOC ADMIN JAIL RELEASE
// ============================================================

stock CRP_AdminActionsReleaseOOCJail(
    playerid
)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    gCRP_AdminJailed[playerid] = false;
    gCRP_AdminJailEnd[playerid] = 0;

    SetPlayerInterior(
        playerid,
        CRP_ADMIN_RELEASE_INTERIOR
    );

    SetPlayerVirtualWorld(
        playerid,
        CRP_ADMIN_RELEASE_WORLD
    );

    SetPlayerPos(
        playerid,
        CRP_ADMIN_RELEASE_X,
        CRP_ADMIN_RELEASE_Y,
        CRP_ADMIN_RELEASE_Z
    );

    SetPlayerFacingAngle(
        playerid,
        CRP_ADMIN_RELEASE_A
    );

    TogglePlayerControllable(
        playerid,
        true
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "AdminCmd: OOC Admin Jail kamu telah selesai."
    );

    return 1;
}


// ============================================================
// JAIL TIMER START
// ============================================================

stock CRP_AdminActionsStartJailTimer(
    playerid
)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    gCRP_AdminJailEnd[playerid] =
        CRP_AdminActionsGetCharacterJailEnd(
            (
                ""
            )
        );

    return 1;
}


// ============================================================
// JAIL TIMER STOP
// ============================================================

stock CRP_AdminActionsStopJailTimer(
    playerid
)
{
    gCRP_AdminJailEnd[playerid] = 0;

    return 1;
}


// ============================================================
// JAIL TIMER
// ============================================================

public CRP_AdminActionsJailTimer(
    playerid
)
{
    if(!IsPlayerConnected(playerid))
    {
        gCRP_AdminJailEnd[playerid] = 0;
        return 0;
    }

    if(!gCRP_AdminJailed[playerid])
        return 0;

    if(
        gCRP_AdminJailEnd[playerid] <=
        CRP_AdminActionsGetTime()
    )
    {
        new character[64];

        CRP_AdminActionsGetCharacter(
            playerid,
            character,
            sizeof(character)
        );

        new adminName[64];

        format(
            adminName,
            sizeof(adminName),
            "SYSTEM"
        );

        CRP_AdminActionsWriteJail(
            character,
            0,
            adminName,
            "Jail selesai"
        );

        CRP_AdminActionsReleaseOOCJail(
            playerid
        );

        return 1;
    }

    return 1;
}


// ============================================================
// PENDING OFFLINE JAIL
//
// Dipanggil ketika character sudah aktif/login.
// ============================================================

stock CRP_AdminActionsApplyPendingJail(
    playerid,
    const character[]
)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    new endTime =
        CRP_AdminActionsGetCharacterJailEnd(
            character
        );

    if(endTime <= 0)
        return 0;

    if(endTime <= CRP_AdminActionsGetTime())
    {
        return 0;
    }

    gCRP_AdminJailEnd[playerid] = endTime;

    CRP_AdminActionsApplyOOCJail(
        playerid
    );

    new remaining =
        endTime - CRP_AdminActionsGetTime();

    new message[144];

    format(
        message,
        sizeof(message),
        "AdminCmd: Kamu masih memiliki OOC Admin Jail. Sisa waktu: %d detik.",
        remaining
    );

    SendClientMessage(
        playerid,
        COLOR_RED,
        message
    );

    return 1;
}


// ============================================================
// KICK
// ============================================================

public CRP_AdminActionKick(
    actorid,
    targetid,
    const reason[]
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new targetName[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        targetName,
        sizeof(targetName)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    format(
        message,
        sizeof(message),
        "%s telah dikeluarkan dari server oleh Staff %s.",
        targetName,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Reason: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "KICK",
        targetName,
        reason
    );

    Kick(
        targetid
    );

    return 1;
}


// ============================================================
// BAN
// ============================================================

public CRP_AdminActionBan(
    actorid,
    targetid,
    const reason[]
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteBan(
        character,
        1,
        -1,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "%s telah dilakukan karakter ban oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "BAN",
        character,
        reason
    );

    Kick(
        targetid
    );

    return 1;
}


// ============================================================
// OFFLINE BAN
// ============================================================

public CRP_AdminActionOfflineBan(
    actorid,
    const character[],
    const reason[]
)
{
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteBan(
        character,
        1,
        -1,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "%s sedang offline telah dilakukan karakter ban oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "OBAN",
        character,
        reason
    );

    return 1;
}


// ============================================================
// UNBAN
// ============================================================

public CRP_AdminActionUnban(
    actorid,
    const character[]
)
{
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteBan(
        character,
        0,
        0,
        adminName,
        "Character ban dibuka"
    );

    format(
        message,
        sizeof(message),
        "Character ban %s telah dibuka oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "UNBAN",
        character,
        "Character ban dibuka"
    );

    return 1;
}


// ============================================================
// MUTE
// ============================================================

public CRP_AdminActionMute(
    actorid,
    targetid
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteMute(
        character,
        1,
        adminName
    );

    gCRP_AdminMuted[targetid] = true;

    format(
        message,
        sizeof(message),
        "Staff %s telah mengaktifkan mute pada %s.",
        adminName,
        character
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "MUTE",
        character,
        "Mute"
    );

    return 1;
}


// ============================================================
// UNMUTE
// ============================================================

public CRP_AdminActionUnmute(
    actorid,
    targetid
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteMute(
        character,
        0,
        adminName
    );

    gCRP_AdminMuted[targetid] = false;

    format(
        message,
        sizeof(message),
        "Mute %s telah dinonaktifkan oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "UNMUTE",
        character,
        "Mute dibuka"
    );

    return 1;
}


// ============================================================
// WARN
// ============================================================

public CRP_AdminActionWarn(
    actorid,
    targetid,
    const reason[]
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    new count =
        CRP_AdminActionsGetCharacterWarnings(
            character
        );

    if(count < CRP_ADMIN_WARNING_LIMIT)
    {
        count++;
    }

    CRP_AdminActionsWriteWarning(
        character,
        count,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "%s telah diberikan peringatan dan memiliki %d/%d peringatan.",
        character,
        count,
        CRP_ADMIN_WARNING_LIMIT
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "WARN",
        character,
        reason
    );

    return 1;
}


// ============================================================
// UNWARN
// ============================================================

public CRP_AdminActionUnwarn(
    actorid,
    targetid
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    new count =
        CRP_AdminActionsGetCharacterWarnings(
            character
        );

    if(count > 0)
    {
        count--;
    }

    CRP_AdminActionsWriteWarning(
        character,
        count,
        adminName,
        "Warning dikurangi"
    );

    format(
        message,
        sizeof(message),
        "Peringatan %s telah dikurangi menjadi %d, jumlah peringatannya menjadi %d/%d.",
        character,
        count,
        count,
        CRP_ADMIN_WARNING_LIMIT
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "UNWARN",
        character,
        "Warning dikurangi"
    );

    return 1;
}


// ============================================================
// JAIL
// ============================================================

public CRP_AdminActionJail(
    actorid,
    targetid,
    minutes,
    const reason[]
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    if(minutes <= 0)
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    new endTime =
        CRP_AdminActionsGetTime() +
        (minutes * 60);

    CRP_AdminActionsWriteJail(
        character,
        endTime,
        adminName,
        reason
    );

    gCRP_AdminJailEnd[targetid] = endTime;

    CRP_AdminActionsApplyOOCJail(
        targetid
    );

    format(
        message,
        sizeof(message),
        "%s telah dimasukkan ke dalam OOC Admin Jail oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Durasi: %d menit",
        minutes
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "JAIL",
        character,
        reason
    );

    return 1;
}


// ============================================================
// OFFLINE JAIL
// ============================================================

public CRP_AdminActionOfflineJail(
    actorid,
    const character[],
    minutes,
    const reason[]
)
{
    if(minutes <= 0)
        return 0;

    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    new endTime =
        CRP_AdminActionsGetTime() +
        (minutes * 60);

    CRP_AdminActionsWriteJail(
        character,
        endTime,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "%s sedang offline telah dimasukkan ke dalam OOC Admin Jail oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Durasi: %d menit",
        minutes
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "OJAIL",
        character,
        reason
    );

    return 1;
}


// ============================================================
// UNJAIL
// ============================================================

public CRP_AdminActionUnjail(
    actorid,
    targetid
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteJail(
        character,
        0,
        adminName,
        "OOC Admin Jail dibuka"
    );

    gCRP_AdminJailEnd[targetid] = 0;

    CRP_AdminActionsReleaseOOCJail(
        targetid
    );

    format(
        message,
        sizeof(message),
        "OOC Admin Jail %s telah dibuka oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "UNJAIL",
        character,
        "OOC Admin Jail dibuka"
    );

    return 1;
}


// ============================================================
// TEMPORARY BAN
// ============================================================

public CRP_AdminActionTBan(
    actorid,
    targetid,
    minutes,
    const reason[]
)
{
    if(!IsPlayerConnected(targetid))
        return 0;

    if(minutes <= 0)
        return 0;

    new character[64];
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetCharacter(
        targetid,
        character,
        sizeof(character)
    );

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    new expires =
        CRP_AdminActionsGetTime() +
        (minutes * 60);

    CRP_AdminActionsWriteBan(
        character,
        2,
        expires,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "%s telah dilakukan temporary character ban oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Durasi: %d menit",
        minutes
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "TBAN",
        character,
        reason
    );

    Kick(
        targetid
    );

    return 1;
}


// ============================================================
// ACCOUNT BLOCK
// ============================================================

public CRP_AdminActionBlockUser(
    actorid,
    const account[],
    const reason[]
)
{
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteBlock(
        account,
        1,
        adminName,
        reason
    );

    format(
        message,
        sizeof(message),
        "Account %s telah diblokir oleh %s.",
        account,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    format(
        message,
        sizeof(message),
        "Alasan: %s",
        reason
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "BLOCKUSER",
        account,
        reason
    );

    return 1;
}


// ============================================================
// ACCOUNT UNBLOCK
// ============================================================

public CRP_AdminActionUnblock(
    actorid,
    const account[]
)
{
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CRP_AdminActionsWriteBlock(
        account,
        0,
        adminName,
        "Account block dibuka"
    );

    format(
        message,
        sizeof(message),
        "Account block %s telah dibuka oleh %s.",
        account,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "UNBLOCK",
        account,
        "Account block dibuka"
    );

    return 1;
}


// ============================================================
// CHARACTER REMOVE
// ============================================================

public CRP_AdminActionCharacterRemove(
    actorid,
    const character[]
)
{
    new adminName[64];
    new message[256];

    CRP_AdminActionsGetAdminName(
        actorid,
        adminName,
        sizeof(adminName)
    );

    CallRemoteFunction(
        "CRP_CharacterRemoveRemote",
        "s",
        character
    );

    format(
        message,
        sizeof(message),
        "Character %s telah dihapus oleh %s.",
        character,
        adminName
    );

    CRP_AdminActionsBroadcast(
        message
    );

    CRP_AdminActionsLog(
        actorid,
        "CHARREMOVE",
        character,
        "Character removed"
    );

    return 1;
}