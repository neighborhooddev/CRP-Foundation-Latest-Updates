#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Spawn System v0.2
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - Spawn character yang sudah aktif
// - Mengambil data dari Character Activation
// - Set skin character sementara
// - Set posisi spawn default
// - Set interior
// - Set virtual world
// - Menjalankan SpawnPlayer()
// - Menjaga Register Spawn tetap khusus character baru
//
// Activation:
// crp_character_activation.pwn
//
// Register Spawn:
// crp_register_spawn.pwn
//
// CATATAN:
// Spawn location sementara menggunakan lokasi default.
//
// Fondasi berikutnya dapat dikembangkan menjadi:
// - Logout Spawn
// - Hospital Spawn
// - Jail Spawn
// - Job Spawn
// - Rumah
// - Apartment
// - Last Position
// - Spawn Selection
// ============================================================


#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_RED       0xFF3333FF
#define COLOR_GREY      0xAAAAAAFF


// ============================================================
// DEFAULT CHARACTER SPAWN
// ============================================================
//
// Sementara menggunakan lokasi default di Los Santos.
//
// Nanti posisi ini dapat digantikan oleh sistem:
//
// Character Last Position
// Logout Spawn
// Hospital Spawn
// Jail Spawn
// Job Spawn
// House Spawn
// Apartment Spawn
//
// ============================================================

#define CHARACTER_SPAWN_X        1685.6346
#define CHARACTER_SPAWN_Y       -2242.5151
#define CHARACTER_SPAWN_Z          13.5469
#define CHARACTER_SPAWN_A          90.0

#define CHARACTER_SPAWN_INTERIOR    0
#define CHARACTER_SPAWN_WORLD       0


// ============================================================
// DEFAULT SKIN
// ============================================================
//
// Untuk sementara skin menggunakan skin default.
//
// Sistem skin character akan dikembangkan kemudian.
//
// ============================================================

#define CHARACTER_DEFAULT_SKIN 7


// ============================================================
// CHARACTER ACTIVATION REMOTE
// ============================================================

forward CRP_IsCharacterActiveRemote(
    playerid
);

forward CRP_GetActiveCharacterNameRemote(
    playerid,
    name[],
    size
);

forward CRP_GetActiveCharacterLevelRemote(
    playerid
);

forward CRP_GetActiveCharacterPRIDRemote(
    playerid
);


// ============================================================
// VALIDATE PLAYER
// ============================================================

stock CRP_IsValidSpawnPlayer(
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
// APPLY CHARACTER SPAWN
// ============================================================
//
// Fungsi ini hanya mempersiapkan spawn.
//
// Belum memanggil SpawnPlayer().
//
// ============================================================

stock CRP_ApplyCharacterSpawn(
    playerid
)
{
    new active;

    new name[25];
    new level;
    new prid;

    // --------------------------------------------------------
    // VALIDATE PLAYER
    // --------------------------------------------------------

    if (
        !CRP_IsValidSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // CHECK CHARACTER ACTIVE
    // --------------------------------------------------------

    active = CallRemoteFunction(
        "CRP_IsCharacterActiveRemote",
        "d",
        playerid
    );

    if (
        !active
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Character belum aktif."
        );

        return 0;
    }

    // --------------------------------------------------------
    // GET ACTIVE CHARACTER NAME
    // --------------------------------------------------------

    name[0] = EOS;

    if (
        !CallRemoteFunction(
            "CRP_GetActiveCharacterNameRemote",
            "dsd",
            playerid,
            name,
            sizeof(name)
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Nama character gagal dibaca."
        );

        return 0;
    }

    if (
        name[0] == EOS
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Nama character tidak valid."
        );

        return 0;
    }

    // --------------------------------------------------------
    // GET ACTIVE CHARACTER LEVEL
    // --------------------------------------------------------

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        playerid
    );

    if (
        level <= 0
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Level character tidak valid."
        );

        return 0;
    }

    // --------------------------------------------------------
    // GET ACTIVE CHARACTER PRID
    // --------------------------------------------------------

    prid = CallRemoteFunction(
        "CRP_GetActiveCharacterPRIDRemote",
        "d",
        playerid
    );

    if (
        prid <= 0
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] PRID character tidak valid."
        );

        return 0;
    }

    // --------------------------------------------------------
    // SET SPAWN INFO
    // --------------------------------------------------------

    SetSpawnInfo(
        playerid,
        NO_TEAM,
        CHARACTER_DEFAULT_SKIN,

        CHARACTER_SPAWN_X,
        CHARACTER_SPAWN_Y,
        CHARACTER_SPAWN_Z,
        CHARACTER_SPAWN_A,

        0,
        0,

        0,
        0,

        0,
        0
    );

    // --------------------------------------------------------
    // SET INTERIOR
    // --------------------------------------------------------

    SetPlayerInterior(
        playerid,
        CHARACTER_SPAWN_INTERIOR
    );

    // --------------------------------------------------------
    // SET VIRTUAL WORLD
    // --------------------------------------------------------

    SetPlayerVirtualWorld(
        playerid,
        CHARACTER_SPAWN_WORLD
    );

    // --------------------------------------------------------
    // LOG
    // --------------------------------------------------------

    printf(
        "[CRP SPAWN] Spawn disiapkan | PlayerID=%d | PRID=%03d | Name=%s | Level=%d",
        playerid,
        prid,
        name,
        level
    );

    return 1;
}


// ============================================================
// SPAWN ACTIVE CHARACTER
// ============================================================
//
// Fungsi utama yang dipanggil oleh:
//
// crp_character_activation.pwn
//
// Remote:
//
// CRP_SpawnActiveCharacterRemote
//
// ============================================================

stock CRP_SpawnActiveCharacter(
    playerid
)
{
    new name[25];
    new level;
    new prid;

    new message[144];

    // --------------------------------------------------------
    // VALIDATE PLAYER
    // --------------------------------------------------------

    if (
        !CRP_IsValidSpawnPlayer(playerid)
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // CHECK CHARACTER ACTIVE
    // --------------------------------------------------------

    if (
        !CallRemoteFunction(
            "CRP_IsCharacterActiveRemote",
            "d",
            playerid
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Character belum aktif."
        );

        return 0;
    }

    // --------------------------------------------------------
    // APPLY SPAWN
    // --------------------------------------------------------

    if (
        !CRP_ApplyCharacterSpawn(
            playerid
        )
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // GET CHARACTER NAME
    // --------------------------------------------------------

    name[0] = EOS;

    CallRemoteFunction(
        "CRP_GetActiveCharacterNameRemote",
        "dsd",
        playerid,
        name,
        sizeof(name)
    );

    // --------------------------------------------------------
    // GET CHARACTER LEVEL
    // --------------------------------------------------------

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        playerid
    );

    // --------------------------------------------------------
    // GET CHARACTER PRID
    // --------------------------------------------------------

    prid = CallRemoteFunction(
        "CRP_GetActiveCharacterPRIDRemote",
        "d",
        playerid
    );

    // --------------------------------------------------------
    // INFORMATION
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP SPAWN] Character berhasil disiapkan."
    );

    format(
        message,
        sizeof(message),
        "[CRP SPAWN] Selamat datang, %s. | Level %d | PRID %03d.",
        name,
        level,
        prid
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "[CRP SPAWN] Posisi awal character telah ditentukan."
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
// REMOTE: SPAWN ACTIVE CHARACTER
// ============================================================

forward CRP_SpawnActiveCharacterRemote(
    playerid
);

public CRP_SpawnActiveCharacterRemote(
    playerid
)
{
    return CRP_SpawnActiveCharacter(
        playerid
    );
}


// ============================================================
// INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Character Spawn System v0.2");
    print(" Active Character Spawn Loaded");
    print(" Activation Validation Loaded");
    print(" Character Identity Validation Loaded");
    print(" Spawn Configuration Loaded");
    print(" Character Spawn Integration Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP CHARACTER SPAWN] System unloaded."
    );

    return 1;
}