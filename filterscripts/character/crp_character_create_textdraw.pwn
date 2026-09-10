#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character Creation TextDraw System v0.2
//
// Fungsi:
// - UI Character Creation
// - Nama
// - Origin
// - Gender
// - DOB
// - Agama
// - Konfirmasi
//
// Logic:
// crp_character_create.pwn
//
// Komunikasi:
// CallRemoteFunction()
// ============================================================


// ============================================================
// COLOR
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREY      0xAAAAAAFF
#define COLOR_GREEN     0x33AA33FF
#define COLOR_RED       0xFF3333FF
#define COLOR_YELLOW    0xFFFF00FF


// ============================================================
// DIALOG
// ============================================================

#define DIALOG_CREATE_NAME       2200
#define DIALOG_CREATE_ORIGIN     2201
#define DIALOG_CREATE_GENDER     2202
#define DIALOG_CREATE_DOB        2203
#define DIALOG_CREATE_RELIGION   2204
#define DIALOG_CREATE_CONFIRM    2205


// ============================================================
// CREATE STATE
// ============================================================

#define CREATE_STATE_NAME       1
#define CREATE_STATE_ORIGIN     2
#define CREATE_STATE_GENDER     3
#define CREATE_STATE_DOB        4
#define CREATE_STATE_RELIGION   5
#define CREATE_STATE_CONFIRM    6


// ============================================================
// TEXTDRAW ID
// ============================================================

#define TD_BACKGROUND       0
#define TD_TITLE            1
#define TD_SUBTITLE         2
#define TD_SLOT_INFO        3
#define TD_NAME             4
#define TD_ORIGIN           5
#define TD_GENDER           6
#define TD_DOB              7
#define TD_RELIGION         8
#define TD_CONFIRM          9
#define TD_CANCEL           10

#define CREATE_TD_COUNT     11


// ============================================================
// PLAYER TEXTDRAW
// ============================================================

new PlayerText:gCreateTD[MAX_PLAYERS][CREATE_TD_COUNT];


// ============================================================
// LOGIC REMOTE
// ============================================================

forward CRP_GetCreateStateRemote(
    playerid
);

forward CRP_GetCreateSlotRemote(
    playerid
);

forward CRP_GetCreateNameRemote(
    playerid,
    name[],
    size
);

forward CRP_GetCreateOriginRemote(
    playerid,
    origin[],
    size
);

forward CRP_GetCreateGenderRemote(
    playerid,
    gender[],
    size
);

forward CRP_GetCreateDOBRemote(
    playerid,
    dob[],
    size
);

forward CRP_GetCreateReligionRemote(
    playerid,
    religion[],
    size
);

forward CRP_CreateName(
    playerid,
    input[]
);

forward CRP_CreateOrigin(
    playerid,
    input[]
);

forward CRP_CreateGender(
    playerid,
    listitem
);

forward CRP_CreateDOB(
    playerid,
    input[]
);

forward CRP_CreateReligion(
    playerid,
    listitem
);

forward CRP_SaveCreatedCharacter(
    playerid
);

forward CRP_CancelCharacterCreation(
    playerid
);


// ============================================================
// CREATE TEXTDRAW
// ============================================================

stock CRP_CreateCharacterCreateTextDraw(
    playerid
)
{
    // ========================================================
    // BACKGROUND
    // ========================================================

    gCreateTD[playerid][TD_BACKGROUND] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            190.0,
            "_"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        0.0,
        20.0
    );

    PlayerTextDrawTextSize(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        0.0,
        470.0
    );

    PlayerTextDrawUseBox(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        0x111111EE
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        2
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_BACKGROUND],
        1
    );


    // ========================================================
    // TITLE
    // ========================================================

    gCreateTD[playerid][TD_TITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            210.0,
            "CHARACTER CREATION"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_TITLE],
        0.35,
        1.5
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_TITLE],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_TITLE],
        1
    );


    // ========================================================
    // SUBTITLE
    // ========================================================

    gCreateTD[playerid][TD_SUBTITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            235.0,
            "Buat karakter baru untuk memulai perjalananmu."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_SUBTITLE],
        0.20,
        1.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_SUBTITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_SUBTITLE],
        COLOR_GREY
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_SUBTITLE],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_SUBTITLE],
        1
    );


    // ========================================================
    // SLOT INFO
    // ========================================================

    gCreateTD[playerid][TD_SLOT_INFO] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            260.0,
            "Slot karakter"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        COLOR_YELLOW
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        1
    );


    // ========================================================
    // NAME
    // ========================================================

    gCreateTD[playerid][TD_NAME] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            285.0,
            "NAMA KARAKTER"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_NAME],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_NAME],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_NAME],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_NAME],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_NAME],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_NAME],
        1
    );


    // ========================================================
    // ORIGIN
    // ========================================================

    gCreateTD[playerid][TD_ORIGIN] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            310.0,
            "ASAL / ORIGIN"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_ORIGIN],
        1
    );


    // ========================================================
    // GENDER
    // ========================================================

    gCreateTD[playerid][TD_GENDER] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            335.0,
            "JENIS KELAMIN"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_GENDER],
        1
    );


    // ========================================================
    // DOB
    // ========================================================

    gCreateTD[playerid][TD_DOB] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            360.0,
            "TANGGAL LAHIR"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_DOB],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_DOB],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_DOB],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_DOB],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_DOB],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_DOB],
        1
    );


    // ========================================================
    // RELIGION
    // ========================================================

    gCreateTD[playerid][TD_RELIGION] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            385.0,
            "AGAMA"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_RELIGION],
        1
    );


    // ========================================================
    // CONFIRM
    // ========================================================

    gCreateTD[playerid][TD_CONFIRM] =
        CreatePlayerTextDraw(
            playerid,
            265.0,
            420.0,
            "[  KONFIRMASI  ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        COLOR_GREEN
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_CONFIRM],
        1
    );


    // ========================================================
    // CANCEL
    // ========================================================

    gCreateTD[playerid][TD_CANCEL] =
        CreatePlayerTextDraw(
            playerid,
            375.0,
            420.0,
            "[  BATAL  ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        COLOR_RED
    );

    PlayerTextDrawFont(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCreateTD[playerid][TD_CANCEL],
        1
    );

    return 1;
}


// ============================================================
// SHOW UI
// ============================================================

stock CRP_ShowCharacterCreateUI(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    new slot;
    new slottext[64];

    slot = CallRemoteFunction(
        "CRP_GetCreateSlotRemote",
        "d",
        playerid
    );

    if (
        slot < 0
    )
    {
        return 0;
    }

    format(
        slottext,
        sizeof(slottext),
        "Membuat karakter pada Slot %d",
        slot + 1
    );

    PlayerTextDrawSetString(
        playerid,
        gCreateTD[playerid][TD_SLOT_INFO],
        slottext
    );

    for (
        new i = 0;
        i < CREATE_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawShow(
            playerid,
            gCreateTD[playerid][i]
        );
    }

    SelectTextDraw(
        playerid,
        COLOR_WHITE
    );

    return 1;
}


// ============================================================
// HIDE UI
// ============================================================

stock CRP_HideCharacterCreateUI(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    for (
        new i = 0;
        i < CREATE_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawHide(
            playerid,
            gCreateTD[playerid][i]
        );
    }

    CancelSelectTextDraw(playerid);

    return 1;
}


// ============================================================
// SHOW NAME DIALOG
// ============================================================

stock CRP_ShowCreateNameDialog(
    playerid
)
{
    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_NAME,
        DIALOG_STYLE_INPUT,
        "CRYSTAL ROLEPLAY | NAMA",
        "Masukkan nama karakter.\n\nFormat:\nNamaDepan_NamaBelakang\n\nContoh:\nMuhammad_Rizal",
        "LANJUT",
        "BATAL"
    );

    return 1;
}


// ============================================================
// SHOW ORIGIN DIALOG
// ============================================================

stock CRP_ShowCreateOriginDialog(
    playerid
)
{
    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_ORIGIN,
        DIALOG_STYLE_INPUT,
        "CRYSTAL ROLEPLAY | ORIGIN",
        "Masukkan asal karakter kamu.\n\nContoh:\nJakarta, Indonesia",
        "LANJUT",
        "BATAL"
    );

    return 1;
}


// ============================================================
// SHOW GENDER DIALOG
// ============================================================

stock CRP_ShowCreateGenderDialog(
    playerid
)
{
    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_GENDER,
        DIALOG_STYLE_LIST,
        "CRYSTAL ROLEPLAY | GENDER",
        "Laki-Laki\nPerempuan",
        "PILIH",
        "BATAL"
    );

    return 1;
}


// ============================================================
// SHOW DOB DIALOG
// ============================================================

stock CRP_ShowCreateDOBDialog(
    playerid
)
{
    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_DOB,
        DIALOG_STYLE_INPUT,
        "CRYSTAL ROLEPLAY | TANGGAL LAHIR",
        "Masukkan tanggal lahir karakter.\n\nFormat wajib: DD/MM/YYYY\n\nContoh: 20/01/1989",
        "LANJUT",
        "BATAL"
    );

    return 1;
}


// ============================================================
// SHOW RELIGION DIALOG
// ============================================================

stock CRP_ShowCreateReligionDialog(
    playerid
)
{
    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_RELIGION,
        DIALOG_STYLE_LIST,
        "CRYSTAL ROLEPLAY | AGAMA",
        "Islam\nKristen\nHindu\nBuddha\nLainnya",
        "PILIH",
        "BATAL"
    );

    return 1;
}


// ============================================================
// SHOW CONFIRMATION
// ============================================================

stock CRP_ShowCreateConfirmation(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    new name[25];
    new origin[64];
    new gender[16];
    new dob[16];
    new religion[24];
    new confirm[512];

    // --------------------------------------------------------
    // IMPORTANT:
    //
    // Getter signature:
    //
    // playerid
    // string[]
    // size
    //
    // Correct CallRemoteFunction format:
    // "dsd"
    //
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_GetCreateNameRemote",
        "dsd",
        playerid,
        name,
        sizeof(name)
    );

    CallRemoteFunction(
        "CRP_GetCreateOriginRemote",
        "dsd",
        playerid,
        origin,
        sizeof(origin)
    );

    CallRemoteFunction(
        "CRP_GetCreateGenderRemote",
        "dsd",
        playerid,
        gender,
        sizeof(gender)
    );

    CallRemoteFunction(
        "CRP_GetCreateDOBRemote",
        "dsd",
        playerid,
        dob,
        sizeof(dob)
    );

    CallRemoteFunction(
        "CRP_GetCreateReligionRemote",
        "dsd",
        playerid,
        religion,
        sizeof(religion)
    );

    format(
        confirm,
        sizeof(confirm),
        "Pastikan data karakter kamu sudah benar.\n\nNama: %s\nOrigin: %s\nGender: %s\nTanggal Lahir: %s\nAgama: %s\n\nData akan disimpan pada slot karakter.",
        name,
        origin,
        gender,
        dob,
        religion
    );

    CRP_HideCharacterCreateUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_CREATE_CONFIRM,
        DIALOG_STYLE_MSGBOX,
        "CRYSTAL ROLEPLAY | KONFIRMASI",
        confirm,
        "BUAT",
        "KEMBALI"
    );

    return 1;
}


// ============================================================
// REMOTE SHOW
// ============================================================

forward CRP_ShowCharacterCreationUIRemote(
    playerid
);

public CRP_ShowCharacterCreationUIRemote(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    CRP_ShowCharacterCreateUI(
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER CLICK
// ============================================================

public OnPlayerClickPlayerTextDraw(
    playerid,
    PlayerText:playertextid
)
{
    if (
        playertextid
        == gCreateTD[playerid][TD_NAME]
    )
    {
        CRP_ShowCreateNameDialog(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_ORIGIN]
    )
    {
        CRP_ShowCreateOriginDialog(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_GENDER]
    )
    {
        CRP_ShowCreateGenderDialog(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_DOB]
    )
    {
        CRP_ShowCreateDOBDialog(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_RELIGION]
    )
    {
        CRP_ShowCreateReligionDialog(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_CONFIRM]
    )
    {
        CRP_ShowCreateConfirmation(playerid);
        return 1;
    }

    if (
        playertextid
        == gCreateTD[playerid][TD_CANCEL]
    )
    {
        CRP_HideCharacterCreateUI(playerid);

        CallRemoteFunction(
            "CRP_CancelCharacterCreation",
            "d",
            playerid
        );

        return 1;
    }

    return 0;
}


// ============================================================
// DIALOG RESPONSE
// ============================================================

public OnDialogResponse(
    playerid,
    dialogid,
    response,
    listitem,
    inputtext[]
)
{
    // ========================================================
    // NAME
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_NAME
    )
    {
        if (!response)
        {
            CallRemoteFunction(
                "CRP_CancelCharacterCreation",
                "d",
                playerid
            );

            return 1;
        }

        if (
            !CallRemoteFunction(
                "CRP_CreateName",
                "ds",
                playerid,
                inputtext
            )
        )
        {
            CRP_ShowCreateNameDialog(playerid);
            return 1;
        }

        CRP_ShowCharacterCreateUI(playerid);
        return 1;
    }


    // ========================================================
    // ORIGIN
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_ORIGIN
    )
    {
        if (!response)
        {
            CallRemoteFunction(
                "CRP_CancelCharacterCreation",
                "d",
                playerid
            );

            return 1;
        }

        if (
            !CallRemoteFunction(
                "CRP_CreateOrigin",
                "ds",
                playerid,
                inputtext
            )
        )
        {
            CRP_ShowCreateOriginDialog(playerid);
            return 1;
        }

        CRP_ShowCharacterCreateUI(playerid);
        return 1;
    }


    // ========================================================
    // GENDER
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_GENDER
    )
    {
        if (!response)
        {
            CallRemoteFunction(
                "CRP_CancelCharacterCreation",
                "d",
                playerid
            );

            return 1;
        }

        if (
            !CallRemoteFunction(
                "CRP_CreateGender",
                "dd",
                playerid,
                listitem
            )
        )
        {
            return 1;
        }

        CRP_ShowCharacterCreateUI(playerid);
        return 1;
    }


    // ========================================================
    // DOB
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_DOB
    )
    {
        if (!response)
        {
            CallRemoteFunction(
                "CRP_CancelCharacterCreation",
                "d",
                playerid
            );

            return 1;
        }

        if (
            !CallRemoteFunction(
                "CRP_CreateDOB",
                "ds",
                playerid,
                inputtext
            )
        )
        {
            CRP_ShowCreateDOBDialog(playerid);
            return 1;
        }

        CRP_ShowCharacterCreateUI(playerid);
        return 1;
    }


    // ========================================================
    // RELIGION
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_RELIGION
    )
    {
        if (!response)
        {
            CallRemoteFunction(
                "CRP_CancelCharacterCreation",
                "d",
                playerid
            );

            return 1;
        }

        if (
            !CallRemoteFunction(
                "CRP_CreateReligion",
                "dd",
                playerid,
                listitem
            )
        )
        {
            return 1;
        }

        CRP_ShowCharacterCreateUI(playerid);
        return 1;
    }


    // ========================================================
    // CONFIRM
    // ========================================================

    if (
        dialogid
        == DIALOG_CREATE_CONFIRM
    )
    {
        if (!response)
        {
            CRP_ShowCreateReligionDialog(playerid);
            return 1;
        }

        CRP_HideCharacterCreateUI(playerid);

        CallRemoteFunction(
            "CRP_SaveCreatedCharacter",
            "d",
            playerid
        );

        return 1;
    }

    return 0;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(
    playerid
)
{
    CRP_CreateCharacterCreateTextDraw(
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
    for (
        new i = 0;
        i < CREATE_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawDestroy(
            playerid,
            gCreateTD[playerid][i]
        );
    }

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Character Creation TextDraw v0.2");
    print(" Character Creation UI Loaded");
    print(" Dialog Input Integration Loaded");
    print(" Remote Logic Interface Loaded");
    print(" Remote Getter Format Validated");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP CHARACTER CREATE TD] UI unloaded."
    );

    return 1;
}