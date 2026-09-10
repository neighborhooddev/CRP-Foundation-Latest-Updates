#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Register TextDraw System v0.4
//
// Fungsi:
// - UI Register
// - Tombol REGISTER
// - Tombol BATAL
// - Dialog Password 1/2
// - Dialog Password 2/2
// - Dialog Email 1/2
// - Dialog Email 2/2
// - UI Register hanya ditampilkan ketika dipanggil
//
// Logic:
// crp_register.pwn
//
// Storage:
// crp_storage.pwn
//
// Komunikasi antar Filterscript:
// CallRemoteFunction()
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREY      0xAAAAAA
#define COLOR_GREEN     0x33AA33
#define COLOR_RED       0xFF3333
#define COLOR_YELLOW    0xFFFF00

// ============================================================
// DIALOG ID
// ============================================================

#define DIALOG_REGISTER_PASSWORD_1    2100
#define DIALOG_REGISTER_PASSWORD_2    2101
#define DIALOG_REGISTER_EMAIL_1       2102
#define DIALOG_REGISTER_EMAIL_2       2103

// ============================================================
// TEXTDRAW ID
// ============================================================

#define TD_BACKGROUND       0
#define TD_TITLE            1
#define TD_BODY             2
#define TD_INFO             3
#define TD_BUTTON_REGISTER  4
#define TD_BUTTON_CANCEL    5

#define REGISTER_TD_COUNT   6

new PlayerText:gRegisterTD[MAX_PLAYERS][REGISTER_TD_COUNT];


// ============================================================
// REGISTER REMOTE FUNCTION
// ============================================================

forward CRP_StartRegister(playerid);

forward CRP_RegisterPassword1(
    playerid,
    password[]
);

forward CRP_RegisterPassword2(
    playerid,
    password[]
);

forward CRP_RegisterEmail1(
    playerid,
    email[]
);

forward CRP_RegisterEmail2(
    playerid,
    email[]
);


// ============================================================
// CREATE TEXTDRAW
// ============================================================

stock CRP_CreateRegisterTextDraw(playerid)
{
    // --------------------------------------------------------
    // BACKGROUND
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_BACKGROUND] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            220.0,
            "_"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        0.0,
        14.0
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        0.0,
        430.0
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        0x111111EE
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        2
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_BACKGROUND],
        1
    );


    // --------------------------------------------------------
    // TITLE
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_TITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            235.0,
            "CRYSTAL ROLEPLAY"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_TITLE],
        0.35,
        1.5
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterTD[playerid][TD_TITLE],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterTD[playerid][TD_TITLE],
        1
    );


    // --------------------------------------------------------
    // BODY
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_BODY] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            270.0,
            "Selamat datang di Server Crystal Roleplay"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_BODY],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_BODY],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterTD[playerid][TD_BODY],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_BODY],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterTD[playerid][TD_BODY],
        1
    );


    // --------------------------------------------------------
    // INFO
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_INFO] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            295.0,
            "Username kamu belum terdaftar."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_INFO],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_INFO],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterTD[playerid][TD_INFO],
        COLOR_GREY
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_INFO],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterTD[playerid][TD_INFO],
        1
    );


    // --------------------------------------------------------
    // REGISTER BUTTON
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_BUTTON_REGISTER] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            335.0,
            "[  REGISTER  ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        0.28,
        1.3
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        COLOR_GREEN
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_REGISTER],
        1
    );


    // --------------------------------------------------------
    // CANCEL BUTTON
    // --------------------------------------------------------

    gRegisterTD[playerid][TD_BUTTON_CANCEL] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            365.0,
            "[  BATAL  ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        0.28,
        1.3
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        COLOR_RED
    );

    PlayerTextDrawFont(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    return 1;
}


// ============================================================
// SHOW UI
// ============================================================

stock CRP_ShowRegisterUI(playerid)
{
    for (
        new i = 0;
        i < REGISTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawShow(
            playerid,
            gRegisterTD[playerid][i]
        );
    }

    SelectTextDraw(
        playerid,
        COLOR_WHITE
    );

    return 1;
}


// ============================================================
// REMOTE SHOW UI
// ============================================================

forward CRP_ShowRegisterUIRemote(playerid);

public CRP_ShowRegisterUIRemote(playerid)
{
    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    CRP_ShowRegisterUI(playerid);

    return 1;
}


// ============================================================
// HIDE UI
// ============================================================

stock CRP_HideRegisterUI(playerid)
{
    for (
        new i = 0;
        i < REGISTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawHide(
            playerid,
            gRegisterTD[playerid][i]
        );
    }

    CancelSelectTextDraw(playerid);

    return 1;
}


// ============================================================
// PASSWORD 1
// ============================================================

stock CRP_ShowRegisterPassword1(playerid)
{
    CRP_HideRegisterUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTER_PASSWORD_1,
        DIALOG_STYLE_PASSWORD,
        "CRYSTAL ROLEPLAY | REGISTER",
        "Harap isi password untuk kamu 1/2.\n\nPassword minimal 6 karakter.",
        "Lanjut",
        "Batal"
    );

    return 1;
}


// ============================================================
// PASSWORD 2
// ============================================================

stock CRP_ShowRegisterPassword2(playerid)
{
    CRP_HideRegisterUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTER_PASSWORD_2,
        DIALOG_STYLE_PASSWORD,
        "CRYSTAL ROLEPLAY | REGISTER",
        "Kami perlu konfirmasi untuk password kamu 2/2.\n\nMasukkan kembali password yang sama.",
        "Konfirmasi",
        "Batal"
    );

    return 1;
}


// ============================================================
// EMAIL 1
// ============================================================

stock CRP_ShowRegisterEmail1(playerid)
{
    CRP_HideRegisterUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTER_EMAIL_1,
        DIALOG_STYLE_INPUT,
        "CRYSTAL ROLEPLAY | EMAIL",
        "PENTING!\n\nUntuk menjaga akun kamu tetap aman,\nkami perlu alamat email yang kamu gunakan.",
        "Lanjut",
        "Batal"
    );

    return 1;
}


// ============================================================
// EMAIL 2
// ============================================================

stock CRP_ShowRegisterEmail2(playerid)
{
    CRP_HideRegisterUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTER_EMAIL_2,
        DIALOG_STYLE_INPUT,
        "CRYSTAL ROLEPLAY | EMAIL",
        "Kami perlu konfirmasi ulang alamat email kamu.\n\nMasukkan kembali email yang sama.",
        "Konfirmasi",
        "Batal"
    );

    return 1;
}


// ============================================================
// CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    CRP_CreateRegisterTextDraw(playerid);

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
    for (
        new i = 0;
        i < REGISTER_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawDestroy(
            playerid,
            gRegisterTD[playerid][i]
        );
    }

    return 1;
}


// ============================================================
// PLAYER TEXTDRAW CLICK
// ============================================================

public OnPlayerClickPlayerTextDraw(
    playerid,
    PlayerText:playertextid
)
{
    if (
        playertextid
        == gRegisterTD[playerid][TD_BUTTON_REGISTER]
    )
    {
        CRP_ShowRegisterPassword1(playerid);

        return 1;
    }


    if (
        playertextid
        == gRegisterTD[playerid][TD_BUTTON_CANCEL]
    )
    {
        CancelSelectTextDraw(playerid);

        Kick(playerid);

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
    new result;


    // --------------------------------------------------------
    // PASSWORD 1
    // --------------------------------------------------------

    if (
        dialogid
        == DIALOG_REGISTER_PASSWORD_1
    )
    {
        if (!response)
        {
            CRP_ShowRegisterUI(playerid);

            return 1;
        }

        result = CallRemoteFunction(
            "CRP_RegisterPassword1",
            "ds",
            playerid,
            inputtext
        );

        if (!result)
        {
            CRP_ShowRegisterPassword1(playerid);

            return 1;
        }

        CRP_ShowRegisterPassword2(playerid);

        return 1;
    }


    // --------------------------------------------------------
    // PASSWORD 2
    // --------------------------------------------------------

    if (
        dialogid
        == DIALOG_REGISTER_PASSWORD_2
    )
    {
        if (!response)
        {
            CRP_ShowRegisterPassword1(playerid);

            return 1;
        }

        result = CallRemoteFunction(
            "CRP_RegisterPassword2",
            "ds",
            playerid,
            inputtext
        );

        if (!result)
        {
            CRP_ShowRegisterPassword1(playerid);

            return 1;
        }

        CRP_ShowRegisterEmail1(playerid);

        return 1;
    }


    // --------------------------------------------------------
    // EMAIL 1
    // --------------------------------------------------------

    if (
        dialogid
        == DIALOG_REGISTER_EMAIL_1
    )
    {
        if (!response)
        {
            CRP_ShowRegisterPassword1(playerid);

            return 1;
        }

        result = CallRemoteFunction(
            "CRP_RegisterEmail1",
            "ds",
            playerid,
            inputtext
        );

        if (!result)
        {
            CRP_ShowRegisterEmail1(playerid);

            return 1;
        }

        CRP_ShowRegisterEmail2(playerid);

        return 1;
    }


    // --------------------------------------------------------
    // EMAIL 2
    // --------------------------------------------------------

    if (
        dialogid
        == DIALOG_REGISTER_EMAIL_2
    )
    {
        if (!response)
        {
            CRP_ShowRegisterEmail1(playerid);

            return 1;
        }

        result = CallRemoteFunction(
            "CRP_RegisterEmail2",
            "ds",
            playerid,
            inputtext
        );

        if (!result)
        {
            CRP_ShowRegisterEmail1(playerid);

            return 1;
        }

        CRP_HideRegisterUI(playerid);

        return 1;
    }

    return 0;
}


// ============================================================
// INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Register TextDraw System v0.4");
    print(" Register UI Loaded");
    print(" Manual UI Trigger Enabled");
    print(" Remote Interface Connected");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP REGISTER TD] Register TextDraw unloaded."
    );

    return 1;
}