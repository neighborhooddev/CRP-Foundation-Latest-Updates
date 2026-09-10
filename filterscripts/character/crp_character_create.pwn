#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Creation System v0.5
//
// Fungsi:
// - Logic pembuatan karakter
// - Nama
// - Origin
// - Gender
// - Tanggal Lahir
// - Agama
// - Konfirmasi
// - Menyimpan character ke Storage
// - Mengambil PRID character
// - Reset state creation
// - Validasi input
//
// UI:
// crp_character_create_textdraw.pwn
//
// Selection:
// crp_character_slot.pwn
//
// Storage:
// crp_storage.pwn
//
// PRID:
// - Dibuat oleh Storage.
// - Setiap character memiliki PRID unik global.
// - PRID tidak berubah ketika nama berubah.
// - PRID tidak berubah ketika slot berubah.
// ============================================================


// ============================================================
// COLOR
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_RED       0xFF3333FF
#define COLOR_GREY      0xAAAAAAFF


// ============================================================
// CONSTANT
// ============================================================

#define CHARACTER_SLOT_COUNT 5

#define CREATE_STATE_NONE       0
#define CREATE_STATE_NAME       1
#define CREATE_STATE_ORIGIN     2
#define CREATE_STATE_GENDER     3
#define CREATE_STATE_DOB        4
#define CREATE_STATE_RELIGION   5
#define CREATE_STATE_CONFIRM    6

#define CHARACTER_NAME_MAX       24
#define CHARACTER_ORIGIN_MAX     63
#define CHARACTER_GENDER_MAX     15
#define CHARACTER_DOB_MAX        15
#define CHARACTER_RELIGION_MAX   23


// ============================================================
// CREATE DATA
// ============================================================

new gCreateState[MAX_PLAYERS];
new gCreateSlot[MAX_PLAYERS];

new gCreateName[MAX_PLAYERS][25];
new gCreateOrigin[MAX_PLAYERS][64];
new gCreateGender[MAX_PLAYERS][16];
new gCreateDOB[MAX_PLAYERS][16];
new gCreateReligion[MAX_PLAYERS][24];


// ============================================================
// STORAGE REMOTE
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

forward CRP_StorageSaveCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    level,
    origin[],
    gender[],
    dob[],
    religion[],
    lastip[],
    lastlogout[]
);


// ============================================================
// CHARACTER SLOT REMOTE
// ============================================================

forward CRP_LoadCharacterSlotsRemote(
    playerid
);

forward CRP_ShowCharacterSelectionRemote(
    playerid
);


// ============================================================
// CHARACTER CREATION UI REMOTE
// ============================================================

forward CRP_ShowCharacterCreationUIRemote(
    playerid
);


// ============================================================
// REGISTER SPAWN REMOTE
// ============================================================

forward CRP_ShowRegisterSpawnSelectionRemote(
    playerid
);


// ============================================================
// RESET
// ============================================================

stock CRP_ResetCharacterCreation(
    playerid
)
{
    gCreateState[playerid] = CREATE_STATE_NONE;
    gCreateSlot[playerid] = -1;

    gCreateName[playerid][0] = EOS;
    gCreateOrigin[playerid][0] = EOS;
    gCreateGender[playerid][0] = EOS;
    gCreateDOB[playerid][0] = EOS;
    gCreateReligion[playerid][0] = EOS;

    return 1;
}


// ============================================================
// GETTERS
// ============================================================

forward CRP_GetCreateStateRemote(
    playerid
);

public CRP_GetCreateStateRemote(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return CREATE_STATE_NONE;
    }

    return gCreateState[playerid];
}


forward CRP_GetCreateSlotRemote(
    playerid
);

public CRP_GetCreateSlotRemote(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return -1;
    }

    return gCreateSlot[playerid];
}


forward CRP_GetCreateNameRemote(
    playerid,
    name[],
    size
);

public CRP_GetCreateNameRemote(
    playerid,
    name[],
    size
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        name[0] = EOS;
        return 0;
    }

    format(
        name,
        size,
        "%s",
        gCreateName[playerid]
    );

    return 1;
}


forward CRP_GetCreateOriginRemote(
    playerid,
    origin[],
    size
);

public CRP_GetCreateOriginRemote(
    playerid,
    origin[],
    size
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        origin[0] = EOS;
        return 0;
    }

    format(
        origin,
        size,
        "%s",
        gCreateOrigin[playerid]
    );

    return 1;
}


forward CRP_GetCreateGenderRemote(
    playerid,
    gender[],
    size
);

public CRP_GetCreateGenderRemote(
    playerid,
    gender[],
    size
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        gender[0] = EOS;
        return 0;
    }

    format(
        gender,
        size,
        "%s",
        gCreateGender[playerid]
    );

    return 1;
}


forward CRP_GetCreateDOBRemote(
    playerid,
    dob[],
    size
);

public CRP_GetCreateDOBRemote(
    playerid,
    dob[],
    size
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        dob[0] = EOS;
        return 0;
    }

    format(
        dob,
        size,
        "%s",
        gCreateDOB[playerid]
    );

    return 1;
}


forward CRP_GetCreateReligionRemote(
    playerid,
    religion[],
    size
);

public CRP_GetCreateReligionRemote(
    playerid,
    religion[],
    size
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        religion[0] = EOS;
        return 0;
    }

    format(
        religion,
        size,
        "%s",
        gCreateReligion[playerid]
    );

    return 1;
}


// ============================================================
// NAME VALIDATION
// ============================================================

stock CRP_IsValidCharacterName(
    name[]
)
{
    new length = strlen(name);
    new underscore = 0;

    if (
        length < 3 ||
        length > CHARACTER_NAME_MAX
    )
    {
        return 0;
    }

    for (
        new i = 0;
        i < length;
        i++
    )
    {
        if (
            name[i] == '_'
        )
        {
            underscore++;

            if (
                i == 0 ||
                i == length - 1
            )
            {
                return 0;
            }

            continue;
        }

        if (
            (name[i] >= 'A' && name[i] <= 'Z') ||
            (name[i] >= 'a' && name[i] <= 'z')
        )
        {
            continue;
        }

        return 0;
    }

    if (
        underscore != 1
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// CHARACTER NAME CHECK
//
// Catatan:
// Saat ini pengecekan nama dilakukan terhadap character
// yang tersimpan pada slot account/player yang sama.
//
// Global name uniqueness membutuhkan interface Storage
// khusus dan tidak dibuat secara asumsi di file ini.
// ============================================================

stock CRP_IsCharacterNameUsed(
    playerid,
    name[]
)
{
    new charactername[25];
    new level;
    new lastlogin[32];

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        if (
            !CallRemoteFunction(
                "CRP_StorageCharacterExistsRemote",
                "dd",
                playerid,
                slot
            )
        )
        {
            continue;
        }

        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;

        // ----------------------------------------------------
        // Storage signature:
        //
        // playerid       = d
        // slot           = d
        // charactername  = s
        // namesize       = d
        // level          = d
        // lastlogin      = s
        // lastloginsize  = d
        //
        // Correct format:
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

        if (
            !strcmp(
                charactername,
                name,
                true
            )
        )
        {
            return 1;
        }
    }

    return 0;
}


// ============================================================
// START CREATION
// ============================================================

forward CRP_StartCharacterCreation(
    playerid,
    slot
);

public CRP_StartCharacterCreation(
    playerid,
    slot
)
{
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

    // --------------------------------------------------------
    // SLOT MUST BE EMPTY
    // --------------------------------------------------------

    if (
        CallRemoteFunction(
            "CRP_StorageCharacterExistsRemote",
            "dd",
            playerid,
            slot
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Slot tersebut sudah memiliki karakter."
        );

        return 0;
    }


    // --------------------------------------------------------
    // RESET CREATE STATE
    // --------------------------------------------------------

    CRP_ResetCharacterCreation(
        playerid
    );

    gCreateSlot[playerid] =
        slot;

    gCreateState[playerid] =
        CREATE_STATE_NAME;


    // --------------------------------------------------------
    // INFO
    // --------------------------------------------------------

    new message[144];

    format(
        message,
        sizeof(message),
        "[CRP CHARACTER] Character Creation dimulai untuk Slot %d.",
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
        "[CRP CHARACTER] Silakan lengkapi data character kamu."
    );


    // --------------------------------------------------------
    // SHOW CHARACTER CREATION UI
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_ShowCharacterCreationUIRemote",
        "d",
        playerid
    );

    return 1;
}


// ============================================================
// NAME
// ============================================================

forward CRP_CreateName(
    playerid,
    input[]
);

public CRP_CreateName(
    playerid,
    input[]
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_NAME
    )
    {
        return 0;
    }

    if (
        !CRP_IsValidCharacterName(
            input
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Format nama tidak valid."
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP CHARACTER] Gunakan format NamaDepan_NamaBelakang."
        );

        return 0;
    }

    if (
        CRP_IsCharacterNameUsed(
            playerid,
            input
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Nama karakter tersebut sudah digunakan."
        );

        return 0;
    }

    format(
        gCreateName[playerid],
        sizeof(gCreateName[]),
        "%s",
        input
    );

    gCreateState[playerid] =
        CREATE_STATE_ORIGIN;

    return 1;
}


// ============================================================
// ORIGIN
// ============================================================

forward CRP_CreateOrigin(
    playerid,
    input[]
);

public CRP_CreateOrigin(
    playerid,
    input[]
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_ORIGIN
    )
    {
        return 0;
    }

    if (
        strlen(input) < 3
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Origin terlalu pendek."
        );

        return 0;
    }

    if (
        strlen(input)
        > CHARACTER_ORIGIN_MAX
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Origin terlalu panjang."
        );

        return 0;
    }

    format(
        gCreateOrigin[playerid],
        sizeof(gCreateOrigin[]),
        "%s",
        input
    );

    gCreateState[playerid] =
        CREATE_STATE_GENDER;

    return 1;
}


// ============================================================
// GENDER
// ============================================================

forward CRP_CreateGender(
    playerid,
    listitem
);

public CRP_CreateGender(
    playerid,
    listitem
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_GENDER
    )
    {
        return 0;
    }

    if (
        listitem == 0
    )
    {
        format(
            gCreateGender[playerid],
            sizeof(gCreateGender[]),
            "Laki-Laki"
        );
    }
    else if (
        listitem == 1
    )
    {
        format(
            gCreateGender[playerid],
            sizeof(gCreateGender[]),
            "Perempuan"
        );
    }
    else
    {
        return 0;
    }

    gCreateState[playerid] =
        CREATE_STATE_DOB;

    return 1;
}


// ============================================================
// DOB VALIDATION
//
// Format:
// DD/MM/YYYY
//
// Sistem saat ini memvalidasi:
// - Panjang
// - Posisi "/"
// - Semua karakter angka
//
// Validasi kalender detail dapat ditambahkan kemudian.
// ============================================================

stock CRP_IsValidDOB(
    dob[]
)
{
    if (
        strlen(dob) != 10
    )
    {
        return 0;
    }

    if (
        dob[2] != '/' ||
        dob[5] != '/'
    )
    {
        return 0;
    }

    for (
        new i = 0;
        i < 10;
        i++
    )
    {
        if (
            i == 2 ||
            i == 5
        )
        {
            continue;
        }

        if (
            dob[i] < '0' ||
            dob[i] > '9'
        )
        {
            return 0;
        }
    }

    return 1;
}


// ============================================================
// DOB
// ============================================================

forward CRP_CreateDOB(
    playerid,
    input[]
);

public CRP_CreateDOB(
    playerid,
    input[]
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_DOB
    )
    {
        return 0;
    }

    if (
        !CRP_IsValidDOB(
            input
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Format tanggal lahir tidak valid."
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP CHARACTER] Gunakan format DD/MM/YYYY."
        );

        return 0;
    }

    format(
        gCreateDOB[playerid],
        sizeof(gCreateDOB[]),
        "%s",
        input
    );

    gCreateState[playerid] =
        CREATE_STATE_RELIGION;

    return 1;
}


// ============================================================
// RELIGION
// ============================================================

forward CRP_CreateReligion(
    playerid,
    listitem
);

public CRP_CreateReligion(
    playerid,
    listitem
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_RELIGION
    )
    {
        return 0;
    }

    switch (listitem)
    {
        case 0:
        {
            format(
                gCreateReligion[playerid],
                sizeof(gCreateReligion[]),
                "Islam"
            );
        }

        case 1:
        {
            format(
                gCreateReligion[playerid],
                sizeof(gCreateReligion[]),
                "Kristen"
            );
        }

        case 2:
        {
            format(
                gCreateReligion[playerid],
                sizeof(gCreateReligion[]),
                "Hindu"
            );
        }

        case 3:
        {
            format(
                gCreateReligion[playerid],
                sizeof(gCreateReligion[]),
                "Buddha"
            );
        }

        case 4:
        {
            format(
                gCreateReligion[playerid],
                sizeof(gCreateReligion[]),
                "Lainnya"
            );
        }

        default:
        {
            return 0;
        }
    }

    gCreateState[playerid] =
        CREATE_STATE_CONFIRM;

    return 1;
}


// ============================================================
// SAVE CHARACTER
// ============================================================

forward CRP_SaveCreatedCharacter(
    playerid
);

public CRP_SaveCreatedCharacter(
    playerid
)
{
    new ip[16];
    new lastlogout[32];
    new saved;
    new prid;
    new message[144];

    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    if (
        gCreateState[playerid]
        != CREATE_STATE_CONFIRM
    )
    {
        return 0;
    }

    if (
        gCreateSlot[playerid] < 0 ||
        gCreateSlot[playerid] >= CHARACTER_SLOT_COUNT
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Slot karakter tidak valid."
        );

        return 0;
    }


    // --------------------------------------------------------
    // FINAL DATA VALIDATION
    // --------------------------------------------------------

    if (
        !CRP_IsValidCharacterName(
            gCreateName[playerid]
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data nama character tidak valid."
        );

        return 0;
    }

    if (
        strlen(gCreateOrigin[playerid]) < 3
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data origin character tidak valid."
        );

        return 0;
    }

    if (
        gCreateGender[playerid][0] == EOS
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data gender character belum diisi."
        );

        return 0;
    }

    if (
        !CRP_IsValidDOB(
            gCreateDOB[playerid]
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data tanggal lahir tidak valid."
        );

        return 0;
    }

    if (
        gCreateReligion[playerid][0] == EOS
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Data agama character belum diisi."
        );

        return 0;
    }


    // --------------------------------------------------------
    // DOUBLE CHECK SLOT
    // --------------------------------------------------------

    if (
        CallRemoteFunction(
            "CRP_StorageCharacterExistsRemote",
            "dd",
            playerid,
            gCreateSlot[playerid]
        )
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Slot tersebut sudah memiliki karakter."
        );

        CRP_ResetCharacterCreation(
            playerid
        );

        return 0;
    }


    // --------------------------------------------------------
    // PLAYER IP
    // --------------------------------------------------------

    GetPlayerIp(
        playerid,
        ip,
        sizeof(ip)
    );

    format(
        lastlogout,
        sizeof(lastlogout),
        "-"
    );


    // --------------------------------------------------------
    // SAVE TO STORAGE
    //
    // Storage yang menentukan PRID.
    //
    // Parameter:
    // playerid
    // slot
    // charactername
    // level
    // origin
    // gender
    // dob
    // religion
    // lastip
    // lastlogout
    // --------------------------------------------------------

    saved = CallRemoteFunction(
        "CRP_StorageSaveCharacterSlotRemote",
        "ddsdssssss",
        playerid,
        gCreateSlot[playerid],
        gCreateName[playerid],
        1,
        gCreateOrigin[playerid],
        gCreateGender[playerid],
        gCreateDOB[playerid],
        gCreateReligion[playerid],
        ip,
        lastlogout
    );


    // --------------------------------------------------------
    // SAVE FAILED
    // --------------------------------------------------------

    if (
        !saved
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] Character gagal disimpan."
        );

        return 0;
    }


    // --------------------------------------------------------
    // GET PRID
    //
    // PRID dibuat dan dikontrol oleh Storage.
    // --------------------------------------------------------

    prid = CallRemoteFunction(
        "CRP_StorageGetCharacterPRIDRemote",
        "dd",
        playerid,
        gCreateSlot[playerid]
    );

    if (
        prid <= 0
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP CHARACTER] PRID character tidak ditemukan."
        );

        return 0;
    }


    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP CHARACTER] Character berhasil dibuat."
    );

    format(
        message,
        sizeof(message),
        "[CRP CHARACTER] Character: %s | PRID: %03d",
        gCreateName[playerid],
        prid
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "[CRP CHARACTER] Character kamu disimpan pada Level 1."
    );


    // --------------------------------------------------------
    // RESET CREATE STATE
    // --------------------------------------------------------

    CRP_ResetCharacterCreation(
        playerid
    );


    // --------------------------------------------------------
    // RELOAD CHARACTER SLOTS
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_LoadCharacterSlotsRemote",
        "d",
        playerid
    );


    // --------------------------------------------------------
    // REGISTER SPAWN SELECTION
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_ShowRegisterSpawnSelectionRemote",
        "d",
        playerid
    );

    return 1;
}


// ============================================================
// CANCEL CREATION
// ============================================================

forward CRP_CancelCharacterCreation(
    playerid
);

public CRP_CancelCharacterCreation(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    CRP_ResetCharacterCreation(
        playerid
    );

    CallRemoteFunction(
        "CRP_ShowCharacterSelectionRemote",
        "d",
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(
    playerid
)
{
    CRP_ResetCharacterCreation(
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
    CRP_ResetCharacterCreation(
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
    print(" CRP Character Creation System v0.5");
    print(" Logic System Loaded");
    print(" TextDraw UI Separated");
    print(" Character Storage Interface Loaded");
    print(" Global PRID Integration Loaded");
    print(" Register Spawn Integration Loaded");
    print(" Creation State Validation Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP CHARACTER CREATE] System unloaded."
    );

    return 1;
}