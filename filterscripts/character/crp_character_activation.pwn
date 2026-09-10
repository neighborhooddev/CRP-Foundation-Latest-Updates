#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Activation System v0.3
//
// Fungsi:
// - Mengaktifkan character yang dipilih
// - Load full character data dari Storage
// - Menyimpan character aktif
// - Menyimpan PRID aktif
// - Update Last Login
// - Update Last IP
// - Update Last Logout saat disconnect
// - Menjalankan Character Spawn setelah activation berhasil
//
// Character Slot:
// crp_character_slot.pwn
//
// Storage:
// crp_storage.pwn
//
// Spawn:
// crp_character_spawn.pwn
//
// PRID:
// - PRID merupakan identitas permanen character.
// - PRID tidak berubah saat character aktif.
// - PRID tidak berubah saat rename.
// - PRID tidak berubah saat pindah slot.
// ============================================================


#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33
#define COLOR_YELLOW    0xFFFF00
#define COLOR_RED       0xFF3333
#define COLOR_GREY      0xAAAAAA

#define CHARACTER_SLOT_COUNT 5


// ============================================================
// ACTIVE CHARACTER DATA
// ============================================================

new gActiveCharacterSlot[MAX_PLAYERS];

new gActiveCharacterPRID[MAX_PLAYERS];

new gActiveCharacterName[MAX_PLAYERS][25];

new gActiveCharacterLevel[MAX_PLAYERS];

new gActiveCharacterOrigin[MAX_PLAYERS][64];

new gActiveCharacterGender[MAX_PLAYERS][16];

new gActiveCharacterDOB[MAX_PLAYERS][16];

new gActiveCharacterReligion[MAX_PLAYERS][24];

new gActiveCharacterLastIP[MAX_PLAYERS][16];

new gActiveCharacterLastLogin[MAX_PLAYERS][32];

new gActiveCharacterLastLogout[MAX_PLAYERS][32];

new bool:gCharacterActive[MAX_PLAYERS];


// ============================================================
// STORAGE REMOTE
// ============================================================

forward CRP_StorageCharacterExistsRemote(
    playerid,
    slot
);

forward CRP_StorageGetCharacterPRIDRemote(
    playerid,
    slot
);

forward CRP_StorageGetCharacterFullDataRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    origin[],
    originsize,
    gender[],
    gendersize,
    dob[],
    dobsize,
    religion[],
    religionsize,
    lastip[],
    ipsize,
    lastlogin[],
    loginsize,
    lastlogout[],
    logoutsize
);

forward CRP_StorageUpdateCharacterLastLoginRemote(
    playerid,
    slot
);

forward CRP_StorageUpdateCharacterLastLogoutRemote(
    playerid,
    slot
);


// ============================================================
// CHARACTER SPAWN REMOTE
// ============================================================

forward CRP_SpawnActiveCharacterRemote(
    playerid
);


// ============================================================
// RESET ACTIVE CHARACTER
// ============================================================

stock CRP_ResetActiveCharacter(
    playerid
)
{
    gActiveCharacterSlot[playerid] = -1;

    gActiveCharacterPRID[playerid] = 0;

    gActiveCharacterName[playerid][0] = EOS;

    gActiveCharacterLevel[playerid] = 0;

    gActiveCharacterOrigin[playerid][0] = EOS;

    gActiveCharacterGender[playerid][0] = EOS;

    gActiveCharacterDOB[playerid][0] = EOS;

    gActiveCharacterReligion[playerid][0] = EOS;

    gActiveCharacterLastIP[playerid][0] = EOS;

    gActiveCharacterLastLogin[playerid][0] = EOS;

    gActiveCharacterLastLogout[playerid][0] = EOS;

    gCharacterActive[playerid] = false;

    return 1;
}


// ============================================================
// CHECK ACTIVE CHARACTER
// ============================================================

stock CRP_IsCharacterActive(
    playerid
)
{
    if (
        gCharacterActive[playerid]
    )
    {
        return 1;
    }

    return 0;
}


// ============================================================
// GET ACTIVE SLOT
// ============================================================

stock CRP_GetActiveCharacterSlot(
    playerid
)
{
    return gActiveCharacterSlot[playerid];
}


// ============================================================
// GET ACTIVE PRID
// ============================================================

stock CRP_GetActiveCharacterPRID(
    playerid
)
{
    return gActiveCharacterPRID[playerid];
}


// ============================================================
// GET ACTIVE CHARACTER NAME
// ============================================================

stock CRP_GetActiveCharacterName(
    playerid,
    name[],
    size
)
{
    format(
        name,
        size,
        "%s",
        gActiveCharacterName[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE CHARACTER LEVEL
// ============================================================

stock CRP_GetActiveCharacterLevel(
    playerid
)
{
    return gActiveCharacterLevel[playerid];
}


// ============================================================
// GET ACTIVE CHARACTER ORIGIN
// ============================================================

stock CRP_GetActiveCharacterOrigin(
    playerid,
    origin[],
    size
)
{
    format(
        origin,
        size,
        "%s",
        gActiveCharacterOrigin[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE CHARACTER GENDER
// ============================================================

stock CRP_GetActiveCharacterGender(
    playerid,
    gender[],
    size
)
{
    format(
        gender,
        size,
        "%s",
        gActiveCharacterGender[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE CHARACTER DOB
// ============================================================

stock CRP_GetActiveCharacterDOB(
    playerid,
    dob[],
    size
)
{
    format(
        dob,
        size,
        "%s",
        gActiveCharacterDOB[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE CHARACTER RELIGION
// ============================================================

stock CRP_GetActiveCharacterReligion(
    playerid,
    religion[],
    size
)
{
    format(
        religion,
        size,
        "%s",
        gActiveCharacterReligion[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE LAST IP
// ============================================================

stock CRP_GetActiveCharacterLastIP(
    playerid,
    ip[],
    size
)
{
    format(
        ip,
        size,
        "%s",
        gActiveCharacterLastIP[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE LAST LOGIN
// ============================================================

stock CRP_GetActiveCharacterLastLogin(
    playerid,
    lastlogin[],
    size
)
{
    format(
        lastlogin,
        size,
        "%s",
        gActiveCharacterLastLogin[playerid]
    );

    return 1;
}


// ============================================================
// GET ACTIVE LAST LOGOUT
// ============================================================

stock CRP_GetActiveCharacterLastLogout(
    playerid,
    lastlogout[],
    size
)
{
    format(
        lastlogout,
        size,
        "%s",
        gActiveCharacterLastLogout[playerid]
    );

    return 1;
}


// ============================================================
// LOAD FULL CHARACTER DATA
// ============================================================

stock CRP_LoadActiveCharacterData(
    playerid,
    slot
)
{
    new charactername[25];
    new origin[64];
    new gender[16];
    new dob[16];
    new religion[24];
    new lastip[16];
    new lastlogin[32];
    new lastlogout[32];

    new level;
    new prid;

    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    if (
        !CallRemoteFunction(
            "CRP_StorageCharacterExistsRemote",
            "dd",
            playerid,
            slot
        )
    )
    {
        return 0;
    }

    charactername[0] = EOS;
    origin[0] = EOS;
    gender[0] = EOS;
    dob[0] = EOS;
    religion[0] = EOS;
    lastip[0] = EOS;
    lastlogin[0] = EOS;
    lastlogout[0] = EOS;

    level = 0;

    if (
        !CallRemoteFunction(
            "CRP_StorageGetCharacterFullDataRemote",
            "ddsdssssssss",
            playerid,
            slot,
            charactername,
            sizeof(charactername),
            level,
            origin,
            sizeof(origin),
            gender,
            sizeof(gender),
            dob,
            sizeof(dob),
            religion,
            sizeof(religion),
            lastip,
            sizeof(lastip),
            lastlogin,
            sizeof(lastlogin),
            lastlogout,
            sizeof(lastlogout)
        )
    )
    {
        return 0;
    }

    prid = CallRemoteFunction(
        "CRP_StorageGetCharacterPRIDRemote",
        "dd",
        playerid,
        slot
    );

    if (
        prid <= 0
    )
    {
        return 0;
    }

    gActiveCharacterSlot[playerid] = slot;
    gActiveCharacterPRID[playerid] = prid;

    format(
        gActiveCharacterName[playerid],
        25,
        "%s",
        charactername
    );

    gActiveCharacterLevel[playerid] = level;

    format(
        gActiveCharacterOrigin[playerid],
        64,
        "%s",
        origin
    );

    format(
        gActiveCharacterGender[playerid],
        16,
        "%s",
        gender
    );

    format(
        gActiveCharacterDOB[playerid],
        16,
        "%s",
        dob
    );

    format(
        gActiveCharacterReligion[playerid],
        24,
        "%s",
        religion
    );

    format(
        gActiveCharacterLastIP[playerid],
        16,
        "%s",
        lastip
    );

    format(
        gActiveCharacterLastLogin[playerid],
        32,
        "%s",
        lastlogin
    );

    format(
        gActiveCharacterLastLogout[playerid],
        32,
        "%s",
        lastlogout
    );

    return 1;
}


// ============================================================
// ACTIVATE CHARACTER
// ============================================================

stock CRP_ActivateCharacter(
    playerid,
    slot
)
{
    new message[144];
    new updated;

    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Slot karakter tidak valid."
        );

        return 0;
    }

    CRP_ResetActiveCharacter(
        playerid
    );

    if (
        !CRP_LoadActiveCharacterData(
            playerid,
            slot
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data character gagal dimuat."
        );

        CRP_ResetActiveCharacter(
            playerid
        );

        return 0;
    }

    updated = CallRemoteFunction(
        "CRP_StorageUpdateCharacterLastLoginRemote",
        "dd",
        playerid,
        slot
    );

    if (
        !updated
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Gagal memperbarui Last Login."
        );

        CRP_ResetActiveCharacter(
            playerid
        );

        return 0;
    }

    if (
        !CRP_LoadActiveCharacterData(
            playerid,
            slot
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data character gagal disinkronkan."
        );

        CRP_ResetActiveCharacter(
            playerid
        );

        return 0;
    }

    gCharacterActive[playerid] = true;

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP CHARACTER] Character berhasil diaktifkan."
    );

    format(
        message,
        sizeof(message),
        "[CRP CHARACTER] %s | Level %d | PRID %03d.",
        gActiveCharacterName[playerid],
        gActiveCharacterLevel[playerid],
        gActiveCharacterPRID[playerid]
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        "[CRP CHARACTER] Last Login berhasil diperbarui."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP CHARACTER] Character aktif. Menyiapkan Spawn..."
    );

    if (
        !CallRemoteFunction(
            "CRP_SpawnActiveCharacterRemote",
            "d",
            playerid
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Character aktif, tetapi Spawn gagal disiapkan."
        );

        return 0;
    }

    return 1;
}


// ============================================================
// PREPARE CHARACTER LOGOUT
//
// Dipanggil sebelum Active Character di-reset.
//
// Yang disimpan:
// - Last Logout
// - Last IP
//
// PRID tetap.
// Nama tetap.
// Last Login tetap.
// ============================================================

stock CRP_PrepareCharacterLogout(
    playerid
)
{
    new slot;
    new updated;

    if (
        !gCharacterActive[playerid]
    )
    {
        return 0;
    }

    slot =
        gActiveCharacterSlot[playerid];

    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    updated = CallRemoteFunction(
        "CRP_StorageUpdateCharacterLastLogoutRemote",
        "dd",
        playerid,
        slot
    );

    if (
        updated
    )
    {
        printf(
            "[CRP CHARACTER] Last Logout berhasil disimpan | PlayerID=%d | PRID=%03d | Character=%s",
            playerid,
            gActiveCharacterPRID[playerid],
            gActiveCharacterName[playerid]
        );

        return 1;
    }

    printf(
        "[CRP CHARACTER] WARNING: Last Logout gagal disimpan | PlayerID=%d | PRID=%03d",
        playerid,
        gActiveCharacterPRID[playerid]
    );

    return 0;
}


// ============================================================
// REMOTE: ACTIVATE CHARACTER
// ============================================================

forward CRP_ActivateCharacterRemote(
    playerid,
    slot
);

public CRP_ActivateCharacterRemote(
    playerid,
    slot
)
{
    return CRP_ActivateCharacter(
        playerid,
        slot
    );
}


// ============================================================
// REMOTE: ACTIVE STATUS
// ============================================================

forward CRP_IsCharacterActiveRemote(
    playerid
);

public CRP_IsCharacterActiveRemote(
    playerid
)
{
    return CRP_IsCharacterActive(
        playerid
    );
}


// ============================================================
// REMOTE: ACTIVE SLOT
// ============================================================

forward CRP_GetActiveCharacterSlotRemote(
    playerid
);

public CRP_GetActiveCharacterSlotRemote(
    playerid
)
{
    return CRP_GetActiveCharacterSlot(
        playerid
    );
}


// ============================================================
// REMOTE: ACTIVE PRID
// ============================================================

forward CRP_GetActiveCharacterPRIDRemote(
    playerid
);

public CRP_GetActiveCharacterPRIDRemote(
    playerid
)
{
    return CRP_GetActiveCharacterPRID(
        playerid
    );
}


// ============================================================
// REMOTE: ACTIVE NAME
// ============================================================

forward CRP_GetActiveCharacterNameRemote(
    playerid,
    name[],
    size
);

public CRP_GetActiveCharacterNameRemote(
    playerid,
    name[],
    size
)
{
    return CRP_GetActiveCharacterName(
        playerid,
        name,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE LEVEL
// ============================================================

forward CRP_GetActiveCharacterLevelRemote(
    playerid
);

public CRP_GetActiveCharacterLevelRemote(
    playerid
)
{
    return CRP_GetActiveCharacterLevel(
        playerid
    );
}


// ============================================================
// REMOTE: ACTIVE ORIGIN
// ============================================================

forward CRP_GetActiveCharacterOriginRemote(
    playerid,
    origin[],
    size
);

public CRP_GetActiveCharacterOriginRemote(
    playerid,
    origin[],
    size
)
{
    return CRP_GetActiveCharacterOrigin(
        playerid,
        origin,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE GENDER
// ============================================================

forward CRP_GetActiveCharacterGenderRemote(
    playerid,
    gender[],
    size
);

public CRP_GetActiveCharacterGenderRemote(
    playerid,
    gender[],
    size
)
{
    return CRP_GetActiveCharacterGender(
        playerid,
        gender,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE DOB
// ============================================================

forward CRP_GetActiveCharacterDOBRemote(
    playerid,
    dob[],
    size
);

public CRP_GetActiveCharacterDOBRemote(
    playerid,
    dob[],
    size
)
{
    return CRP_GetActiveCharacterDOB(
        playerid,
        dob,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE RELIGION
// ============================================================

forward CRP_GetActiveCharacterReligionRemote(
    playerid,
    religion[],
    size
);

public CRP_GetActiveCharacterReligionRemote(
    playerid,
    religion[],
    size
)
{
    return CRP_GetActiveCharacterReligion(
        playerid,
        religion,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE LAST IP
// ============================================================

forward CRP_GetActiveCharacterLastIPRemote(
    playerid,
    ip[],
    size
);

public CRP_GetActiveCharacterLastIPRemote(
    playerid,
    ip[],
    size
)
{
    return CRP_GetActiveCharacterLastIP(
        playerid,
        ip,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE LAST LOGIN
// ============================================================

forward CRP_GetActiveCharacterLastLoginRemote(
    playerid,
    lastlogin[],
    size
);

public CRP_GetActiveCharacterLastLoginRemote(
    playerid,
    lastlogin[],
    size
)
{
    return CRP_GetActiveCharacterLastLogin(
        playerid,
        lastlogin,
        size
    );
}


// ============================================================
// REMOTE: ACTIVE LAST LOGOUT
// ============================================================

forward CRP_GetActiveCharacterLastLogoutRemote(
    playerid,
    lastlogout[],
    size
);

public CRP_GetActiveCharacterLastLogoutRemote(
    playerid,
    lastlogout[],
    size
)
{
    return CRP_GetActiveCharacterLastLogout(
        playerid,
        lastlogout,
        size
    );
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(
    playerid
)
{
    CRP_ResetActiveCharacter(
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER DISCONNECT
//
// PENTING:
// Activation harus dimuat SEBELUM Storage.
//
// Tujuannya:
// Last Logout disimpan terlebih dahulu,
// baru Storage melakukan reset data player.
// ============================================================

public OnPlayerDisconnect(
    playerid,
    reason
)
{
    if (
        gCharacterActive[playerid]
    )
    {
        CRP_PrepareCharacterLogout(
            playerid
        );
    }

    CRP_ResetActiveCharacter(
        playerid
    );

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Character Activation System v0.3");
    print(" Full Character Data Loaded");
    print(" Active Character System Loaded");
    print(" Active PRID System Loaded");
    print(" Last Login Integration Loaded");
    print(" Last IP Integration Loaded");
    print(" Last Logout Integration Loaded");
    print(" Character Spawn Integration Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP CHARACTER ACTIVATION] System unloaded."
    );

    return 1;
}
