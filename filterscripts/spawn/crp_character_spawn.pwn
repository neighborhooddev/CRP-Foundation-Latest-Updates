#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Spawn System v0.1
//
// Fungsi:
// - Spawn character yang sudah aktif
// - Mengambil data dari Character Activation
// - Set skin character
// - Set posisi spawn
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
// Nanti bisa dikembangkan menjadi:
// - Logout Spawn
// - Hospital Spawn
// - Jail Spawn
// - Job Spawn
// - Rumah
// - Apartment
// - Last Position
// ============================================================


#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33
#define COLOR_YELLOW    0xFFFF00
#define COLOR_RED       0xFF3333
#define COLOR_GREY      0xAAAAAA


// ============================================================
// DEFAULT CHARACTER SPAWN
//
// Sementara menggunakan lokasi aman di Los Santos.
//
// NANTI:
// posisi ini akan digantikan oleh sistem:
// Character Last Position / Logout Spawn.
// ============================================================

#define CHARACTER_SPAWN_X  1685.6346
#define CHARACTER_SPAWN_Y -2242.5151
#define CHARACTER_SPAWN_Z 13.5469
#define CHARACTER_SPAWN_A 90.0

#define CHARACTER_SPAWN_INTERIOR 0
#define CHARACTER_SPAWN_WORLD    0


// ============================================================
// DEFAULT SKIN
//
// Untuk sementara skin mengikuti data default.
// Sistem skin character akan dikembangkan nanti.
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
// APPLY CHARACTER SPAWN
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
    // CEK CHARACTER AKTIF
    // --------------------------------------------------------

    active = CallRemoteFunction(
        "CRP_IsCharacterActiveRemote",
        "d",
        playerid
    );

    if (!active)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP SPAWN] Character belum aktif."
        );

        return 0;
    }


    // --------------------------------------------------------
    // AMBIL DATA CHARACTER AKTIF
    // --------------------------------------------------------

    name[0] = EOS;

    CallRemoteFunction(
        "CRP_GetActiveCharacterNameRemote",
        "dsd",
        playerid,
        name,
        sizeof(name)
    );

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        playerid
    );

    prid = CallRemoteFunction(
        "CRP_GetActiveCharacterPRIDRemote",
        "d",
        playerid
    );


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
        0, 0,
        0, 0,
        0, 0
    );


    // --------------------------------------------------------
    // INTERIOR
    // --------------------------------------------------------

    SetPlayerInterior(
        playerid,
        CHARACTER_SPAWN_INTERIOR
    );


    // --------------------------------------------------------
    // VIRTUAL WORLD
    // --------------------------------------------------------

    SetPlayerVirtualWorld(
        playerid,
        CHARACTER_SPAWN_WORLD
    );


    // --------------------------------------------------------
    // LOG
    // --------------------------------------------------------

    printf(
        "[CRP SPAWN] Character spawn disiapkan | PRID=%03d | Name=%s | Level=%d",
        prid,
        name,
        level
    );

    return 1;
}


// ============================================================
// SPAWN ACTIVE CHARACTER
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
    // CEK CHARACTER AKTIF
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
    // AMBIL DATA
    // --------------------------------------------------------

    name[0] = EOS;

    CallRemoteFunction(
        "CRP_GetActiveCharacterNameRemote",
        "dsd",
        playerid,
        name,
        sizeof(name)
    );

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        playerid
    );

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


    // --------------------------------------------------------
    // SPAWN
    // --------------------------------------------------------

    SpawnPlayer(
        playerid
    );

    return 1;
}


// ============================================================
// REMOTE
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
    print(" CRP Character Spawn System v0.1");
    print(" Active Character Spawn Loaded");
    print(" Activation Check Loaded");
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