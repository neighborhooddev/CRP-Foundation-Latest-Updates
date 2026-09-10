#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Register Spawn System v0.4
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - 4 lokasi Register Spawn
// - Menyimpan pilihan spawn player
// - Menyiapkan SetSpawnInfo
// - Menjalankan SpawnPlayer
// - Register Spawn State
// - Remote interface untuk Character Creation
// - Validasi player dan spawn
//
// UI:
// - Register Spawn UI ditangani oleh file terpisah
//
// Digunakan setelah:
// - Character Creation
//
// CATATAN:
// - Sistem ini khusus untuk karakter baru.
// - Spawn karakter aktif setelah login tetap ditangani
//   oleh crp_character_spawn.pwn.
// ============================================================


// ============================================================
// COLOR
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_GREY      0xAAAAAAFF
#define COLOR_RED       0xFF3333FF


// ============================================================
// REGISTER SPAWN ID
// ============================================================

#define REGISTER_SPAWN_UNITY       0
#define REGISTER_SPAWN_AIRPORT     1
#define REGISTER_SPAWN_SANTA       2
#define REGISTER_SPAWN_EAST        3

#define REGISTER_SPAWN_MIN         REGISTER_SPAWN_UNITY
#define REGISTER_SPAWN_MAX         REGISTER_SPAWN_EAST


// ============================================================
// SPAWN LOCATION
// ============================================================

// ------------------------------------------------------------
// Unity Station
// ------------------------------------------------------------

#define UNITY_SPAWN_X          1810.8765
#define UNITY_SPAWN_Y         -1877.1888
#define UNITY_SPAWN_Z            13.5839
#define UNITY_SPAWN_A           270.0


// ------------------------------------------------------------
// Los Santos Airport
// ------------------------------------------------------------

#define AIRPORT_SPAWN_X        1583.5385
#define AIRPORT_SPAWN_Y       -2286.5608
#define AIRPORT_SPAWN_Z          13.5396
#define AIRPORT_SPAWN_A          90.0


// ------------------------------------------------------------
// Santa Maria Beach
// ------------------------------------------------------------

#define SANTA_SPAWN_X           477.3500
#define SANTA_SPAWN_Y         -1764.1151
#define SANTA_SPAWN_Z             5.5333
#define SANTA_SPAWN_A           190.0


// ------------------------------------------------------------
// East Beach
// ------------------------------------------------------------

#define EAST_SPAWN_X           2770.5393
#define EAST_SPAWN_Y          -1628.3069
#define EAST_SPAWN_Z             12.1775
#define EAST_SPAWN_A              4.9637


// ============================================================
// DEFAULT REGISTER CHARACTER
// ============================================================

#define REGISTER_DEFAULT_SKIN 7

#define REGISTER_INTERIOR     0
#define REGISTER_WORLD        0


// ============================================================
// PLAYER DATA
// ============================================================

new gPlayerRegisterSpawn[MAX_PLAYERS];

new bool:gPlayerRegisterSpawnActive[MAX_PLAYERS];


// ============================================================
// VALID PLAYER
// ============================================================

stock CRP_IsValidRegisterSpawnPlayer(
    playerid
)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// VALID SPAWN
// ============================================================

stock CRP_IsValidRegisterSpawn(
    spawnid
)
{
    if (
        spawnid < REGISTER_SPAWN_MIN ||
        spawnid > REGISTER_SPAWN_MAX
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// RESET
// ============================================================

stock CRP_ResetRegisterSpawn(
    playerid
)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    gPlayerRegisterSpawn[playerid] = -1;

    gPlayerRegisterSpawnActive[playerid] = false;

    return 1;
}


// ============================================================
// GET SPAWN NAME
// ============================================================

stock CRP_GetRegisterSpawnName(
    spawnid,
    name[],
    size
)
{
    if (
        size <= 0
    )
    {
        return 0;
    }

    switch (
        spawnid
    )
    {
        case REGISTER_SPAWN_UNITY:
        {
            format(
                name,
                size,
                "Unity Station"
            );
        }

        case REGISTER_SPAWN_AIRPORT:
        {
            format(
                name,
                size,
                "Los Santos Airport"
            );
        }

        case REGISTER_SPAWN_SANTA:
        {
            format(
                name,
                size,
                "Santa Maria Beach"
            );
        }

        case REGISTER_SPAWN_EAST:
        {
            format(
                name,
                size,
                "East Beach"
            );
        }

        default:
        {
            format(
                name,
                size,
                "Unknown"
            );
        }
    }

    return 1;
}


// ============================================================
// GET SPAWN DESCRIPTION
// ============================================================

stock CRP_GetRegisterSpawnDescription(
    spawnid,
    description[],
    size
)
{
    if (
        size <= 0
    )
    {
        return 0;
    }

    switch (
        spawnid
    )
    {
        case REGISTER_SPAWN_UNITY:
        {
            format(
                description,
                size,
                "Stasiun transportasi utama di kawasan pusat Los Santos."
            );
        }

        case REGISTER_SPAWN_AIRPORT:
        {
            format(
                description,
                size,
                "Bandar udara utama yang menjadi pintu masuk Los Santos."
            );
        }

        case REGISTER_SPAWN_SANTA:
        {
            format(
                description,
                size,
                "Kawasan pesisir Los Santos dengan suasana tepi laut."
            );
        }

        case REGISTER_SPAWN_EAST:
        {
            format(
                description,
                size,
                "Kawasan timur Los Santos dengan lingkungan permukiman."
            );
        }

        default:
        {
            format(
                description,
                size,
                "Los Santos."
            );
        }
    }

    return 1;
}


// ============================================================
// APPLY SPAWN
// ============================================================

stock CRP_ApplyRegisterSpawn(
    playerid,
    spawnid
)
{
    if (
        !CRP_IsValidRegisterSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    if (
        !CRP_IsValidRegisterSpawn(spawnid)
    )
    {
        return 0;
    }

    new Float:x;
    new Float:y;
    new Float:z;
    new Float:a;

    switch (
        spawnid
    )
    {
        case REGISTER_SPAWN_UNITY:
        {
            x = UNITY_SPAWN_X;
            y = UNITY_SPAWN_Y;
            z = UNITY_SPAWN_Z;
            a = UNITY_SPAWN_A;
        }

        case REGISTER_SPAWN_AIRPORT:
        {
            x = AIRPORT_SPAWN_X;
            y = AIRPORT_SPAWN_Y;
            z = AIRPORT_SPAWN_Z;
            a = AIRPORT_SPAWN_A;
        }

        case REGISTER_SPAWN_SANTA:
        {
            x = SANTA_SPAWN_X;
            y = SANTA_SPAWN_Y;
            z = SANTA_SPAWN_Z;
            a = SANTA_SPAWN_A;
        }

        case REGISTER_SPAWN_EAST:
        {
            x = EAST_SPAWN_X;
            y = EAST_SPAWN_Y;
            z = EAST_SPAWN_Z;
            a = EAST_SPAWN_A;
        }

        default:
        {
            return 0;
        }
    }


    // --------------------------------------------------------
    // SAVE PLAYER REGISTER SPAWN
    // --------------------------------------------------------

    gPlayerRegisterSpawn[playerid] =
        spawnid;

    gPlayerRegisterSpawnActive[playerid] =
        true;


    // --------------------------------------------------------
    // SET SPAWN INFO
    // --------------------------------------------------------

    SetSpawnInfo(
        playerid,
        NO_TEAM,
        REGISTER_DEFAULT_SKIN,
        x,
        y,
        z,
        a,
        0, 0,
        0, 0,
        0, 0
    );


    // --------------------------------------------------------
    // INTERIOR
    // --------------------------------------------------------

    SetPlayerInterior(
        playerid,
        REGISTER_INTERIOR
    );


    // --------------------------------------------------------
    // VIRTUAL WORLD
    // --------------------------------------------------------

    SetPlayerVirtualWorld(
        playerid,
        REGISTER_WORLD
    );

    return 1;
}


// ============================================================
// START NEW CHARACTER SPAWN
// ============================================================

forward CRP_StartNewCharacterSpawn(
    playerid,
    spawnid
);

public CRP_StartNewCharacterSpawn(
    playerid,
    spawnid
)
{
    if (
        !CRP_IsValidRegisterSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    if (
        !CRP_IsValidRegisterSpawn(spawnid)
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP] Register Spawn tidak valid."
        );

        return 0;
    }


    // --------------------------------------------------------
    // APPLY
    // --------------------------------------------------------

    if (
        !CRP_ApplyRegisterSpawn(
            playerid,
            spawnid
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP] Gagal menyiapkan lokasi spawn."
        );

        return 0;
    }


    // --------------------------------------------------------
    // INFORMATION
    // --------------------------------------------------------

    new spawnname[32];
    new description[144];
    new message[144];

    CRP_GetRegisterSpawnName(
        spawnid,
        spawnname,
        sizeof(spawnname)
    );

    CRP_GetRegisterSpawnDescription(
        spawnid,
        description,
        sizeof(description)
    );


    format(
        message,
        sizeof(message),
        "Kamu akan memulai perjalanan di %s, Los Santos.",
        spawnname
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        message
    );


    SendClientMessage(
        playerid,
        COLOR_GREY,
        description
    );


    // --------------------------------------------------------
    // SPAWN PLAYER
    // --------------------------------------------------------

    SpawnPlayer(
        playerid
    );

    return 1;
}


// ============================================================
// CHECK REGISTER SPAWN ACTIVE
// ============================================================

stock CRP_IsRegisterSpawnActive(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    if (
        gPlayerRegisterSpawnActive[playerid]
    )
    {
        return 1;
    }

    return 0;
}


// ============================================================
// GET SELECTED REGISTER SPAWN
// ============================================================

stock CRP_GetPlayerRegisterSpawn(
    playerid
)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return -1;
    }

    return gPlayerRegisterSpawn[playerid];
}


// ============================================================
// REMOTE
// ============================================================

forward CRP_IsRegisterSpawnActiveRemote(
    playerid
);

public CRP_IsRegisterSpawnActiveRemote(
    playerid
)
{
    return CRP_IsRegisterSpawnActive(
        playerid
    );
}


// ------------------------------------------------------------

forward CRP_GetPlayerRegisterSpawnRemote(
    playerid
);

public CRP_GetPlayerRegisterSpawnRemote(
    playerid
)
{
    return CRP_GetPlayerRegisterSpawn(
        playerid
    );
}


// ============================================================
// REGISTER SPAWN UI INTERFACE
// ============================================================
//
// Character Creation v0.5 memanggil:
//
// CRP_ShowRegisterSpawnSelectionRemote(playerid)
//
// UI tetap dipisahkan dari logic.
// ============================================================

forward CRP_ShowRegisterSpawnSelectionRemote(
    playerid
);

public CRP_ShowRegisterSpawnSelectionRemote(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    return CallRemoteFunction(
        "CRP_ShowRegisterSpawnSelection",
        "d",
        playerid
    );
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(
    playerid
)
{
    CRP_ResetRegisterSpawn(
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER SPAWN
// ============================================================

public OnPlayerSpawn(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnPlayer(playerid)
    )
    {
        return 1;
    }

    if (
        !gPlayerRegisterSpawnActive[playerid]
    )
    {
        return 1;
    }

    new spawnname[32];
    new message[144];

    CRP_GetRegisterSpawnName(
        gPlayerRegisterSpawn[playerid],
        spawnname,
        sizeof(spawnname)
    );


    format(
        message,
        sizeof(message),
        "Selamat datang di Los Santos. Kamu memulai perjalanan dari %s.",
        spawnname
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        message
    );


    // --------------------------------------------------------
    // REGISTER SPAWN SELESAI
    // --------------------------------------------------------

    gPlayerRegisterSpawnActive[playerid] =
        false;

    return 1;
}


// ============================================================
// DISCONNECT
// ============================================================

public OnPlayerDisconnect(
    playerid,
    reason
)
{
    CRP_ResetRegisterSpawn(
        playerid
    );

    return 1;
}


// ============================================================
// INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Register Spawn System v0.4");
    print(" 4 Los Santos Spawn Locations");
    print(" Register Spawn State Loaded");
    print(" SpawnPlayer Integration Loaded");
    print(" Character Creation Remote Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP REGISTER SPAWN] System unloaded."
    );

    return 1;
}