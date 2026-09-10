#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Character TextDraw System v0.5
//
// Fungsi:
// - Menampilkan 5 slot karakter
// - Slot kosong  : "Buat Karakter"
// - Slot terisi  : Nama / Level / PRID / Last Login
// - Menangani klik slot
// - Memilih character slot
// - Terhubung dengan Character Slot System
// - Menampilkan PRID / PURI character
//
// Logic:
// crp_character_slot.pwn
//
// Storage:
// crp_storage.pwn
//
// Komunikasi antar Filterscript:
// CallRemoteFunction()
// ============================================================

#define COLOR_WHITE      0xFFFFFFFF
#define COLOR_GREY       0xAAAAAA
#define COLOR_GREEN      0x33AA33
#define COLOR_YELLOW     0xFFFF00
#define COLOR_RED        0xFF3333

#define CHARACTER_SLOT_COUNT 5


// ============================================================
// TEXTDRAW ID
// ============================================================

#define TD_CHAR_BACKGROUND     0
#define TD_CHAR_TITLE          1
#define TD_CHAR_SUBTITLE       2

#define TD_SLOT_1              3
#define TD_SLOT_2              4
#define TD_SLOT_3              5
#define TD_SLOT_4              6
#define TD_SLOT_5              7

#define TD_SLOT_INFO_1         8
#define TD_SLOT_INFO_2         9
#define TD_SLOT_INFO_3         10
#define TD_SLOT_INFO_4         11
#define TD_SLOT_INFO_5         12

#define TD_BUTTON_SELECT       13
#define TD_BUTTON_EXIT         14

#define CHARACTER_TD_COUNT     15


// ============================================================
// PLAYER TEXTDRAW
// ============================================================

new PlayerText:gCharacterTD
    [MAX_PLAYERS]
    [CHARACTER_TD_COUNT];


// ============================================================
// REMOTE CHARACTER FUNCTIONS
// ============================================================

forward CRP_GetCharacterSlotData(
    playerid,
    slot
);

forward CRP_GetCharacterSlotName(
    playerid,
    slot,
    name[],
    size
);

forward CRP_GetCharacterSlotLevel(
    playerid,
    slot
);

// ------------------------------------------------------------
// PRID REMOTE
// ------------------------------------------------------------

forward CRP_GetCharacterSlotPRIDRemote(
    playerid,
    slot
);

forward CRP_GetCharacterSlotLastLogin(
    playerid,
    slot,
    lastlogin[],
    size
);

forward CRP_SelectCharacterSlotRemote(
    playerid,
    slot
);

forward CRP_GetSelectedCharacterSlotRemote(
    playerid
);

forward CRP_CharacterSlotConfirmed(
    playerid,
    slot
);


// ============================================================
// CREATE CHARACTER TEXTDRAW
// ============================================================

stock CRP_CreateCharacterTextDraw(
    playerid
)
{
    // --------------------------------------------------------
    // BACKGROUND
    // --------------------------------------------------------

    gCharacterTD[playerid][TD_CHAR_BACKGROUND] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            180.0,
            "_"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        0.0,
        25.0
    );

    PlayerTextDrawTextSize(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        0.0,
        450.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        2
    );

    PlayerTextDrawUseBox(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        0x111111EE
    );

    PlayerTextDrawFont(
        playerid,
        gCharacterTD[playerid][TD_CHAR_BACKGROUND],
        1
    );


    // --------------------------------------------------------
    // TITLE
    // --------------------------------------------------------

    gCharacterTD[playerid][TD_CHAR_TITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            195.0,
            "CRYSTAL ROLEPLAY"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCharacterTD[playerid][TD_CHAR_TITLE],
        0.35,
        1.4
    );

    PlayerTextDrawAlignment(
        playerid,
        gCharacterTD[playerid][TD_CHAR_TITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCharacterTD[playerid][TD_CHAR_TITLE],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gCharacterTD[playerid][TD_CHAR_TITLE],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCharacterTD[playerid][TD_CHAR_TITLE],
        1
    );


    // --------------------------------------------------------
    // SUBTITLE
    // --------------------------------------------------------

    gCharacterTD[playerid][TD_CHAR_SUBTITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            220.0,
            "PILIH KARAKTER"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCharacterTD[playerid][TD_CHAR_SUBTITLE],
        0.22,
        1.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gCharacterTD[playerid][TD_CHAR_SUBTITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCharacterTD[playerid][TD_CHAR_SUBTITLE],
        COLOR_GREY
    );

    PlayerTextDrawFont(
        playerid,
        gCharacterTD[playerid][TD_CHAR_SUBTITLE],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCharacterTD[playerid][TD_CHAR_SUBTITLE],
        1
    );


    // --------------------------------------------------------
    // SLOT POSITION
    // --------------------------------------------------------

    new Float:slotY[CHARACTER_SLOT_COUNT];

    slotY[0] = 250.0;
    slotY[1] = 295.0;
    slotY[2] = 340.0;
    slotY[3] = 385.0;
    slotY[4] = 430.0;


    // --------------------------------------------------------
    // CREATE 5 SLOT
    // --------------------------------------------------------

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        new tdid;

        tdid =
            TD_SLOT_1 + slot;


        // ----------------------------------------------------
        // SLOT HEADER
        // ----------------------------------------------------

        gCharacterTD[playerid][tdid] =
            CreatePlayerTextDraw(
                playerid,
                320.0,
                slotY[slot],
                "SLOT 1"
            );

        PlayerTextDrawLetterSize(
            playerid,
            gCharacterTD[playerid][tdid],
            0.25,
            1.2
        );

        PlayerTextDrawAlignment(
            playerid,
            gCharacterTD[playerid][tdid],
            2
        );

        PlayerTextDrawColor(
            playerid,
            gCharacterTD[playerid][tdid],
            COLOR_WHITE
        );

        PlayerTextDrawFont(
            playerid,
            gCharacterTD[playerid][tdid],
            2
        );

        PlayerTextDrawSetProportional(
            playerid,
            gCharacterTD[playerid][tdid],
            1
        );

        PlayerTextDrawUseBox(
            playerid,
            gCharacterTD[playerid][tdid],
            1
        );

        PlayerTextDrawBoxColor(
            playerid,
            gCharacterTD[playerid][tdid],
            0x222222EE
        );

        PlayerTextDrawTextSize(
            playerid,
            gCharacterTD[playerid][tdid],
            440.0,
            30.0
        );

        PlayerTextDrawSetSelectable(
            playerid,
            gCharacterTD[playerid][tdid],
            1
        );


        // ----------------------------------------------------
        // SLOT INFORMATION
        // ----------------------------------------------------

        gCharacterTD[playerid]
            [TD_SLOT_INFO_1 + slot] =
            CreatePlayerTextDraw(
                playerid,
                320.0,
                slotY[slot] + 15.0,
                "Buat Karakter"
            );

        PlayerTextDrawLetterSize(
            playerid,
            gCharacterTD[playerid]
                [TD_SLOT_INFO_1 + slot],
            0.20,
            0.9
        );

        PlayerTextDrawAlignment(
            playerid,
            gCharacterTD[playerid]
                [TD_SLOT_INFO_1 + slot],
            2
        );

        PlayerTextDrawColor(
            playerid,
            gCharacterTD[playerid]
                [TD_SLOT_INFO_1 + slot],
            COLOR_GREY
        );

        PlayerTextDrawFont(
            playerid,
            gCharacterTD[playerid]
                [TD_SLOT_INFO_1 + slot],
            1
        );

        PlayerTextDrawSetProportional(
            playerid,
            gCharacterTD[playerid]
                [TD_SLOT_INFO_1 + slot],
            1
        );
    }


    // --------------------------------------------------------
    // BUTTON PILIH
    // --------------------------------------------------------

    gCharacterTD[playerid][TD_BUTTON_SELECT] =
        CreatePlayerTextDraw(
            playerid,
            270.0,
            470.0,
            "[ PILIH ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        0.23,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        COLOR_GREEN
    );

    PlayerTextDrawFont(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_SELECT],
        1
    );


    // --------------------------------------------------------
    // BUTTON EXIT
    // --------------------------------------------------------

    gCharacterTD[playerid][TD_BUTTON_EXIT] =
        CreatePlayerTextDraw(
            playerid,
            370.0,
            470.0,
            "[ KELUAR ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        0.23,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        COLOR_YELLOW
    );

    PlayerTextDrawFont(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gCharacterTD[playerid][TD_BUTTON_EXIT],
        1
    );

    return 1;
}


// ============================================================
// SHOW CHARACTER TEXTDRAW
// ============================================================

stock CRP_ShowCharacterTextDraw(
    playerid
)
{
    for (
        new i = 0;
        i < CHARACTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawShow(
            playerid,
            gCharacterTD[playerid][i]
        );
    }

    SelectTextDraw(
        playerid,
        COLOR_WHITE
    );

    return 1;
}


// ============================================================
// HIDE CHARACTER TEXTDRAW
// ============================================================

stock CRP_HideCharacterTextDraw(
    playerid
)
{
    for (
        new i = 0;
        i < CHARACTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawHide(
            playerid,
            gCharacterTD[playerid][i]
        );
    }

    CancelSelectTextDraw(
        playerid
    );

    return 1;
}


// ============================================================
// SET SLOT TEXT
// ============================================================

stock CRP_SetCharacterSlotText(
    playerid,
    slot,
    status,
    charactername[],
    level,
    prid,
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

    new tdid;
    new info[144];


    // --------------------------------------------------------
    // SLOT HEADER
    // --------------------------------------------------------

    tdid =
        TD_SLOT_1 + slot;

    format(
        info,
        sizeof(info),
        "SLOT %d",
        slot + 1
    );

    PlayerTextDrawSetString(
        playerid,
        gCharacterTD[playerid][tdid],
        info
    );


    // --------------------------------------------------------
    // SLOT CONTENT
    // --------------------------------------------------------

    if (status == 0)
    {
        format(
            info,
            sizeof(info),
            "Buat Karakter"
        );
    }
    else
    {
        format(
            info,
            sizeof(info),
            "%s | Level %d | PRID %03d | Last Login: %s",
            charactername,
            level,
            prid,
            lastlogin
        );
    }

    PlayerTextDrawSetString(
        playerid,
        gCharacterTD[playerid]
            [TD_SLOT_INFO_1 + slot],
        info
    );

    return 1;
}


// ============================================================
// REFRESH CHARACTER SLOTS
// ============================================================

stock CRP_RefreshCharacterSlots(
    playerid
)
{
    new status;
    new charactername[25];
    new lastlogin[32];
    new level;
    new prid;

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;
        prid = 0;


        // ----------------------------------------------------
        // GET STATUS
        // ----------------------------------------------------

        status = CallRemoteFunction(
            "CRP_GetCharacterSlotData",
            "dd",
            playerid,
            slot
        );


        // ----------------------------------------------------
        // GET CHARACTER DATA
        // ----------------------------------------------------

        if (status)
        {
            CallRemoteFunction(
                "CRP_GetCharacterSlotName",
                "ddsds",
                playerid,
                slot,
                charactername,
                sizeof(charactername)
            );

            level =
                CallRemoteFunction(
                    "CRP_GetCharacterSlotLevel",
                    "dd",
                    playerid,
                    slot
                );


            // ------------------------------------------------
            // PRID
            //
            // Penting:
            // Character Slot System mengekspos fungsi
            // remote dengan nama CRP_GetCharacterSlotPRIDRemote.
            // ------------------------------------------------

            prid =
                CallRemoteFunction(
                    "CRP_GetCharacterSlotPRIDRemote",
                    "dd",
                    playerid,
                    slot
                );


            CallRemoteFunction(
                "CRP_GetCharacterSlotLastLogin",
                "ddsds",
                playerid,
                slot,
                lastlogin,
                sizeof(lastlogin)
            );
        }


        // ----------------------------------------------------
        // APPLY TO TEXTDRAW
        // ----------------------------------------------------

        CRP_SetCharacterSlotText(
            playerid,
            slot,
            status,
            charactername,
            level,
            prid,
            lastlogin
        );
    }


    // --------------------------------------------------------
    // SHOW UI
    // --------------------------------------------------------

    CRP_ShowCharacterTextDraw(
        playerid
    );

    return 1;
}


// ============================================================
// SHOW CHARACTER SELECTION
//
// Dipanggil dari:
// - crp_register.pwn
// - crp_login.pwn
// - system character lainnya
// ============================================================

forward CRP_ShowCharacterSelectionRemote(
    playerid
);

public CRP_ShowCharacterSelectionRemote(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    CRP_RefreshCharacterSlots(
        playerid
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP CHARACTER] Character Selection berhasil dibuka."
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
    CRP_CreateCharacterTextDraw(
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
        i < CHARACTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawDestroy(
            playerid,
            gCharacterTD[playerid][i]
        );
    }

    return 1;
}


// ============================================================
// PLAYER CLICK TEXTDRAW
// ============================================================

public OnPlayerClickPlayerTextDraw(
    playerid,
    PlayerText:playertextid
)
{
    // --------------------------------------------------------
    // SLOT 1 - 5
    // --------------------------------------------------------

    for (
        new slot = 0;
        slot < CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        if (
            playertextid
            ==
            gCharacterTD[playerid]
                [TD_SLOT_1 + slot]
        )
        {
            CallRemoteFunction(
                "CRP_SelectCharacterSlotRemote",
                "dd",
                playerid,
                slot
            );

            new message[64];

            format(
                message,
                sizeof(message),
                "[CRP] Slot %d dipilih.",
                slot + 1
            );

            SendClientMessage(
                playerid,
                COLOR_WHITE,
                message
            );

            return 1;
        }
    }


    // --------------------------------------------------------
    // PILIH
    // --------------------------------------------------------

    if (
        playertextid
        ==
        gCharacterTD[playerid]
            [TD_BUTTON_SELECT]
    )
    {
        new selectedslot;

        selectedslot =
            CallRemoteFunction(
                "CRP_GetSelectedCharacterSlotRemote",
                "d",
                playerid
            );

        if (
            selectedslot < 0
        )
        {
            SendClientMessage(
                playerid,
                COLOR_YELLOW,
                "[CRP] Silakan pilih slot karakter terlebih dahulu."
            );

            return 1;
        }

        CallRemoteFunction(
            "CRP_CharacterSlotConfirmed",
            "dd",
            playerid,
            selectedslot
        );

        return 1;
    }


    // --------------------------------------------------------
    // KELUAR
    // --------------------------------------------------------

    if (
        playertextid
        ==
        gCharacterTD[playerid]
            [TD_BUTTON_EXIT]
    )
    {
        CancelSelectTextDraw(
            playerid
        );

        Kick(
            playerid
        );

        return 1;
    }

    return 0;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Character TextDraw System v0.5");
    print(" Character Selection UI Loaded");
    print(" Character Slot Data Connected");
    print(" PRID / PURI Display Connected");
    print(" PRID Remote Synchronization Fixed");
    print(" Remote Selection Interface Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP] Character TextDraw System unloaded."
    );

    return 1;
}
