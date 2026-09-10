#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Slot System v0.6
//
// Fungsi:
// - 5 slot karakter per UCP
// - Load data karakter dari Storage
// - Status slot kosong / terisi
// - PRID / PURI karakter
// - Nama karakter
// - Level
// - Last Login
// - Pemilihan slot
// - Membuka Character Creation untuk slot kosong
// - Memanggil Character Activation untuk slot terisi
//
// Storage:
// crp_storage.pwn
//
// TextDraw:
// crp_character_textdraw.pwn
//
// Character Creation:
// crp_character_create.pwn
//
// Character Activation:
// crp_character_activation.pwn
//
// PRID:
// - Setiap character memiliki PRID global.
// - PRID berasal dari Storage.
// - PRID tidak dibuat oleh Character Slot.
// - PRID tidak berubah ketika character rename.
// - PRID tidak berubah ketika character berpindah slot.
// ============================================================


#define COLOR_WHITE      0xFFFFFFFF
#define COLOR_GREEN      0x33AA33
#define COLOR_YELLOW     0xFFFF00
#define COLOR_RED        0xFF3333
#define COLOR_GREY       0xAAAAAA

#define CHARACTER_SLOT_COUNT 5

#define CHARACTER_SLOT_EMPTY     0
#define CHARACTER_SLOT_HAS_CHAR  1


// ============================================================
// CHARACTER DATA
// ============================================================

new gCharacterSlotStatus[MAX_PLAYERS][CHARACTER_SLOT_COUNT];

new gCharacterPRID[MAX_PLAYERS]
    [CHARACTER_SLOT_COUNT];

new gCharacterName[MAX_PLAYERS]
    [CHARACTER_SLOT_COUNT][25];

new gCharacterLevel[MAX_PLAYERS]
    [CHARACTER_SLOT_COUNT];

new gCharacterLastLogin[MAX_PLAYERS]
    [CHARACTER_SLOT_COUNT][32];

new gSelectedCharacterSlot[MAX_PLAYERS];


// ============================================================
// STORAGE REMOTE FUNCTIONS
// ============================================================

forward CRP_StorageCharacterExistsRemote(
    playerid,
    slot
);

forward CRP_StorageGetCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    lastlogin[],
    lastloginsize
);

forward CRP_StorageGetCharacterPRIDRemote(
    playerid,
    slot
);


// ============================================================
// CHARACTER CREATION REMOTE
// ============================================================

forward CRP_StartCharacterCreation(
    playerid,
    slot
);


// ============================================================
// CHARACTER ACTIVATION REMOTE
// ============================================================

forward CRP_ActivateCharacterRemote(
    playerid,
    slot
);


// ============================================================
// RESET CHARACTER SLOTS
// ============================================================

stock CRP_ResetCharacterSlots(
    playerid
)
{
    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        gCharacterSlotStatus[playerid][slot] =
            CHARACTER_SLOT_EMPTY;

        gCharacterPRID[playerid][slot] =
            0;

        gCharacterName[playerid][slot][0] =
            EOS;

        gCharacterLevel[playerid][slot] =
            0;

        gCharacterLastLogin[playerid][slot][0] =
            EOS;
    }

    gSelectedCharacterSlot[playerid] =
        -1;

    return 1;
}


// ============================================================
// LOAD CHARACTER SLOTS FROM STORAGE
// ============================================================

stock CRP_LoadCharacterSlots(
    playerid
)
{
    new charactername[25];
    new lastlogin[32];
    new level;
    new prid;
    new exists;

    CRP_ResetCharacterSlots(
        playerid
    );

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        exists = CallRemoteFunction(
            "CRP_StorageCharacterExistsRemote",
            "dd",
            playerid,
            slot
        );

        if (!exists)
        {
            gCharacterSlotStatus[playerid][slot] =
                CHARACTER_SLOT_EMPTY;

            continue;
        }


        // ----------------------------------------------------
        // RESET DATA SLOT
        // ----------------------------------------------------

        CRP_ResetCharacterSlotData(
            playerid,
            slot
        );


        // ----------------------------------------------------
        // LOAD BASIC CHARACTER DATA
        // ----------------------------------------------------

        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;

        CallRemoteFunction(
            "CRP_StorageGetCharacterSlotRemote",
            "ddsdss",
            playerid,
            slot,
            charactername,
            sizeof(charactername),
            level,
            lastlogin,
            sizeof(lastlogin)
        );


        // ----------------------------------------------------
        // LOAD PRID
        // ----------------------------------------------------

        prid = CallRemoteFunction(
            "CRP_StorageGetCharacterPRIDRemote",
            "dd",
            playerid,
            slot
        );


        // ----------------------------------------------------
        // SAVE TO CHARACTER SLOT CACHE
        // ----------------------------------------------------

        gCharacterSlotStatus[playerid][slot] =
            CHARACTER_SLOT_HAS_CHAR;

        gCharacterPRID[playerid][slot] =
            prid;

        format(
            gCharacterName[playerid][slot],
            25,
            "%s",
            charactername
        );

        gCharacterLevel[playerid][slot] =
            level;

        format(
            gCharacterLastLogin[playerid][slot],
            32,
            "%s",
            lastlogin
        );
    }

    return 1;
}


// ============================================================
// RESET ONE CHARACTER SLOT DATA
// ============================================================

stock CRP_ResetCharacterSlotData(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    gCharacterPRID[playerid][slot] =
        0;

    gCharacterName[playerid][slot][0] =
        EOS;

    gCharacterLevel[playerid][slot] =
        0;

    gCharacterLastLogin[playerid][slot][0] =
        EOS;

    return 1;
}


// ============================================================
// SET CHARACTER SLOT
// ============================================================

stock CRP_SetCharacterSlot(
    playerid,
    slot,
    prid,
    charactername[],
    level,
    lastlogin[]
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    gCharacterSlotStatus[playerid][slot] =
        CHARACTER_SLOT_HAS_CHAR;

    gCharacterPRID[playerid][slot] =
        prid;

    format(
        gCharacterName[playerid][slot],
        25,
        "%s",
        charactername
    );

    gCharacterLevel[playerid][slot] =
        level;

    format(
        gCharacterLastLogin[playerid][slot],
        32,
        "%s",
        lastlogin
    );

    return 1;
}


// ============================================================
// CHECK EMPTY SLOT
// ============================================================

stock CRP_IsCharacterSlotEmpty(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 1;
    }

    if (
        gCharacterSlotStatus[playerid][slot]
        == CHARACTER_SLOT_EMPTY
    )
    {
        return 1;
    }

    return 0;
}


// ============================================================
// SELECT CHARACTER SLOT
// ============================================================

stock CRP_SelectCharacterSlot(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP] Slot karakter tidak valid."
        );

        return 0;
    }

    gSelectedCharacterSlot[playerid] =
        slot;

    return 1;
}


// ============================================================
// GET SELECTED SLOT
// ============================================================

stock CRP_GetSelectedCharacterSlot(
    playerid
)
{
    return gSelectedCharacterSlot[playerid];
}


// ============================================================
// REMOTE: SELECT SLOT
// ============================================================

forward CRP_SelectCharacterSlotRemote(
    playerid,
    slot
);

public CRP_SelectCharacterSlotRemote(
    playerid,
    slot
)
{
    return CRP_SelectCharacterSlot(
        playerid,
        slot
    );
}


// ============================================================
// REMOTE: GET SELECTED SLOT
// ============================================================

forward CRP_GetSelectedCharacterSlotRemote(
    playerid
);

public CRP_GetSelectedCharacterSlotRemote(
    playerid
)
{
    return CRP_GetSelectedCharacterSlot(
        playerid
    );
}


// ============================================================
// GET CHARACTER SLOT STATUS
// ============================================================

forward CRP_GetCharacterSlotData(
    playerid,
    slot
);

public CRP_GetCharacterSlotData(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return CHARACTER_SLOT_EMPTY;
    }

    return gCharacterSlotStatus[playerid][slot];
}


// ============================================================
// GET CHARACTER SLOT PRID
// ============================================================

stock CRP_GetCharacterSlotPRID(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    return gCharacterPRID[playerid][slot];
}


// ============================================================
// REMOTE: GET CHARACTER SLOT PRID
// ============================================================

forward CRP_GetCharacterSlotPRIDRemote(
    playerid,
    slot
);

public CRP_GetCharacterSlotPRIDRemote(
    playerid,
    slot
)
{
    return CRP_GetCharacterSlotPRID(
        playerid,
        slot
    );
}


// ============================================================
// GET CHARACTER SLOT NAME
// ============================================================

forward CRP_GetCharacterSlotName(
    playerid,
    slot,
    name[],
    size
);

public CRP_GetCharacterSlotName(
    playerid,
    slot,
    name[],
    size
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        name[0] = EOS;

        return 0;
    }

    format(
        name,
        size,
        "%s",
        gCharacterName[playerid][slot]
    );

    return 1;
}


// ============================================================
// GET CHARACTER SLOT LEVEL
// ============================================================

forward CRP_GetCharacterSlotLevel(
    playerid,
    slot
);

public CRP_GetCharacterSlotLevel(
    playerid,
    slot
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        return 0;
    }

    return gCharacterLevel[playerid][slot];
}


// ============================================================
// GET CHARACTER SLOT LAST LOGIN
// ============================================================

forward CRP_GetCharacterSlotLastLogin(
    playerid,
    slot,
    lastlogin[],
    size
);

public CRP_GetCharacterSlotLastLogin(
    playerid,
    slot,
    lastlogin[],
    size
)
{
    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        lastlogin[0] = EOS;

        return 0;
    }

    format(
        lastlogin,
        size,
        "%s",
        gCharacterLastLogin[playerid][slot]
    );

    return 1;
}


// ============================================================
// CHARACTER SLOT CONFIRMED
// ============================================================

forward CRP_CharacterSlotConfirmed(
    playerid,
    slot
);

public CRP_CharacterSlotConfirmed(
    playerid,
    slot
)
{
    new message[144];

    if (
        slot < 0 ||
        slot >= CHARACTER_SLOT_COUNT
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP] Slot karakter tidak valid."
        );

        return 0;
    }


    // --------------------------------------------------------
    // SIMPAN SLOT YANG DIPILIH
    // --------------------------------------------------------

    gSelectedCharacterSlot[playerid] =
        slot;


    // --------------------------------------------------------
    // SLOT KOSONG
    // --------------------------------------------------------

    if (
        gCharacterSlotStatus[playerid][slot]
        == CHARACTER_SLOT_EMPTY
    )
    {
        format(
            message,
            sizeof(message),
            "Slot %d masih kosong. Character Creation akan dibuka.",
            slot + 1
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            message
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "[CRP] Silakan membuat karakter baru."
        );


        // ----------------------------------------------------
        // BUKA CHARACTER CREATION
        // ----------------------------------------------------

        CallRemoteFunction(
            "CRP_StartCharacterCreation",
            "dd",
            playerid,
            slot
        );

        return 1;
    }


    // --------------------------------------------------------
    // SLOT TERISI
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "Memilih karakter %s | Level %d | PRID %03d.",
        gCharacterName[playerid][slot],
        gCharacterLevel[playerid][slot],
        gCharacterPRID[playerid][slot]
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP CHARACTER] Mengaktifkan character..."
    );


    // --------------------------------------------------------
    // CHARACTER ACTIVATION
    // --------------------------------------------------------

    if (
        !CallRemoteFunction(
            "CRP_ActivateCharacterRemote",
            "dd",
            playerid,
            slot
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Character gagal diaktifkan."
        );

        return 0;
    }

    return 1;
}


// ============================================================
// REMOTE: LOAD CHARACTER SLOTS
// ============================================================

forward CRP_LoadCharacterSlotsRemote(
    playerid
);

public CRP_LoadCharacterSlotsRemote(
    playerid
)
{
    return CRP_LoadCharacterSlots(
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
    CRP_ResetCharacterSlots(
        playerid
    );

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
    CRP_ResetCharacterSlots(
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
    print(" CRP Character Slot System v0.6");
    print(" 5 Character Slots");
    print(" Storage Integration Loaded");
    print(" PRID / PURI Integration Loaded");
    print(" Remote Selected Slot Loaded");
    print(" Character Creation Integration Loaded");
    print(" Character Activation Integration Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP] Character Slot System unloaded."
    );

    return 1;
}