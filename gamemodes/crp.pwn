#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Core Gamemode v3.2
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// GM = Otak Utama Server
//
// Catatan:
// GM hanya menyimpan konteks/jenis spawn.
// Lokasi spawn tetap menjadi tanggung jawab Filterscript.
// ============================================================


// ============================================================
// COLOR DEFINITIONS
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_RED       0xFF0000FF
#define COLOR_GREEN     0x00FF00FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_GREY      0xAFAFAFFF


// ============================================================
// CHARACTER DEFINITIONS
// ============================================================

#define MAX_PLAYER_CHARACTERS   3


// ============================================================
// PLAYER STATE
// ============================================================

#define CRP_PLAYER_STATE_NONE            0
#define CRP_PLAYER_STATE_CONNECTED       1
#define CRP_PLAYER_STATE_AUTHENTICATING  2
#define CRP_PLAYER_STATE_AUTHENTICATED   3
#define CRP_PLAYER_STATE_CHARACTER       4
#define CRP_PLAYER_STATE_ACTIVE          5

new gPlayerState[MAX_PLAYERS];


// ============================================================
// PLAYER STATE HISTORY
// ============================================================

new gPlayerPreviousState[MAX_PLAYERS];
new gPlayerStateSessionID[MAX_PLAYERS];


// ============================================================
// PLAYER STATE TRANSITION AUDIT
// ============================================================

new gPlayerStateTransitionCount[MAX_PLAYERS];
new gPlayerStateTransitionSessionID[MAX_PLAYERS];


// ============================================================
// PLAYER SESSION
// ============================================================

new bool:gPlayerSession[MAX_PLAYERS];
new gPlayerSessionID[MAX_PLAYERS];
new gCRPSessionCounter;


// ============================================================
// PLAYER RUNTIME DATA
// ============================================================

new bool:gPlayerSpawned[MAX_PLAYERS];
new bool:gPlayerDead[MAX_PLAYERS];


// ============================================================
// PLAYER RUNTIME TRANSITION AUDIT
// ============================================================

new gPlayerRuntimeTransitionCount[MAX_PLAYERS];
new gPlayerRuntimeTransitionSessionID[MAX_PLAYERS];


// ============================================================
// PLAYER IDENTITY
// ============================================================

new gPlayerName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];
new bool:gPlayerIdentityReady[MAX_PLAYERS];


// ============================================================
// PLAYER DATA FOUNDATION
// ============================================================

new bool:gPlayerDataReady[MAX_PLAYERS];
new gPlayerDataSessionID[MAX_PLAYERS];


// ============================================================
// PLAYER CHARACTER DATA
// ============================================================

new gPlayerCharacterID[MAX_PLAYERS];
new gPlayerCharacterName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];
new gPlayerCharacterGender[MAX_PLAYERS];
new gPlayerCharacterSkin[MAX_PLAYERS];
new gPlayerCharacterAge[MAX_PLAYERS];
new bool:gPlayerCharacterDataReady[MAX_PLAYERS];


// ============================================================
// PLAYER SPAWN CONTEXT
// ============================================================

#define CRP_SPAWN_TYPE_NONE       0
#define CRP_SPAWN_TYPE_DEFAULT    1
#define CRP_SPAWN_TYPE_CHARACTER  2
#define CRP_SPAWN_TYPE_REGISTER   3
#define CRP_SPAWN_TYPE_LOGOUT     4
#define CRP_SPAWN_TYPE_JAIL       5
#define CRP_SPAWN_TYPE_HOSPITAL   6
#define CRP_SPAWN_TYPE_JOB         7
#define CRP_SPAWN_TYPE_EVENT       8

new gPlayerSpawnType[MAX_PLAYERS];


// ============================================================
// PLAYER STATE ACCESS DECISION
// ============================================================

#define CRP_ACCESS_RESULT_DENIED   0
#define CRP_ACCESS_RESULT_ALLOWED  1


// ============================================================
// PLAYER STATE ACCESS DECISION REASON
// ============================================================

#define CRP_ACCESS_REASON_NONE                  0
#define CRP_ACCESS_REASON_INVALID_PLAYER        1
#define CRP_ACCESS_REASON_INVALID_REQUIREMENT   2
#define CRP_ACCESS_REASON_INVALID_ACCESS_STATE  3
#define CRP_ACCESS_REASON_LIFECYCLE_INVALID    4
#define CRP_ACCESS_REASON_SESSION_INVALID      5
#define CRP_ACCESS_REASON_STATE_MISMATCH       6
#define CRP_ACCESS_REASON_STATE_TOO_LOW        7
#define CRP_ACCESS_REASON_STATE_ALLOWED        8


// ============================================================
// PLAYER CONTEXT
// ============================================================

#define CRP_PLAYER_CONTEXT_NONE            0
#define CRP_PLAYER_CONTEXT_CONNECTED       1
#define CRP_PLAYER_CONTEXT_AUTHENTICATING  2
#define CRP_PLAYER_CONTEXT_AUTHENTICATED   3
#define CRP_PLAYER_CONTEXT_CHARACTER       4
#define CRP_PLAYER_CONTEXT_ACTIVE          5

new bool:gPlayerContextReady[MAX_PLAYERS];
new gPlayerContextSessionID[MAX_PLAYERS];
new gPlayerContextState[MAX_PLAYERS];


// ============================================================
// PLAYER LIFECYCLE EVENT
// ============================================================

#define CRP_PLAYER_EVENT_NONE        0
#define CRP_PLAYER_EVENT_CONNECT     1
#define CRP_PLAYER_EVENT_SPAWN       2
#define CRP_PLAYER_EVENT_DEATH       3
#define CRP_PLAYER_EVENT_DISCONNECT  4

new gPlayerLastEvent[MAX_PLAYERS];
new gPlayerEventSessionID[MAX_PLAYERS];
new gPlayerEventCount[MAX_PLAYERS];


// ============================================================
// FORWARD DECLARATIONS
// ============================================================

forward bool:CRP_IsPlayerLifecycleCoreValid(playerid);


// ============================================================
// PLAYER VALIDATION
// ============================================================

stock bool:CRP_IsPlayerValid(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerConnected(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!IsPlayerConnected(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER IDENTITY
// ============================================================

stock bool:CRP_GetPlayerName(playerid, name[], size)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        name[0] = EOS;
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        name[0] = EOS;
        return false;
    }

    GetPlayerName(playerid, name, size);

    return true;
}


stock bool:CRP_InitPlayerIdentity(playerid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    GetPlayerName(
        playerid,
        gPlayerName[playerid],
        MAX_PLAYER_NAME + 1
    );

    if (gPlayerName[playerid][0] == EOS)
    {
        gPlayerIdentityReady[playerid] = false;
        return false;
    }

    gPlayerIdentityReady[playerid] = true;

    return true;
}


stock CRP_ResetPlayerIdentity(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerName[playerid][0] = EOS;
    gPlayerIdentityReady[playerid] = false;

    return 1;
}


stock bool:CRP_IsPlayerIdentityReady(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (gPlayerName[playerid][0] == EOS)
    {
        return false;
    }

    return true;
}


stock bool:CRP_GetCachedPlayerName(playerid, name[], size)
{
    if (!CRP_IsPlayerIdentityReady(playerid))
    {
        name[0] = EOS;
        return false;
    }

    format(
        name,
        size,
        "%s",
        gPlayerName[playerid]
    );

    return true;
}


stock bool:CRP_IsPlayerName(playerid, const name[])
{
    if (!CRP_IsPlayerIdentityReady(playerid))
    {
        return false;
    }

    if (
        strcmp(
            gPlayerName[playerid],
            name,
            true
        ) == 0
    )
    {
        return true;
    }

    return false;
}


// ============================================================
// PLAYER CHARACTER MANAGEMENT (v3.2 NEW)
// ============================================================

stock CRP_ResetPlayerCharacterData(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerCharacterID[playerid] = 0;
    gPlayerCharacterName[playerid][0] = EOS;
    gPlayerCharacterGender[playerid] = 0;
    gPlayerCharacterSkin[playerid] = 0;
    gPlayerCharacterAge[playerid] = 0;
    gPlayerCharacterDataReady[playerid] = false;

    return 1;
}


stock bool:CRP_IsPlayerCharacterDataReady(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    return gPlayerCharacterDataReady[playerid];
}


stock bool:CRP_IsPlayerCharacterDataValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerCharacterDataReady[playerid])
    {
        return false;
    }

    if (gPlayerCharacterID[playerid] <= 0)
    {
        return false;
    }

    if (gPlayerCharacterName[playerid][0] == EOS)
    {
        return false;
    }

    return true;
}


stock bool:CRP_SetPlayerActiveCharacter(playerid, charid, const charName[], gender, skin, age)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (charid <= 0)
    {
        return false;
    }

    if (charName[0] == EOS)
    {
        return false;
    }

    gPlayerCharacterID[playerid] = charid;
    format(gPlayerCharacterName[playerid], MAX_PLAYER_NAME + 1, "%s", charName);
    gPlayerCharacterGender[playerid] = gender;
    gPlayerCharacterSkin[playerid] = skin;
    gPlayerCharacterAge[playerid] = age;
    gPlayerCharacterDataReady[playerid] = true;

    return true;
}


stock CRP_GetPlayerCharacterID(playerid)
{
    if (!CRP_IsPlayerCharacterDataValid(playerid))
    {
        return 0;
    }

    return gPlayerCharacterID[playerid];
}


stock bool:CRP_GetPlayerCharacterName(playerid, name[], size)
{
    if (!CRP_IsPlayerCharacterDataValid(playerid))
    {
        name[0] = EOS;
        return false;
    }

    format(name, size, "%s", gPlayerCharacterName[playerid]);
    return true;
}


stock CRP_GetPlayerCharacterSkin(playerid)
{
    if (!CRP_IsPlayerCharacterDataValid(playerid))
    {
        return 0;
    }

    return gPlayerCharacterSkin[playerid];
}


stock CRP_DebugPlayerCharacter(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    printf(
        "[CRP] Character Data | Player: %d | CharID: %d | CharName: %s | Gender: %d | Skin: %d | Age: %d | Ready: %d",
        playerid,
        gPlayerCharacterID[playerid],
        gPlayerCharacterName[playerid],
        gPlayerCharacterGender[playerid],
        gPlayerCharacterSkin[playerid],
        gPlayerCharacterAge[playerid],
        gPlayerCharacterDataReady[playerid]
    );

    return 1;
}


// ============================================================
// PLAYER SESSION
// ============================================================

stock CRP_StartPlayerSession(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    gPlayerSession[playerid] = false;
    gPlayerSessionID[playerid] = 0;

    gCRPSessionCounter++;

    if (gCRPSessionCounter <= 0)
    {
        gCRPSessionCounter = 1;
    }

    gPlayerSessionID[playerid] = gCRPSessionCounter;
    gPlayerSession[playerid] = true;

    return 1;
}


stock CRP_EndPlayerSession(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerSession[playerid] = false;
    gPlayerSessionID[playerid] = 0;

    return 1;
}


stock bool:CRP_IsPlayerSessionActive(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerSession[playerid])
    {
        return false;
    }

    if (gPlayerSessionID[playerid] <= 0)
    {
        return false;
    }

    return true;
}


stock CRP_GetPlayerSessionID(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerSessionID[playerid];
}


stock bool:CRP_IsValidPlayerSession(playerid, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (sessionID <= 0)
    {
        return false;
    }

    if (gPlayerSessionID[playerid] != sessionID)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER SESSION INTEGRITY
// ============================================================

stock bool:CRP_IsPlayerSessionIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (gPlayerSession[playerid])
    {
        if (!CRP_IsPlayerConnected(playerid))
        {
            return false;
        }

        if (gPlayerSessionID[playerid] <= 0)
        {
            return false;
        }

        return true;
    }

    if (gPlayerSessionID[playerid] != 0)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER RUNTIME
// ============================================================

stock CRP_SetPlayerSpawned(playerid, bool:spawned)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerSpawned[playerid] = spawned;

    return 1;
}


stock bool:CRP_IsPlayerSpawned(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    return gPlayerSpawned[playerid];
}


stock CRP_SetPlayerDead(playerid, bool:dead)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerDead[playerid] = dead;

    return 1;
}


stock bool:CRP_IsPlayerDead(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    return gPlayerDead[playerid];
}


stock CRP_ResetPlayerRuntimeData(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerSpawned[playerid] = false;
    gPlayerDead[playerid] = false;

    return 1;
}


stock bool:CRP_IsPlayerRuntimeIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (
        gPlayerSpawned[playerid] &&
        gPlayerDead[playerid]
    )
    {
        return false;
    }

    return true;
}


stock bool:CRP_CanSetPlayerSpawned(playerid, bool:spawned)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (
        spawned &&
        gPlayerDead[playerid]
    )
    {
        return false;
    }

    return true;
}


stock bool:CRP_CanSetPlayerDead(playerid, bool:dead)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (
        dead &&
        gPlayerSpawned[playerid]
    )
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER RUNTIME TRANSITION AUDIT
// ============================================================

stock CRP_ResetPlayerRuntimeTransitionAudit(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerRuntimeTransitionCount[playerid] = 0;
    gPlayerRuntimeTransitionSessionID[playerid] = 0;

    return 1;
}


stock CRP_GetPlayerRuntimeTransitionCount(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerRuntimeTransitionCount[playerid];
}


stock CRP_GetPlayerRuntimeTransitionSessionID(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerRuntimeTransitionSessionID[playerid];
}


stock bool:CRP_CanRecordPlayerRuntimeTransition(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeIntegrityValid(playerid))
    {
        return false;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (sessionID <= 0)
    {
        return false;
    }

    if (
        gPlayerRuntimeTransitionSessionID[playerid] != 0 &&
        gPlayerRuntimeTransitionSessionID[playerid] != sessionID
    )
    {
        return false;
    }

    return true;
}


stock bool:CRP_RecordPlayerRuntimeTransition(playerid)
{
    if (!CRP_CanRecordPlayerRuntimeTransition(playerid))
    {
        return false;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    gPlayerRuntimeTransitionCount[playerid]++;
    gPlayerRuntimeTransitionSessionID[playerid] = sessionID;

    return true;
}


stock bool:CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new transitionCount = gPlayerRuntimeTransitionCount[playerid];
    new transitionSessionID = gPlayerRuntimeTransitionSessionID[playerid];

    if (transitionCount == 0)
    {
        if (transitionSessionID != 0)
        {
            return false;
        }

        return true;
    }

    if (transitionCount < 0)
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (transitionSessionID <= 0)
    {
        return false;
    }

    if (transitionSessionID != gPlayerSessionID[playerid])
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER SAFE RUNTIME SETTERS
// ============================================================

stock bool:CRP_SetPlayerSpawnedSafe(playerid, bool:spawned)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_CanSetPlayerSpawned(playerid, spawned))
    {
        return false;
    }

    if (gPlayerSpawned[playerid] == spawned)
    {
        return true;
    }

    if (!CRP_CanRecordPlayerRuntimeTransition(playerid))
    {
        return false;
    }

    gPlayerSpawned[playerid] = spawned;

    if (!CRP_RecordPlayerRuntimeTransition(playerid))
    {
        return false;
    }

    return true;
}


stock bool:CRP_SetPlayerDeadSafe(playerid, bool:dead)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_CanSetPlayerDead(playerid, dead))
    {
        return false;
    }

    if (gPlayerDead[playerid] == dead)
    {
        return true;
    }

    if (!CRP_CanRecordPlayerRuntimeTransition(playerid))
    {
        return false;
    }

    gPlayerDead[playerid] = dead;

    if (!CRP_RecordPlayerRuntimeTransition(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER DATA
// ============================================================

stock bool:CRP_InitPlayerData(playerid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    gPlayerDataReady[playerid] = false;
    gPlayerDataSessionID[playerid] = 0;

    gPlayerDataSessionID[playerid] = CRP_GetPlayerSessionID(playerid);

    if (gPlayerDataSessionID[playerid] <= 0)
    {
        gPlayerDataSessionID[playerid] = 0;
        return false;
    }

    gPlayerDataReady[playerid] = true;

    return true;
}


stock CRP_ResetPlayerData(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerDataReady[playerid] = false;
    gPlayerDataSessionID[playerid] = 0;

    return 1;
}


stock bool:CRP_IsPlayerDataReady(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerDataReady[playerid])
    {
        return false;
    }

    if (gPlayerDataSessionID[playerid] <= 0)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerDataValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (!gPlayerDataReady[playerid])
    {
        return false;
    }

    if (gPlayerDataSessionID[playerid] <= 0)
    {
        return false;
    }

    if (gPlayerDataSessionID[playerid] != gPlayerSessionID[playerid])
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsValidPlayerDataSession(playerid, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataValid(playerid))
    {
        return false;
    }

    if (sessionID <= 0)
    {
        return false;
    }

    if (gPlayerDataSessionID[playerid] != sessionID)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerDataIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (gPlayerDataReady[playerid])
    {
        if (!CRP_IsPlayerConnected(playerid))
        {
            return false;
        }

        if (!CRP_IsPlayerSessionActive(playerid))
        {
            return false;
        }

        if (gPlayerDataSessionID[playerid] <= 0)
        {
            return false;
        }

        if (gPlayerDataSessionID[playerid] != gPlayerSessionID[playerid])
        {
            return false;
        }

        return true;
    }

    if (gPlayerDataSessionID[playerid] != 0)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER SPAWN CONTEXT
// ============================================================

stock bool:CRP_IsValidPlayerSpawnType(spawnType)
{
    if (
        spawnType < CRP_SPAWN_TYPE_NONE ||
        spawnType > CRP_SPAWN_TYPE_EVENT
    )
    {
        return false;
    }

    return true;
}


stock CRP_GetPlayerSpawnTypeName(spawnType, name[], size)
{
    switch (spawnType)
    {
        case CRP_SPAWN_TYPE_NONE:       format(name, size, "NONE");
        case CRP_SPAWN_TYPE_DEFAULT:    format(name, size, "DEFAULT");
        case CRP_SPAWN_TYPE_CHARACTER:  format(name, size, "CHARACTER");
        case CRP_SPAWN_TYPE_REGISTER:   format(name, size, "REGISTER");
        case CRP_SPAWN_TYPE_LOGOUT:     format(name, size, "LOGOUT");
        case CRP_SPAWN_TYPE_JAIL:       format(name, size, "JAIL");
        case CRP_SPAWN_TYPE_HOSPITAL:   format(name, size, "HOSPITAL");
        case CRP_SPAWN_TYPE_JOB:        format(name, size, "JOB");
        case CRP_SPAWN_TYPE_EVENT:      format(name, size, "EVENT");
        default:                        format(name, size, "UNKNOWN");
    }

    return 1;
}


// ============================================================
// PLAYER STATE NAME
// ============================================================

stock CRP_GetPlayerStateName(state, name[], size)
{
    switch (state)
    {
        case CRP_PLAYER_STATE_NONE:           format(name, size, "NONE");
        case CRP_PLAYER_STATE_CONNECTED:      format(name, size, "CONNECTED");
        case CRP_PLAYER_STATE_AUTHENTICATING: format(name, size, "AUTHENTICATING");
        case CRP_PLAYER_STATE_AUTHENTICATED:  format(name, size, "AUTHENTICATED");
        case CRP_PLAYER_STATE_CHARACTER:      format(name, size, "CHARACTER");
        case CRP_PLAYER_STATE_ACTIVE:         format(name, size, "ACTIVE");
        default:                              format(name, size, "UNKNOWN");
    }

    return 1;
}


// ============================================================
// PLAYER STATE TRANSITION
// ============================================================

stock bool:CRP_IsValidStateTransition(currentState, newState)
{
    if (currentState == newState)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_NONE && newState == CRP_PLAYER_STATE_CONNECTED)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_CONNECTED && newState == CRP_PLAYER_STATE_AUTHENTICATING)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_AUTHENTICATING && newState == CRP_PLAYER_STATE_AUTHENTICATED)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_AUTHENTICATED && newState == CRP_PLAYER_STATE_CHARACTER)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_CHARACTER && newState == CRP_PLAYER_STATE_ACTIVE)
    {
        return true;
    }

    if (currentState == CRP_PLAYER_STATE_ACTIVE && newState == CRP_PLAYER_STATE_CHARACTER)
    {
        return true;
    }

    return false;
}


// ============================================================
// PLAYER STATE INTEGRITY
// ============================================================

stock bool:CRP_IsPlayerStateIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new state = gPlayerState[playerid];

    if (state == CRP_PLAYER_STATE_NONE)
    {
        return true;
    }

    if (state < CRP_PLAYER_STATE_NONE || state > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE HISTORY TRANSITION VALIDATION
// ============================================================

stock bool:CRP_CanUpdatePlayerStateHistory(playerid, newState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    new currentState = gPlayerState[playerid];
    new previousState = gPlayerPreviousState[playerid];
    new historySessionID = gPlayerStateSessionID[playerid];
    new currentSessionID = gPlayerSessionID[playerid];

    if (currentState == CRP_PLAYER_STATE_NONE)
    {
        if (newState != CRP_PLAYER_STATE_CONNECTED)
        {
            return false;
        }

        if (previousState != CRP_PLAYER_STATE_NONE)
        {
            return false;
        }

        if (historySessionID != 0)
        {
            return false;
        }

        return true;
    }

    if (historySessionID <= 0)
    {
        return false;
    }

    if (historySessionID != currentSessionID)
    {
        return false;
    }

    if (!CRP_IsValidStateTransition(previousState, currentState))
    {
        return false;
    }

    if (!CRP_IsValidStateTransition(currentState, newState))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE HISTORY INTEGRITY
// ============================================================

stock bool:CRP_IsPlayerStateHistoryIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new currentState = gPlayerState[playerid];
    new previousState = gPlayerPreviousState[playerid];
    new historySessionID = gPlayerStateSessionID[playerid];

    if (currentState < CRP_PLAYER_STATE_NONE || currentState > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    if (previousState < CRP_PLAYER_STATE_NONE || previousState > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    if (currentState == CRP_PLAYER_STATE_NONE)
    {
        if (previousState != CRP_PLAYER_STATE_NONE)
        {
            return false;
        }

        if (historySessionID != 0)
        {
            return false;
        }

        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (historySessionID <= 0)
    {
        return false;
    }

    if (historySessionID != gPlayerSessionID[playerid])
    {
        return false;
    }

    if (currentState == CRP_PLAYER_STATE_CONNECTED)
    {
        if (previousState != CRP_PLAYER_STATE_NONE)
        {
            return false;
        }

        return true;
    }

    if (previousState == CRP_PLAYER_STATE_NONE)
    {
        return false;
    }

    if (previousState == currentState)
    {
        return false;
    }

    if (!CRP_IsValidStateTransition(previousState, currentState))
    {
        return false;
    }

    return true;
}


stock CRP_GetPlayerPreviousState(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_PLAYER_STATE_NONE;
    }

    return gPlayerPreviousState[playerid];
}


stock CRP_GetPlayerStateSessionID(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerStateSessionID[playerid];
}


stock CRP_ResetPlayerStateHistory(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerPreviousState[playerid] = CRP_PLAYER_STATE_NONE;
    gPlayerStateSessionID[playerid] = 0;

    return 1;
}


// ============================================================
// PLAYER STATE TRANSITION AUDIT
// ============================================================

stock CRP_ResetPlayerStateTransitionAudit(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerStateTransitionCount[playerid] = 0;
    gPlayerStateTransitionSessionID[playerid] = 0;

    return 1;
}


stock CRP_GetPlayerStateTransitionCount(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerStateTransitionCount[playerid];
}


stock CRP_GetPlayerStateTransitionSessionID(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerStateTransitionSessionID[playerid];
}


stock bool:CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new currentState = gPlayerState[playerid];
    new transitionCount = gPlayerStateTransitionCount[playerid];
    new transitionSessionID = gPlayerStateTransitionSessionID[playerid];

    if (currentState == CRP_PLAYER_STATE_NONE)
    {
        if (transitionCount != 0)
        {
            return false;
        }

        if (transitionSessionID != 0)
        {
            return false;
        }

        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (transitionCount <= 0)
    {
        return false;
    }

    if (transitionSessionID <= 0)
    {
        return false;
    }

    if (transitionSessionID != gPlayerSessionID[playerid])
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ENTRY VALIDATION
// ============================================================

stock bool:CRP_CanEnterPlayerState(playerid, newState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (newState == CRP_PLAYER_STATE_NONE)
    {
        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    switch (newState)
    {
        case CRP_PLAYER_STATE_CONNECTED:
        {
            return true;
        }

        case CRP_PLAYER_STATE_AUTHENTICATING:
        {
            if (gPlayerState[playerid] != CRP_PLAYER_STATE_CONNECTED)
            {
                return false;
            }

            return true;
        }

        case CRP_PLAYER_STATE_AUTHENTICATED:
        {
            if (gPlayerState[playerid] != CRP_PLAYER_STATE_AUTHENTICATING)
            {
                return false;
            }

            return true;
        }

        case CRP_PLAYER_STATE_CHARACTER:
        {
            if (gPlayerState[playerid] != CRP_PLAYER_STATE_AUTHENTICATED)
            {
                return false;
            }

            return true;
        }

        case CRP_PLAYER_STATE_ACTIVE:
        {
            if (gPlayerState[playerid] != CRP_PLAYER_STATE_CHARACTER)
            {
                return false;
            }

            return true;
        }
    }

    return false;
}


// ============================================================
// PLAYER LIFECYCLE CORE VALIDATION (v3.2 REVISED)
// ============================================================

stock bool:CRP_IsPlayerLifecycleCoreValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerSessionIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateHistoryIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    // Checking Character Data Consistency for Active State (v3.2)
    if (gPlayerState[playerid] == CRP_PLAYER_STATE_ACTIVE)
    {
        if (!CRP_IsPlayerCharacterDataValid(playerid))
        {
            return false;
        }
    }

    return true;
}


// ============================================================
// PLAYER CONTEXT
// ============================================================

stock bool:CRP_IsValidPlayerContextState(state)
{
    if (state < CRP_PLAYER_CONTEXT_NONE || state > CRP_PLAYER_CONTEXT_ACTIVE)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerContextIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new contextState = gPlayerContextState[playerid];

    if (!CRP_IsValidPlayerContextState(contextState))
    {
        return false;
    }

    if (!gPlayerContextReady[playerid])
    {
        if (gPlayerContextSessionID[playerid] != 0)
        {
            return false;
        }

        if (contextState != CRP_PLAYER_CONTEXT_NONE)
        {
            return false;
        }

        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (gPlayerContextSessionID[playerid] <= 0)
    {
        return false;
    }

    if (gPlayerContextSessionID[playerid] != gPlayerSessionID[playerid])
    {
        return false;
    }

    if (contextState == CRP_PLAYER_CONTEXT_NONE)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerContextValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleCoreValid(playerid))
    {
        return false;
    }

    if (!gPlayerContextReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerContextIntegrityValid(playerid))
    {
        return false;
    }

    if (gPlayerContextSessionID[playerid] != gPlayerSessionID[playerid])
    {
        return false;
    }

    if (gPlayerContextState[playerid] != gPlayerState[playerid])
    {
        return false;
    }

    return true;
}


stock bool:CRP_InitPlayerContext(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleCoreValid(playerid))
    {
        return false;
    }

    gPlayerContextReady[playerid] = false;
    gPlayerContextSessionID[playerid] = 0;
    gPlayerContextState[playerid] = CRP_PLAYER_CONTEXT_NONE;

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (sessionID <= 0)
    {
        return false;
    }

    new state = gPlayerState[playerid];

    if (state < CRP_PLAYER_STATE_CONNECTED || state > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    gPlayerContextSessionID[playerid] = sessionID;
    gPlayerContextState[playerid] = state;
    gPlayerContextReady[playerid] = true;

    return true;
}


stock CRP_ResetPlayerContext(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerContextReady[playerid] = false;
    gPlayerContextSessionID[playerid] = 0;
    gPlayerContextState[playerid] = CRP_PLAYER_CONTEXT_NONE;

    return 1;
}


stock bool:CRP_IsValidPlayerContextSession(playerid, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerContextValid(playerid))
    {
        return false;
    }

    if (sessionID <= 0)
    {
        return false;
    }

    if (gPlayerContextSessionID[playerid] != sessionID)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerContextStateValid(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (requiredState < CRP_PLAYER_STATE_CONNECTED || requiredState > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    if (!CRP_IsPlayerContextValid(playerid))
    {
        return false;
    }

    if (gPlayerContextState[playerid] != requiredState)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER CONTEXT STATE TRANSACTION VALIDATION
// ============================================================

stock bool:CRP_CanUpdatePlayerContextState(playerid, newState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidPlayerContextState(newState))
    {
        return false;
    }

    if (!gPlayerContextReady[playerid])
    {
        return true;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (gPlayerContextSessionID[playerid] != gPlayerSessionID[playerid])
    {
        return false;
    }

    return true;
}


stock bool:CRP_UpdatePlayerContextState(playerid, newState)
{
    if (!CRP_CanUpdatePlayerContextState(playerid, newState))
    {
        return false;
    }

    if (!gPlayerContextReady[playerid])
    {
        return true;
    }

    gPlayerContextState[playerid] = newState;

    return true;
}


stock CRP_DebugPlayerContext(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new stateName[32];

    CRP_GetPlayerStateName(
        gPlayerState[playerid],
        stateName,
        sizeof(stateName)
    );

    printf(
        "[CRP] Player Context | Player: %d | Name: %s | Ready: %d | Session: %d | Context Session: %d | State: %s | Context State: %d",
        playerid,
        gPlayerName[playerid],
        gPlayerContextReady[playerid],
        gPlayerSessionID[playerid],
        gPlayerContextSessionID[playerid],
        stateName,
        gPlayerContextState[playerid]
    );

    if (CRP_IsPlayerContextValid(playerid))
    {
        printf("[CRP] Player Context | Status: VALID");
    }
    else
    {
        printf("[CRP] Player Context | Status: INVALID");
    }

    return 1;
}


// ============================================================
// PLAYER LIFECYCLE EVENT
// ============================================================

stock bool:CRP_IsValidPlayerEvent(eventType)
{
    if (eventType < CRP_PLAYER_EVENT_NONE || eventType > CRP_PLAYER_EVENT_DISCONNECT)
    {
        return false;
    }

    return true;
}


stock CRP_GetPlayerEventName(eventType, name[], size)
{
    switch (eventType)
    {
        case CRP_PLAYER_EVENT_NONE:       format(name, size, "NONE");
        case CRP_PLAYER_EVENT_CONNECT:    format(name, size, "CONNECT");
        case CRP_PLAYER_EVENT_SPAWN:      format(name, size, "SPAWN");
        case CRP_PLAYER_EVENT_DEATH:      format(name, size, "DEATH");
        case CRP_PLAYER_EVENT_DISCONNECT: format(name, size, "DISCONNECT");
        default:                          format(name, size, "UNKNOWN");
    }

    return 1;
}


stock CRP_ResetPlayerEvent(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerLastEvent[playerid] = CRP_PLAYER_EVENT_NONE;
    gPlayerEventSessionID[playerid] = 0;
    gPlayerEventCount[playerid] = 0;

    return 1;
}


stock bool:CRP_IsPlayerLifecycleEventIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new lastEvent = gPlayerLastEvent[playerid];
    new eventSessionID = gPlayerEventSessionID[playerid];
    new eventCount = gPlayerEventCount[playerid];

    if (!CRP_IsValidPlayerEvent(lastEvent))
    {
        return false;
    }

    if (lastEvent == CRP_PLAYER_EVENT_NONE)
    {
        if (eventSessionID != 0)
        {
            return false;
        }

        if (eventCount != 0)
        {
            return false;
        }

        return true;
    }

    if (eventCount <= 0)
    {
        return false;
    }

    if (eventSessionID <= 0)
    {
        return false;
    }

    if (eventSessionID != gPlayerSessionID[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// NORMAL PLAYER EVENT VALIDATION
// ============================================================

stock bool:CRP_CanHandlePlayerEvent(playerid, eventType)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidPlayerEvent(eventType))
    {
        return false;
    }

    if (eventType == CRP_PLAYER_EVENT_NONE)
    {
        return false;
    }

    if (eventType == CRP_PLAYER_EVENT_DISCONNECT)
    {
        return false;
    }

    new lastEvent = gPlayerLastEvent[playerid];

    if (eventType == CRP_PLAYER_EVENT_CONNECT)
    {
        if (lastEvent != CRP_PLAYER_EVENT_NONE)
        {
            return false;
        }

        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return false;
    }

    if (eventType == CRP_PLAYER_EVENT_SPAWN)
    {
        if (
            lastEvent != CRP_PLAYER_EVENT_CONNECT &&
            lastEvent != CRP_PLAYER_EVENT_SPAWN &&
            lastEvent != CRP_PLAYER_EVENT_DEATH
        )
        {
            return false;
        }

        return true;
    }

    if (eventType == CRP_PLAYER_EVENT_DEATH)
    {
        if (lastEvent != CRP_PLAYER_EVENT_SPAWN)
        {
            return false;
        }

        return true;
    }

    return false;
}


// ============================================================
// DISCONNECT EVENT VALIDATION
// ============================================================

stock bool:CRP_CanHandlePlayerDisconnectEvent(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new lastEvent = gPlayerLastEvent[playerid];

    if (
        lastEvent != CRP_PLAYER_EVENT_CONNECT &&
        lastEvent != CRP_PLAYER_EVENT_SPAWN &&
        lastEvent != CRP_PLAYER_EVENT_DEATH
    )
    {
        return false;
    }

    if (!gPlayerSession[playerid])
    {
        return false;
    }

    if (gPlayerSessionID[playerid] <= 0)
    {
        return false;
    }

    return true;
}


stock bool:CRP_RecordPlayerDisconnectEvent(playerid)
{
    if (!CRP_CanHandlePlayerDisconnectEvent(playerid))
    {
        return false;
    }

    new sessionID = gPlayerSessionID[playerid];

    gPlayerLastEvent[playerid] = CRP_PLAYER_EVENT_DISCONNECT;
    gPlayerEventSessionID[playerid] = sessionID;
    gPlayerEventCount[playerid]++;

    return true;
}


stock CRP_RecordPlayerEvent(playerid, eventType)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    if (eventType == CRP_PLAYER_EVENT_DISCONNECT)
    {
        return CRP_RecordPlayerDisconnectEvent(playerid);
    }

    if (!CRP_CanHandlePlayerEvent(playerid, eventType))
    {
        return 0;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (sessionID <= 0)
    {
        return 0;
    }

    gPlayerLastEvent[playerid] = eventType;
    gPlayerEventSessionID[playerid] = sessionID;
    gPlayerEventCount[playerid]++;

    return 1;
}


stock CRP_GetPlayerLastEvent(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_PLAYER_STATE_NONE;
    }

    return gPlayerLastEvent[playerid];
}


stock CRP_GetPlayerEventSessionID(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerEventSessionID[playerid];
}


stock CRP_GetPlayerEventCount(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    return gPlayerEventCount[playerid];
}


stock bool:CRP_IsPlayerEventSessionValid(playerid, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return false;
    }

    if (sessionID <= 0)
    {
        return false;
    }

    if (gPlayerEventSessionID[playerid] != sessionID)
    {
        return false;
    }

    if (gPlayerEventSessionID[playerid] != gPlayerSessionID[playerid])
    {
        return false;
    }

    return true;
}


stock CRP_DebugPlayerEvent(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new eventName[32];

    CRP_GetPlayerEventName(
        gPlayerLastEvent[playerid],
        eventName,
        sizeof(eventName)
    );

    printf(
        "[CRP] Lifecycle Event | Player: %d | Name: %s | Event: %s | Event Count: %d | Session: %d | Event Session: %d",
        playerid,
        gPlayerName[playerid],
        eventName,
        gPlayerEventCount[playerid],
        gPlayerSessionID[playerid],
        gPlayerEventSessionID[playerid]
    );

    if (CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        printf("[CRP] Lifecycle Event | Status: VALID");
    }
    else
    {
        printf("[CRP] Lifecycle Event | Status: INVALID");
    }

    return 1;
}


// ============================================================
// PLAYER STATE FUNCTIONS
// ============================================================

stock bool:CRP_SetPlayerState(playerid, newState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new currentState = gPlayerState[playerid];

    if (currentState == newState)
    {
        return true;
    }

    if (!CRP_IsValidStateTransition(currentState, newState))
    {
        return false;
    }

    if (!CRP_CanEnterPlayerState(playerid, newState))
    {
        return false;
    }

    if (!CRP_CanUpdatePlayerStateHistory(playerid, newState))
    {
        return false;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_CanUpdatePlayerContextState(playerid, newState))
    {
        return false;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (sessionID <= 0)
    {
        return false;
    }

    gPlayerPreviousState[playerid] = currentState;
    gPlayerStateSessionID[playerid] = sessionID;

    gPlayerStateTransitionCount[playerid]++;
    gPlayerStateTransitionSessionID[playerid] = sessionID;

    gPlayerState[playerid] = newState;

    if (gPlayerContextReady[playerid])
    {
        gPlayerContextState[playerid] = newState;
    }

    return true;
}


stock CRP_GetPlayerState(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_PLAYER_STATE_NONE;
    }

    return gPlayerState[playerid];
}


stock CRP_ResetPlayerState(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerState[playerid] = CRP_PLAYER_STATE_NONE;

    return 1;
}


// ============================================================
// PLAYER SPAWN CONTEXT
// ============================================================

stock bool:CRP_SetPlayerSpawnType(playerid, spawnType)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidPlayerSpawnType(spawnType))
    {
        return false;
    }

    if (spawnType != CRP_SPAWN_TYPE_NONE)
    {
        if (!CRP_IsPlayerLifecycleCoreValid(playerid))
        {
            return false;
        }
    }

    gPlayerSpawnType[playerid] = spawnType;

    return true;
}


stock CRP_GetPlayerSpawnType(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_SPAWN_TYPE_NONE;
    }

    return gPlayerSpawnType[playerid];
}


stock CRP_ResetPlayerSpawnType(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    gPlayerSpawnType[playerid] = CRP_SPAWN_TYPE_NONE;

    return 1;
}


stock bool:CRP_IsPlayerSpawnTypeIntegrityValid(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    new spawnType = gPlayerSpawnType[playerid];

    if (!CRP_IsValidPlayerSpawnType(spawnType))
    {
        return false;
    }

    if (spawnType == CRP_SPAWN_TYPE_NONE)
    {
        return true;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleCoreValid(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER LIFECYCLE VALIDATION
// ============================================================

stock bool:CRP_IsPlayerLifecycleValid(playerid)
{
    if (!CRP_IsPlayerLifecycleCoreValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSpawnTypeIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerContextValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER LIFECYCLE SESSION VALIDATION
// ============================================================

stock bool:CRP_IsPlayerLifecycleSessionValid(playerid, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateHistoryIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidPlayerSession(playerid, sessionID))
    {
        return false;
    }

    if (!CRP_IsValidPlayerDataSession(playerid, sessionID))
    {
        return false;
    }

    if (gPlayerStateSessionID[playerid] != sessionID)
    {
        return false;
    }

    if (gPlayerStateTransitionSessionID[playerid] != sessionID)
    {
        return false;
    }

    if (
        gPlayerRuntimeTransitionCount[playerid] > 0 &&
        gPlayerRuntimeTransitionSessionID[playerid] != sessionID
    )
    {
        return false;
    }

    if (!CRP_IsValidPlayerContextSession(playerid, sessionID))
    {
        return false;
    }

    if (!CRP_IsPlayerEventSessionValid(playerid, sessionID))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS POLICY
// ============================================================

stock bool:CRP_IsValidStateAccessRequirement(requiredState)
{
    if (requiredState < CRP_PLAYER_STATE_CONNECTED || requiredState > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS INTEGRITY
// ============================================================

stock bool:CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return false;
    }

    if (gPlayerState[playerid] < CRP_PLAYER_STATE_NONE || gPlayerState[playerid] > CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS POLICY VALIDATION
// ============================================================

stock bool:CRP_IsPlayerStateAccessPolicyValid(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return false;
    }

    if (!CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS REASON NAME
// ============================================================

stock CRP_GetPlayerStateAccessReasonName(reason, name[], size)
{
    switch (reason)
    {
        case CRP_ACCESS_REASON_NONE:                 format(name, size, "NONE");
        case CRP_ACCESS_REASON_INVALID_PLAYER:       format(name, size, "INVALID_PLAYER");
        case CRP_ACCESS_REASON_INVALID_REQUIREMENT:  format(name, size, "INVALID_REQUIREMENT");
        case CRP_ACCESS_REASON_INVALID_ACCESS_STATE: format(name, size, "INVALID_ACCESS_STATE");
        case CRP_ACCESS_REASON_LIFECYCLE_INVALID:   format(name, size, "LIFECYCLE_INVALID");
        case CRP_ACCESS_REASON_SESSION_INVALID:     format(name, size, "SESSION_INVALID");
        case CRP_ACCESS_REASON_STATE_MISMATCH:      format(name, size, "STATE_MISMATCH");
        case CRP_ACCESS_REASON_STATE_TOO_LOW:       format(name, size, "STATE_TOO_LOW");
        case CRP_ACCESS_REASON_STATE_ALLOWED:       format(name, size, "STATE_ALLOWED");
        default:                                     format(name, size, "UNKNOWN");
    }

    return 1;
}


// ============================================================
// PLAYER STATE ACCESS REASON VALIDATION
// ============================================================

stock bool:CRP_IsValidPlayerStateAccessReason(reason)
{
    if (reason < CRP_ACCESS_REASON_NONE || reason > CRP_ACCESS_REASON_STATE_ALLOWED)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS RESULT VALIDATION
// ============================================================

stock bool:CRP_IsValidPlayerStateAccessResult(result)
{
    if (result < CRP_ACCESS_RESULT_DENIED || result > CRP_ACCESS_RESULT_ALLOWED)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE ACCESS REASON -> RESULT
// ============================================================

stock CRP_GetPlayerStateAccessResultFromReason(reason)
{
    if (!CRP_IsValidPlayerStateAccessReason(reason))
    {
        return CRP_ACCESS_RESULT_DENIED;
    }

    if (reason == CRP_ACCESS_REASON_STATE_ALLOWED)
    {
        return CRP_ACCESS_RESULT_ALLOWED;
    }

    return CRP_ACCESS_RESULT_DENIED;
}


// ============================================================
// PLAYER STATE ACCESS DECISION CONSISTENCY
// ============================================================

stock bool:CRP_IsPlayerStateAccessDecisionConsistent(result, reason)
{
    if (!CRP_IsValidPlayerStateAccessResult(result))
    {
        return false;
    }

    if (!CRP_IsValidPlayerStateAccessReason(reason))
    {
        return false;
    }

    if (result != CRP_GetPlayerStateAccessResultFromReason(reason))
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER STATE EXACT ACCESS DECISION REASON
// ============================================================

stock CRP_DecidePlayerStateExactAccessReason(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_ACCESS_REASON_INVALID_PLAYER;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_REQUIREMENT;
    }

    if (!CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_ACCESS_STATE;
    }

    if (!CRP_IsPlayerLifecycleValid(playerid))
    {
        return CRP_ACCESS_REASON_LIFECYCLE_INVALID;
    }

    if (gPlayerState[playerid] != requiredState)
    {
        return CRP_ACCESS_REASON_STATE_MISMATCH;
    }

    return CRP_ACCESS_REASON_STATE_ALLOWED;
}


// ============================================================
// PLAYER STATE EXACT ACCESS SESSION DECISION REASON
// ============================================================

stock CRP_DecidePlayerStateExactAccessReasonForSession(playerid, requiredState, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_ACCESS_REASON_INVALID_PLAYER;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_REQUIREMENT;
    }

    if (!CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_ACCESS_STATE;
    }

    if (!CRP_IsPlayerLifecycleSessionValid(playerid, sessionID))
    {
        return CRP_ACCESS_REASON_SESSION_INVALID;
    }

    if (gPlayerState[playerid] != requiredState)
    {
        return CRP_ACCESS_REASON_STATE_MISMATCH;
    }

    return CRP_ACCESS_REASON_STATE_ALLOWED;
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS DECISION REASON
// ============================================================

stock CRP_DecidePlayerStateMinimumAccessReason(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_ACCESS_REASON_INVALID_PLAYER;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_REQUIREMENT;
    }

    if (!CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_ACCESS_STATE;
    }

    if (!CRP_IsPlayerLifecycleValid(playerid))
    {
        return CRP_ACCESS_REASON_LIFECYCLE_INVALID;
    }

    if (gPlayerState[playerid] < requiredState)
    {
        return CRP_ACCESS_REASON_STATE_TOO_LOW;
    }

    return CRP_ACCESS_REASON_STATE_ALLOWED;
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS SESSION DECISION REASON
// ============================================================

stock CRP_DecidePlayerStateMinimumAccessReasonForSession(playerid, requiredState, sessionID)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return CRP_ACCESS_REASON_INVALID_PLAYER;
    }

    if (!CRP_IsValidStateAccessRequirement(requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_REQUIREMENT;
    }

    if (!CRP_IsPlayerStateAccessIntegrityValid(playerid, requiredState))
    {
        return CRP_ACCESS_REASON_INVALID_ACCESS_STATE;
    }

    if (!CRP_IsPlayerLifecycleSessionValid(playerid, sessionID))
    {
        return CRP_ACCESS_REASON_SESSION_INVALID;
    }

    if (gPlayerState[playerid] < requiredState)
    {
        return CRP_ACCESS_REASON_STATE_TOO_LOW;
    }

    return CRP_ACCESS_REASON_STATE_ALLOWED;
}


// ============================================================
// PLAYER STATE EXACT ACCESS DECISION
// ============================================================

stock bool:CRP_DecidePlayerStateExactAccess(playerid, requiredState)
{
    new reason = CRP_DecidePlayerStateExactAccessReason(playerid, requiredState);
    new result = CRP_GetPlayerStateAccessResultFromReason(reason);

    if (!CRP_IsPlayerStateAccessDecisionConsistent(result, reason))
    {
        return false;
    }

    return (result == CRP_ACCESS_RESULT_ALLOWED);
}


// ============================================================
// PLAYER STATE EXACT ACCESS SESSION DECISION
// ============================================================

stock bool:CRP_DecidePlayerStateExactAccessForSession(playerid, requiredState, sessionID)
{
    new reason = CRP_DecidePlayerStateExactAccessReasonForSession(playerid, requiredState, sessionID);
    new result = CRP_GetPlayerStateAccessResultFromReason(reason);

    if (!CRP_IsPlayerStateAccessDecisionConsistent(result, reason))
    {
        return false;
    }

    return (result == CRP_ACCESS_RESULT_ALLOWED);
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS DECISION
// ============================================================

stock bool:CRP_DecidePlayerStateMinimumAccess(playerid, requiredState)
{
    new reason = CRP_DecidePlayerStateMinimumAccessReason(playerid, requiredState);
    new result = CRP_GetPlayerStateAccessResultFromReason(reason);

    if (!CRP_IsPlayerStateAccessDecisionConsistent(result, reason))
    {
        return false;
    }

    return (result == CRP_ACCESS_RESULT_ALLOWED);
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS SESSION DECISION
// ============================================================

stock bool:CRP_DecidePlayerStateMinimumAccessForSession(playerid, requiredState, sessionID)
{
    new reason = CRP_DecidePlayerStateMinimumAccessReasonForSession(playerid, requiredState, sessionID);
    new result = CRP_GetPlayerStateAccessResultFromReason(reason);

    if (!CRP_IsPlayerStateAccessDecisionConsistent(result, reason))
    {
        return false;
    }

    return (result == CRP_ACCESS_RESULT_ALLOWED);
}


// ============================================================
// PLAYER STATE ACCESS GATE
// ============================================================

stock bool:CRP_IsPlayerStateAllowed(playerid, requiredState)
{
    return CRP_DecidePlayerStateExactAccess(playerid, requiredState);
}


// ============================================================
// PLAYER STATE ACCESS SESSION GATE
// ============================================================

stock bool:CRP_IsPlayerStateAllowedForSession(playerid, requiredState, sessionID)
{
    return CRP_DecidePlayerStateExactAccessForSession(playerid, requiredState, sessionID);
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS
// ============================================================

stock bool:CRP_IsPlayerStateAtLeast(playerid, requiredState)
{
    return CRP_DecidePlayerStateMinimumAccess(playerid, requiredState);
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS SESSION GATE
// ============================================================

stock bool:CRP_IsPlayerStateAtLeastForSession(playerid, requiredState, sessionID)
{
    return CRP_DecidePlayerStateMinimumAccessForSession(playerid, requiredState, sessionID);
}


// ============================================================
// PLAYER STATE ACCESS DEBUG
// ============================================================

stock CRP_DebugPlayerStateAccess(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new currentStateName[32];
    new requiredStateName[32];

    CRP_GetPlayerStateName(gPlayerState[playerid], currentStateName, sizeof(currentStateName));
    CRP_GetPlayerStateName(requiredState, requiredStateName, sizeof(requiredStateName));

    printf(
        "[CRP] State Access | Player: %d | Current: %s | Required: %s | Session: %d",
        playerid,
        currentStateName,
        requiredStateName,
        gPlayerSessionID[playerid]
    );

    if (CRP_IsPlayerStateAllowed(playerid, requiredState))
    {
        printf("[CRP] State Access | Status: ALLOWED");
    }
    else
    {
        printf("[CRP] State Access | Status: DENIED");
    }

    return 1;
}


// ============================================================
// PLAYER STATE MINIMUM ACCESS DEBUG
// ============================================================

stock CRP_DebugPlayerStateMinimumAccess(playerid, requiredState)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new currentStateName[32];
    new requiredStateName[32];

    CRP_GetPlayerStateName(gPlayerState[playerid], currentStateName, sizeof(currentStateName));
    CRP_GetPlayerStateName(requiredState, requiredStateName, sizeof(requiredStateName));

    printf(
        "[CRP] State Minimum Access | Player: %d | Current: %s | Minimum: %s | Session: %d",
        playerid,
        currentStateName,
        requiredStateName,
        gPlayerSessionID[playerid]
    );

    if (CRP_IsPlayerStateAtLeast(playerid, requiredState))
    {
        printf("[CRP] State Minimum Access | Status: ALLOWED");
    }
    else
    {
        printf("[CRP] State Minimum Access | Status: DENIED");
    }

    return 1;
}


// ============================================================
// PLAYER STATE ACCESS DECISION DEBUG
// ============================================================

stock CRP_DebugPlayerStateAccessDecision(playerid, requiredState, bool:minimumAccess)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new currentStateName[32];
    new requiredStateName[32];

    CRP_GetPlayerStateName(gPlayerState[playerid], currentStateName, sizeof(currentStateName));
    CRP_GetPlayerStateName(requiredState, requiredStateName, sizeof(requiredStateName));

    printf(
        "[CRP] Access Decision | Player: %d | Current: %s | Required: %s | Session: %d | Mode: %s",
        playerid,
        currentStateName,
        requiredStateName,
        gPlayerSessionID[playerid],
        minimumAccess ? "MINIMUM" : "EXACT"
    );

    if (minimumAccess)
    {
        if (CRP_DecidePlayerStateMinimumAccess(playerid, requiredState))
        {
            printf("[CRP] Access Decision | Result: ALLOWED");
        }
        else
        {
            printf("[CRP] Access Decision | Result: DENIED");
        }
    }
    else
    {
        if (CRP_DecidePlayerStateExactAccess(playerid, requiredState))
        {
            printf("[CRP] Access Decision | Result: ALLOWED");
        }
        else
        {
            printf("[CRP] Access Decision | Result: DENIED");
        }
    }

    return 1;
}


// ============================================================
// PLAYER STATE ACCESS DECISION REASON DEBUG
// ============================================================

stock CRP_DebugPlayerStateAccessDecisionReason(playerid, requiredState, bool:minimumAccess)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new currentStateName[32];
    new requiredStateName[32];
    new reasonName[40];
    new reason;

    CRP_GetPlayerStateName(gPlayerState[playerid], currentStateName, sizeof(currentStateName));
    CRP_GetPlayerStateName(requiredState, requiredStateName, sizeof(requiredStateName));

    if (minimumAccess)
    {
        reason = CRP_DecidePlayerStateMinimumAccessReason(playerid, requiredState);
    }
    else
    {
        reason = CRP_DecidePlayerStateExactAccessReason(playerid, requiredState);
    }

    CRP_GetPlayerStateAccessReasonName(reason, reasonName, sizeof(reasonName));

    printf(
        "[CRP] Access Decision Reason | Player: %d | Current: %s | Required: %s | Session: %d | Mode: %s",
        playerid,
        currentStateName,
        requiredStateName,
        gPlayerSessionID[playerid],
        minimumAccess ? "MINIMUM" : "EXACT"
    );

    if (reason == CRP_ACCESS_REASON_STATE_ALLOWED)
    {
        printf("[CRP] Access Decision Reason | Result: ALLOWED | Reason: %s", reasonName);
    }
    else
    {
        printf("[CRP] Access Decision Reason | Result: DENIED | Reason: %s", reasonName);
    }

    return 1;
}


// ============================================================
// PLAYER STATE ACCESS DECISION CONSISTENCY DEBUG
// ============================================================

stock CRP_DebugPlayerStateAccessDecisionConsistency(playerid, requiredState, bool:minimumAccess)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new currentStateName[32];
    new requiredStateName[32];
    new reasonName[40];

    new reason;
    new result;
    new expectedResult;

    CRP_GetPlayerStateName(gPlayerState[playerid], currentStateName, sizeof(currentStateName));
    CRP_GetPlayerStateName(requiredState, requiredStateName, sizeof(requiredStateName));

    if (minimumAccess)
    {
        reason = CRP_DecidePlayerStateMinimumAccessReason(playerid, requiredState);
    }
    else
    {
        reason = CRP_DecidePlayerStateExactAccessReason(playerid, requiredState);
    }

    result = CRP_GetPlayerStateAccessResultFromReason(reason);
    expectedResult = CRP_GetPlayerStateAccessResultFromReason(reason);

    CRP_GetPlayerStateAccessReasonName(reason, reasonName, sizeof(reasonName));

    printf(
        "[CRP] Access Consistency | Player: %d | Current: %s | Required: %s | Mode: %s | Reason: %s | Result: %d | Expected: %d",
        playerid,
        currentStateName,
        requiredStateName,
        minimumAccess ? "MINIMUM" : "EXACT",
        reasonName,
        result,
        expectedResult
    );

    if (CRP_IsPlayerStateAccessDecisionConsistent(result, reason))
    {
        printf("[CRP] Access Consistency | Status: VALID");
    }
    else
    {
        printf("[CRP] Access Consistency | Status: INVALID");
    }

    return 1;
}


// ============================================================
// PLAYER SYSTEM STATUS (v3.2 REVISED)
// ============================================================

stock bool:CRP_IsPlayerActive(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSessionActive(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerDataValid(playerid))
    {
        return false;
    }

    // Checking character readiness (v3.2)
    if (!CRP_IsPlayerCharacterDataValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateHistoryIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerContextValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return false;
    }

    if (gPlayerState[playerid] != CRP_PLAYER_STATE_ACTIVE)
    {
        return false;
    }

    return true;
}


stock bool:CRP_IsPlayerSystemReady(playerid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!gPlayerIdentityReady[playerid])
    {
        return false;
    }

    if (!CRP_IsPlayerSessionIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerDataValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateHistoryIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerSpawnTypeIntegrityValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerContextValid(playerid))
    {
        return false;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return false;
    }

    if (CRP_GetPlayerState(playerid) == CRP_PLAYER_STATE_NONE)
    {
        return false;
    }

    return true;
}


// ============================================================
// PLAYER DEBUG
// ============================================================

stock CRP_DebugPlayerIdentity(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    printf(
        "[CRP] Player Identity | ID: %d | Name: %s | Session: %d",
        playerid,
        gPlayerName[playerid],
        CRP_GetPlayerSessionID(playerid)
    );

    return 1;
}


stock CRP_DebugPlayerSession(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    printf(
        "[CRP] Session | Player: %d | Name: %s | Session ID: %d | Status: %d",
        playerid,
        gPlayerName[playerid],
        gPlayerSessionID[playerid],
        gPlayerSession[playerid]
    );

    return 1;
}


stock CRP_DebugPlayerState(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new stateName[32];

    CRP_GetPlayerStateName(gPlayerState[playerid], stateName, sizeof(stateName));

    printf(
        "[CRP] Player State | Player: %d | State: %s | Session: %d",
        playerid,
        stateName,
        gPlayerSessionID[playerid]
    );

    return 1;
}


stock CRP_DebugPlayerRuntimeTransition(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    printf(
        "[CRP] Runtime Transition | Player: %d | Name: %s | Spawned: %d | Dead: %d | Count: %d | Session: %d | Runtime Session: %d",
        playerid,
        gPlayerName[playerid],
        gPlayerSpawned[playerid],
        gPlayerDead[playerid],
        gPlayerRuntimeTransitionCount[playerid],
        gPlayerSessionID[playerid],
        gPlayerRuntimeTransitionSessionID[playerid]
    );

    if (CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        printf("[CRP] Runtime Transition | Status: VALID");
    }
    else
    {
        printf("[CRP] Runtime Transition | Status: INVALID");
    }

    return 1;
}


stock CRP_DebugPlayerLifecycle(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new stateName[32];
    new eventName[32];

    CRP_GetPlayerStateName(gPlayerState[playerid], stateName, sizeof(stateName));
    CRP_GetPlayerEventName(gPlayerLastEvent[playerid], eventName, sizeof(eventName));

    printf(
        "[CRP] Lifecycle | Player: %d | State: %s | Previous: %d | Identity: %d | Session: %d | State Session: %d | Transition Count: %d | Transition Session: %d | Data: %d | Data Session: %d | Context: %d | Context Session: %d | Context State: %d | Event: %s | Event Count: %d | Event Session: %d | Spawned: %d | Dead: %d | Runtime Transition Count: %d | Runtime Transition Session: %d | Spawn Type: %d",
        playerid,
        stateName,
        gPlayerPreviousState[playerid],
        gPlayerIdentityReady[playerid],
        gPlayerSessionID[playerid],
        gPlayerStateSessionID[playerid],
        gPlayerStateTransitionCount[playerid],
        gPlayerStateTransitionSessionID[playerid],
        gPlayerDataReady[playerid],
        gPlayerDataSessionID[playerid],
        gPlayerContextReady[playerid],
        gPlayerContextSessionID[playerid],
        gPlayerContextState[playerid],
        eventName,
        gPlayerEventCount[playerid],
        gPlayerEventSessionID[playerid],
        gPlayerSpawned[playerid],
        gPlayerDead[playerid],
        gPlayerRuntimeTransitionCount[playerid],
        gPlayerRuntimeTransitionSessionID[playerid],
        gPlayerSpawnType[playerid]
    );

    if (CRP_IsPlayerLifecycleValid(playerid))
    {
        printf("[CRP] Lifecycle | Status: VALID");
    }
    else
    {
        printf("[CRP] Lifecycle | Status: INVALID");
    }

    return 1;
}


// ============================================================
// PLAYER CONNECT (v3.2 REVISED)
// ============================================================

stock CRP_HandlePlayerConnect(playerid)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    CRP_ResetPlayerRuntimeData(playerid);
    CRP_ResetPlayerRuntimeTransitionAudit(playerid);
    CRP_ResetPlayerIdentity(playerid);
    CRP_ResetPlayerData(playerid);
    CRP_ResetPlayerCharacterData(playerid); // Reset Character Data (v3.2)
    CRP_ResetPlayerContext(playerid);
    CRP_ResetPlayerEvent(playerid);
    CRP_ResetPlayerSpawnType(playerid);
    CRP_ResetPlayerStateHistory(playerid);
    CRP_ResetPlayerStateTransitionAudit(playerid);
    CRP_EndPlayerSession(playerid);
    CRP_ResetPlayerState(playerid);

    if (!CRP_StartPlayerSession(playerid))
    {
        return 0;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (!CRP_InitPlayerIdentity(playerid))
    {
        CRP_EndPlayerSession(playerid);
        return 0;
    }

    if (!CRP_InitPlayerData(playerid))
    {
        CRP_ResetPlayerIdentity(playerid);
        CRP_EndPlayerSession(playerid);
        return 0;
    }

    if (!CRP_SetPlayerState(playerid, CRP_PLAYER_STATE_CONNECTED))
    {
        CRP_ResetPlayerData(playerid);
        CRP_ResetPlayerIdentity(playerid);
        CRP_ResetPlayerStateHistory(playerid);
        CRP_ResetPlayerStateTransitionAudit(playerid);
        CRP_EndPlayerSession(playerid);

        return 0;
    }

    if (!CRP_RecordPlayerEvent(playerid, CRP_PLAYER_EVENT_CONNECT))
    {
        CRP_ResetPlayerState(playerid);
        CRP_ResetPlayerStateHistory(playerid);
        CRP_ResetPlayerStateTransitionAudit(playerid);
        CRP_ResetPlayerData(playerid);
        CRP_ResetPlayerIdentity(playerid);
        CRP_EndPlayerSession(playerid);

        return 0;
    }

    if (!CRP_InitPlayerContext(playerid))
    {
        CRP_ResetPlayerEvent(playerid);
        CRP_ResetPlayerState(playerid);
        CRP_ResetPlayerStateHistory(playerid);
        CRP_ResetPlayerStateTransitionAudit(playerid);
        CRP_ResetPlayerData(playerid);
        CRP_ResetPlayerIdentity(playerid);
        CRP_EndPlayerSession(playerid);
        CRP_ResetPlayerRuntimeData(playerid);
        CRP_ResetPlayerRuntimeTransitionAudit(playerid);
        CRP_ResetPlayerSpawnType(playerid);

        return 0;
    }

    if (!CRP_IsPlayerLifecycleValid(playerid))
    {
        CRP_ResetPlayerEvent(playerid);
        CRP_ResetPlayerContext(playerid);
        CRP_ResetPlayerState(playerid);
        CRP_ResetPlayerStateHistory(playerid);
        CRP_ResetPlayerStateTransitionAudit(playerid);
        CRP_ResetPlayerData(playerid);
        CRP_ResetPlayerIdentity(playerid);
        CRP_EndPlayerSession(playerid);
        CRP_ResetPlayerRuntimeData(playerid);
        CRP_ResetPlayerRuntimeTransitionAudit(playerid);
        CRP_ResetPlayerSpawnType(playerid);

        return 0;
    }

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Selamat datang di Crystal Roleplay Development."
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Crystal Roleplay Development | Core v3.2"
    );

    CRP_DebugPlayerIdentity(playerid);
    CRP_DebugPlayerSession(playerid);
    CRP_DebugPlayerState(playerid);
    CRP_DebugPlayerContext(playerid);
    CRP_DebugPlayerEvent(playerid);
    CRP_DebugPlayerRuntimeTransition(playerid);
    CRP_DebugPlayerLifecycle(playerid);

    printf(
        "[CRP] Lifecycle | Player connected | ID: %d | Name: %s | Session: %d | State Session: %d | Transition Count: %d | Context Session: %d | Context State: %d | Event: %d | Event Count: %d | Runtime Transition Count: %d | Runtime Transition Session: %d",
        playerid,
        gPlayerName[playerid],
        sessionID,
        gPlayerStateSessionID[playerid],
        gPlayerStateTransitionCount[playerid],
        gPlayerContextSessionID[playerid],
        gPlayerContextState[playerid],
        gPlayerLastEvent[playerid],
        gPlayerEventCount[playerid],
        gPlayerRuntimeTransitionCount[playerid],
        gPlayerRuntimeTransitionSessionID[playerid]
    );

    return 1;
}


// ============================================================
// PLAYER SPAWN
// ============================================================

stock CRP_HandlePlayerSpawn(playerid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerLifecycleValid(playerid))
    {
        return 0;
    }

    if (!CRP_CanHandlePlayerEvent(playerid, CRP_PLAYER_EVENT_SPAWN))
    {
        return 0;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (CRP_GetPlayerSpawnType(playerid) == CRP_SPAWN_TYPE_NONE)
    {
        if (!CRP_SetPlayerSpawnType(playerid, CRP_SPAWN_TYPE_DEFAULT))
        {
            return 0;
        }
    }

    if (!CRP_SetPlayerDeadSafe(playerid, false))
    {
        return 0;
    }

    if (!CRP_SetPlayerSpawnedSafe(playerid, true))
    {
        return 0;
    }

    if (!CRP_RecordPlayerEvent(playerid, CRP_PLAYER_EVENT_SPAWN))
    {
        CRP_SetPlayerSpawned(playerid, false);
        return 0;
    }

    if (!CRP_IsPlayerLifecycleSessionValid(playerid, sessionID))
    {
        CRP_SetPlayerSpawned(playerid, false);
        return 0;
    }

    if (!CRP_IsPlayerSpawnTypeIntegrityValid(playerid))
    {
        CRP_SetPlayerSpawned(playerid, false);
        CRP_ResetPlayerSpawnType(playerid);

        return 0;
    }

    printf(
        "[CRP] Lifecycle | Player spawned | ID: %d | Name: %s | Session: %d | Spawn Type: %d | Event Count: %d | Runtime Transition Count: %d",
        playerid,
        gPlayerName[playerid],
        sessionID,
        gPlayerSpawnType[playerid],
        gPlayerEventCount[playerid],
        gPlayerRuntimeTransitionCount[playerid]
    );

    return 1;
}


// ============================================================
// PLAYER DEATH
// ============================================================

stock CRP_HandlePlayerDeath(playerid, killerid, reason)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerLifecycleValid(playerid))
    {
        return 0;
    }

    if (!CRP_CanHandlePlayerEvent(playerid, CRP_PLAYER_EVENT_DEATH))
    {
        return 0;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    if (!CRP_SetPlayerSpawnedSafe(playerid, false))
    {
        return 0;
    }

    if (!CRP_SetPlayerDeadSafe(playerid, true))
    {
        CRP_SetPlayerSpawned(playerid, true);
        return 0;
    }

    if (!CRP_RecordPlayerEvent(playerid, CRP_PLAYER_EVENT_DEATH))
    {
        CRP_SetPlayerDead(playerid, false);
        CRP_SetPlayerSpawned(playerid, true);

        return 0;
    }

    if (!CRP_IsPlayerLifecycleSessionValid(playerid, sessionID))
    {
        CRP_SetPlayerDead(playerid, false);
        return 0;
    }

    printf(
        "[CRP] Lifecycle | Player death | ID: %d | Killer: %d | Reason: %d | Session: %d | Spawn Type: %d | Event Count: %d | Runtime Transition Count: %d",
        playerid,
        killerid,
        reason,
        sessionID,
        gPlayerSpawnType[playerid],
        gPlayerEventCount[playerid],
        gPlayerRuntimeTransitionCount[playerid]
    );

    return 1;
}


// ============================================================
// PLAYER DISCONNECT (v3.2 REVISED)
// ============================================================

stock CRP_HandlePlayerDisconnect(playerid, reason)
{
    if (!CRP_IsPlayerValid(playerid))
    {
        return 0;
    }

    new sessionID = CRP_GetPlayerSessionID(playerid);

    printf(
        "[CRP] Lifecycle | Player disconnect | ID: %d | Name: %s | Session: %d | Reason: %d | Runtime Transition Count: %d",
        playerid,
        gPlayerName[playerid],
        sessionID,
        reason,
        gPlayerRuntimeTransitionCount[playerid]
    );

    if (gPlayerLastEvent[playerid] != CRP_PLAYER_EVENT_NONE)
    {
        if (!CRP_RecordPlayerDisconnectEvent(playerid))
        {
            printf(
                "[CRP] Lifecycle | Disconnect event recording failed | ID: %d | Session: %d",
                playerid,
                sessionID
            );
        }
        else
        {
            printf(
                "[CRP] Lifecycle | Disconnect event recorded | ID: %d | Session: %d | Event Count: %d",
                playerid,
                sessionID,
                gPlayerEventCount[playerid]
            );
        }
    }

    CRP_EndPlayerSession(playerid);
    CRP_ResetPlayerContext(playerid);
    CRP_ResetPlayerData(playerid);
    CRP_ResetPlayerCharacterData(playerid); // Clear character data (v3.2)
    CRP_ResetPlayerSpawnType(playerid);
    CRP_ResetPlayerStateHistory(playerid);
    CRP_ResetPlayerStateTransitionAudit(playerid);
    CRP_ResetPlayerRuntimeTransitionAudit(playerid);
    CRP_ResetPlayerState(playerid);
    CRP_ResetPlayerRuntimeData(playerid);
    CRP_ResetPlayerIdentity(playerid);
    CRP_ResetPlayerEvent(playerid);

    if (!CRP_IsPlayerSessionIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerDataIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerContextIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerStateHistoryIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerStateTransitionAuditIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerRuntimeTransitionAuditIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerSpawnTypeIntegrityValid(playerid))
    {
        return 0;
    }

    if (!CRP_IsPlayerLifecycleEventIntegrityValid(playerid))
    {
        return 0;
    }

    if (gPlayerState[playerid] != CRP_PLAYER_STATE_NONE)
    {
        return 0;
    }

    if (gPlayerSpawned[playerid] || gPlayerDead[playerid])
    {
        return 0;
    }

    if (gPlayerIdentityReady[playerid])
    {
        return 0;
    }

    if (gPlayerCharacterDataReady[playerid]) // Character Cleanup Verification (v3.2)
    {
        return 0;
    }

    if (
        gPlayerRuntimeTransitionCount[playerid] != 0 ||
        gPlayerRuntimeTransitionSessionID[playerid] != 0
    )
    {
        return 0;
    }

    printf(
        "[CRP] Lifecycle | Player cleanup complete | ID: %d | Previous Session: %d",
        playerid,
        sessionID
    );

    return 1;
}


// ============================================================
// MAIN ENTRY POINT
// ============================================================

main()
{
    print("---------------------------------------");
    print("     CRYSTAL ROLEPLAY - DEVELOPMENT    ");
    print("     Core Gamemode v3.2                ");
    print("                                         ");
    print("     Developer : Muhammad Rizal        ");
    print("     Project   : Crystal Roleplay      ");
    print("---------------------------------------");
}


// ============================================================
// GAME MODE INIT & EXIT (v3.2 REVISED)
// ============================================================

public OnGameModeInit()
{
    SetGameModeText("Crystal Roleplay v3.2");

    SetWeather(10);
    SetWorldTime(12);

    UsePlayerPedAnims();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ShowNameTags(1);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);

    AddPlayerClass(
        7,
        1685.6346, -2242.5151, 13.5469,
        90.0,
        0, 0, 0, 0, 0, 0
    );

    gCRPSessionCounter = 0;

    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        CRP_ResetPlayerIdentity(playerid);
        CRP_ResetPlayerData(playerid);
        CRP_ResetPlayerCharacterData(playerid); // Init/Reset Character (v3.2)
        CRP_ResetPlayerContext(playerid);
        CRP_ResetPlayerEvent(playerid);
        CRP_ResetPlayerState(playerid);
        CRP_ResetPlayerStateHistory(playerid);
        CRP_ResetPlayerStateTransitionAudit(playerid);
        CRP_EndPlayerSession(playerid);
        CRP_ResetPlayerRuntimeData(playerid);
        CRP_ResetPlayerRuntimeTransitionAudit(playerid);
        CRP_ResetPlayerSpawnType(playerid);
    }

    print("[CRP] Core gamemode berhasil dimuat.");
    print("[CRP] Developer: Muhammad Rizal.");
    print("[CRP] Core Version: 3.2.");

    print("[CRP] Player Identity Foundation aktif.");
    print("[CRP] Player Username Cache aktif.");
    print("[CRP] Player Identity Validation aktif.");

    print("[CRP] Player Character Foundation aktif."); // Added (v3.2)
    print("[CRP] Player Character Validation & Binding aktif."); // Added (v3.2)

    print("[CRP] Player Runtime Data Foundation aktif.");
    print("[CRP] Player Runtime Integrity Validation aktif.");
    print("[CRP] Player Runtime Transition Validation aktif.");
    print("[CRP] Player Runtime Transition Audit aktif.");
    print("[CRP] Player Runtime Transition Session Binding aktif.");
    print("[CRP] Player Runtime Transition Integrity Validation aktif.");
    print("[CRP] Player Runtime Transition Debug Foundation aktif.");

    print("[CRP] Player State Foundation aktif.");
    print("[CRP] Player State Transition Validation aktif.");
    print("[CRP] Player State Integrity Validation aktif.");
    print("[CRP] Player State Transaction Protection aktif.");

    print("[CRP] Player State History Foundation aktif.");
    print("[CRP] Player State History Transition Validation aktif.");
    print("[CRP] Player State History Session Protection aktif.");
    print("[CRP] Player State History Integrity Validation aktif.");

    print("[CRP] Player State Transition Counter aktif.");
    print("[CRP] Player State Transition Session Binding aktif.");
    print("[CRP] Player State Transition Integrity Validation aktif.");

    print("[CRP] Player Session Foundation aktif.");
    print("[CRP] Player Session Identification aktif.");
    print("[CRP] Player Session Validation aktif.");
    print("[CRP] Player Session Integrity Validation aktif.");

    print("[CRP] Player Data Foundation aktif.");
    print("[CRP] Player Data Session Binding aktif.");
    print("[CRP] Player Data Validation aktif.");
    print("[CRP] Player Data Integrity Validation aktif.");

    print("[CRP] Player Spawn Context Foundation aktif.");
    print("[CRP] Player Spawn Context Validation aktif.");
    print("[CRP] Player Spawn Context Integrity Hardening aktif.");

    print("[CRP] Player Lifecycle Core Validation aktif.");
    print("[CRP] Player Lifecycle Validation aktif.");
    print("[CRP] Player Lifecycle Session Protection aktif.");

    print("[CRP] Player State Access Gate Foundation aktif.");
    print("[CRP] Player State Access Validation aktif.");
    print("[CRP] Player State Session Access Protection aktif.");

    print("[CRP] Player State Minimum Access Foundation aktif.");
    print("[CRP] Player State Minimum Access Validation aktif.");
    print("[CRP] Player State Minimum Access Session Protection aktif.");

    print("[CRP] Player State Access Policy Foundation aktif.");
    print("[CRP] Player State Access Requirement Validation aktif.");
    print("[CRP] Player State Access Integrity Validation aktif.");

    print("[CRP] Player State Access Decision Foundation aktif.");
    print("[CRP] Player State Exact Access Decision aktif.");
    print("[CRP] Player State Minimum Access Decision aktif.");
    print("[CRP] Player State Access Session Decision aktif.");
    print("[CRP] Player State Access Decision Debug Foundation aktif.");

    print("[CRP] Player State Access Decision Reason Foundation aktif.");
    print("[CRP] Player State Access Decision Reason Validation aktif.");

    print("[CRP] Player State Access Decision Consistency Foundation aktif.");
    print("[CRP] Player State Access Decision Result Validation aktif.");
    print("[CRP] Player State Access Decision Reason/Result Validation aktif.");

    print("[CRP] Player Context Foundation aktif.");
    print("[CRP] Player Context Session Binding aktif.");
    print("[CRP] Player Context State Binding aktif.");
    print("[CRP] Player Context Validation aktif.");
    print("[CRP] Player Context Integrity Validation aktif.");
    print("[CRP] Player Context Session Protection aktif.");
    print("[CRP] Player Context Debug Foundation aktif.");
    print("[CRP] Player Context State Transaction Protection aktif.");

    print("[CRP] Player Lifecycle Event Foundation aktif.");
    print("[CRP] Player Lifecycle Event Validation aktif.");
    print("[CRP] Player Lifecycle Event Session Binding aktif.");
    print("[CRP] Player Lifecycle Event Integrity Validation aktif.");
    print("[CRP] Player Lifecycle Event Sequence Validation aktif.");
    print("[CRP] Player Lifecycle Event Debug Foundation aktif.");
    print("[CRP] Player Disconnect Transaction Protection aktif.");

    print("[CRP] Centralized Lifecycle Handler aktif.");
    print("[CRP] Server Environment System aktif.");

    return 1;
}


public OnGameModeExit()
{
    print("[CRP] Core gamemode dihentikan.");
    return 1;
}


// ============================================================
// SA-MP CORE CALLBACK HANDLERS
// ============================================================

public OnPlayerConnect(playerid)
{
    CRP_HandlePlayerConnect(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    CRP_HandlePlayerDisconnect(playerid, reason);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    CRP_HandlePlayerSpawn(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    CRP_HandlePlayerDeath(playerid, killerid, reason);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if (!CRP_IsPlayerActive(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "ERR: Anda harus masuk ke dalam game untuk mengirim pesan."
        );

        return 0;
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!CRP_IsPlayerActive(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "ERR: Anda harus masuk ke dalam game untuk menggunakan perintah."
        );

        return 1;
    }

    return 0;
}

public OnPlayerRequestClass(playerid, classid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    SetPlayerPos(playerid, 1685.6346, -2242.5151, 13.5469);
    SetPlayerCameraPos(playerid, 1680.6346, -2242.5151, 13.5469);
    SetPlayerCameraLookAt(playerid, 1685.6346, -2242.5151, 13.5469);

    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    if (!CRP_IsPlayerStateAtLeast(playerid, CRP_PLAYER_STATE_CHARACTER))
    {
        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "ERR: Anda belum dapat melakukan spawn."
        );

        return 0;
    }

    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if (!CRP_IsPlayerActive(playerid))
    {
        return 0;
    }

    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if (!CRP_IsPlayerActive(playerid))
    {
        return 0;
    }

    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    return 1;
}

public OnPlayerUpdate(playerid)
{
    if (!CRP_IsPlayerConnected(playerid))
    {
        return 0;
    }

    return 1;
}
