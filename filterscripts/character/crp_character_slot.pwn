#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Slot System v0.7
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
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
// ============================================================
// PRID POLICY
// ============================================================
//
// - Setiap character memiliki PRID global.
// - PRID berasal dari Storage.
// - PRID tidak dibuat oleh Character Slot.
// - PRID tidak berubah ketika character rename.
// - PRID tidak berubah ketika character berpindah slot.
//
// ============================================================
// SLOT POLICY
// ============================================================
//
// SLOT 1 = index 0
// SLOT 2 = index 1
// SLOT 3 = index 2
// SLOT 4 = index 3
// SLOT 5 = index 4
//
// ============================================================


#define COLOR_WHITE      0xFFFFFFFF
#define COLOR_GREEN      0x33AA33FF
#define COLOR_YELLOW     0xFFFF00FF
#define COLOR_RED        0xFF3333FF
#define COLOR_GREY       0xAAAAAAFF


#define CHARACTER_SLOT_COUNT 5


#define CHARACTER_SLOT_EMPTY     0
#define CHARACTER_SLOT_HAS_CHAR  1


// ============================================================
// CHARACTER DATA
// ============================================================

new gCharacterSlotStatus[MAX_PLAYERS][CHARACTER_SLOT_COUNT];

new gCharacterPRID[MAX_PLAYERS][CHARACTER_SLOT_COUNT];

new gCharacterName[MAX_PLAYERS][CHARACTER_SLOT_COUNT][25];

new gCharacterLevel[MAX_PLAYERS][CHARACTER_SLOT_COUNT];

new gCharacterLastLogin[MAX_PLAYERS][CHARACTER_SLOT_COUNT][32];

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
// INTERNAL VALIDATION
// ============================================================

stock CRP_IsValidCharacterSlot(
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
    if (!CRP_IsValidCharacterSlot(slot))
    {
        return 0;
    }

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

    return 1;
}


// ============================================================
// RESET ALL CHARACTER SLOTS
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
        CRP_ResetCharacterSlotData(
            playerid,
            slot
        );
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
    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // LOCAL VARIABLES
    // --------------------------------------------------------

    new charactername[25];
    new lastlogin[32];

    new level;
    new prid;
    new exists;


    // --------------------------------------------------------
    // RESET CURRENT CACHE
    // --------------------------------------------------------

    CRP_ResetCharacterSlots(
        playerid
    );


    // --------------------------------------------------------
    // LOAD 5 CHARACTER SLOTS
    // --------------------------------------------------------

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        // ----------------------------------------------------
        // CHECK CHARACTER EXISTS
        // ----------------------------------------------------

        exists = CallRemoteFunction(
            "CRP_StorageCharacterExistsRemote",
            "dd",
            playerid,
            slot
        );


        // ----------------------------------------------------
        // SLOT EMPTY
        // ----------------------------------------------------

        if (!exists)
        {
            CRP_ResetCharacterSlotData(
                playerid,
                slot
            );

            continue;
        }


        // ----------------------------------------------------
        // RESET LOCAL SLOT DATA
        // ----------------------------------------------------

        CRP_ResetCharacterSlotData(
            playerid,
            slot
        );


        // ----------------------------------------------------
        // RESET TEMP VARIABLES
        // ----------------------------------------------------

        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;


        // ----------------------------------------------------
        // LOAD BASIC CHARACTER DATA
        //
        // Parameter:
        //
        // playerid      = d
        // slot          = d
        // charactername = s
        // namesize      = d
        // level         = d
        // lastlogin     = s
        // lastloginsize = d
        //
        // Format:
        // "ddsddsd"
        // ----------------------------------------------------

        CallRemoteFunction(
            "CRP_StorageGetCharacterSlotRemote",
            "ddsddsd",
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
        // SAVE DATA TO LOCAL CACHE
        // ----------------------------------------------------

        gCharacterSlotStatus[playerid][slot] =
            CHARACTER_SLOT_HAS_CHAR;

        gCharacterPRID[playerid][slot] =
            prid;

        format(
            gCharacterName[playerid][slot],
            sizeof(gCharacterName[][][]),
            "%s",
            charactername
        );

        gCharacterLevel[playerid][slot] =
            level;

        format(
            gCharacterLastLogin[playerid][slot],
            sizeof(gCharacterLastLogin[][][]),
            "%s",
            lastlogin
        );
    }


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
    if (!CRP_IsValidCharacterSlot(slot))
    {
        return 0;
    }


    // --------------------------------------------------------
    // SLOT STATUS
    // --------------------------------------------------------

    gCharacterSlotStatus[playerid][slot] =
        CHARACTER_SLOT_HAS_CHAR;


    // --------------------------------------------------------
    // PRID
    // --------------------------------------------------------

    gCharacterPRID[playerid][slot] =
        prid;


    // --------------------------------------------------------
    // CHARACTER NAME
    // --------------------------------------------------------

    format(
        gCharacterName[playerid][slot],
        sizeof(gCharacterName[][][]),
        "%s",
        charactername
    );


    // --------------------------------------------------------
    // LEVEL
    // --------------------------------------------------------

    gCharacterLevel[playerid][slot] =
        level;


    // --------------------------------------------------------
    // LAST LOGIN
    // --------------------------------------------------------

    format(
        gCharacterLastLogin[playerid][slot],
        sizeof(gCharacterLastLogin[][][]),
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
    if (!CRP_IsValidCharacterSlot(slot))
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
    if (!CRP_IsValidCharacterSlot(slot))
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
// GET SELECTED CHARACTER SLOT
// ============================================================

stock CRP_GetSelectedCharacterSlot(
    playerid
)
{
    return gSelectedCharacterSlot[playerid];
}


// ============================================================
// REMOTE: SELECT CHARACTER SLOT
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
// REMOTE: GET SELECTED CHARACTER SLOT
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

stock CRP_GetCharacterSlotStatus(
    playerid,
    slot
)
{
    if (!CRP_IsValidCharacterSlot(slot))
    {
        return CHARACTER_SLOT_EMPTY;
    }


    return gCharacterSlotStatus[playerid][slot];
}


// ============================================================
// REMOTE: GET CHARACTER SLOT STATUS
// ============================================================

forward CRP_GetCharacterSlotStatusRemote(
    playerid,
    slot
);

public CRP_GetCharacterSlotStatusRemote(
    playerid,
    slot
)
{
    return CRP_GetCharacterSlotStatus(
        playerid,
        slot
    );
}


// ============================================================
// LEGACY REMOTE: GET CHARACTER SLOT DATA
// ============================================================
//
// Dipertahankan agar sistem lama yang memanggil:
// CRP_GetCharacterSlotData
//
// tetap dapat digunakan.
//

forward CRP_GetCharacterSlotData(
    playerid,
    slot
);

public CRP_GetCharacterSlotData(
    playerid,
    slot
)
{
    return CRP_GetCharacterSlotStatus(
        playerid,
        slot
    );
}


// ============================================================
// GET CHARACTER SLOT PRID
// ============================================================

stock CRP_GetCharacterSlotPRID(
    playerid,
    slot
)
{
    if (!CRP_IsValidCharacterSlot(slot))
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

stock CRP_GetCharacterSlotName(
    playerid,
    slot,
    name[],
    size
)
{
    if (!CRP_IsValidCharacterSlot(slot))
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
// REMOTE: GET CHARACTER SLOT NAME
// ============================================================

forward CRP_GetCharacterSlotNameRemote(
    playerid,
    slot,
    name[],
    size
);

public CRP_GetCharacterSlotNameRemote(
    playerid,
    slot,
    name[],
    size
)
{
    return CRP_GetCharacterSlotName(
        playerid,
        slot,
        name,
        size
    );
}


// ============================================================
// GET CHARACTER SLOT LEVEL
// ============================================================

stock CRP_GetCharacterSlotLevel(
    playerid,
    slot
)
{
    if (!CRP_IsValidCharacterSlot(slot))
    {
        return 0;
    }


    return gCharacterLevel[playerid][slot];
}


// ============================================================
// REMOTE: GET CHARACTER SLOT LEVEL
// ============================================================

forward CRP_GetCharacterSlotLevelRemote(
    playerid,
    slot
);

public CRP_GetCharacterSlotLevelRemote(
    playerid,
    slot
)
{
    return CRP_GetCharacterSlotLevel(
        playerid,
        slot
    );
}


// ============================================================
// GET CHARACTER SLOT LAST LOGIN
// ============================================================

stock CRP_GetCharacterSlotLastLogin(
    playerid,
    slot,
    lastlogin[],
    size
)
{
    if (!CRP_IsValidCharacterSlot(slot))
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
// REMOTE: GET CHARACTER SLOT LAST LOGIN
// ============================================================

forward CRP_GetCharacterSlotLastLoginRemote(
    playerid,
    slot,
    lastlogin[],
    size
);

public CRP_GetCharacterSlotLastLoginRemote(
    playerid,
    slot,
    lastlogin[],
    size
)
{
    return CRP_GetCharacterSlotLastLogin(
        playerid,
        slot,
        lastlogin,
        size
    );
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


    // --------------------------------------------------------
    // VALID PLAYER
    // --------------------------------------------------------

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // VALID SLOT
    // --------------------------------------------------------

    if (!CRP_IsValidCharacterSlot(slot))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP] Slot karakter tidak valid."
        );

        return 0;
    }


    // --------------------------------------------------------
    // SAVE SELECTED SLOT
    // --------------------------------------------------------

    gSelectedCharacterSlot[playerid] =
        slot;


    // --------------------------------------------------------
    // EMPTY SLOT
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
        // OPEN CHARACTER CREATION
        // ----------------------------------------------------

        if (
            !CallRemoteFunction(
                "CRP_StartCharacterCreation",
                "dd",
                playerid,
                slot
            )
        )
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP CHARACTER] Character Creation gagal dibuka."
            );

            return 0;
        }


        return 1;
    }


    // --------------------------------------------------------
    // FILLED SLOT
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
    print(" CRP Character Slot System v0.7");
    print(" 5 Character Slots");
    print(" Storage Integration Loaded");
    print(" PRID / PURI Integration Loaded");
    print(" Character Selection Loaded");
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