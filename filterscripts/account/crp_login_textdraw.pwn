#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Login TextDraw System v0.2
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - UI Login
// - Menampilkan username player
// - Tombol LOGIN
// - Tombol KELUAR
// - Dialog Password
// - Sinkronisasi dengan Login System v0.3
//
// Logic:
// crp_login.pwn
//
// Storage:
// crp_storage.pwn
//
// Komunikasi antar Filterscript:
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

#define DIALOG_LOGIN_PASSWORD    2300


// ============================================================
// PLAYER TEXTDRAW
// ============================================================

#define TD_BACKGROUND            0
#define TD_TITLE                 1
#define TD_BODY                  2
#define TD_USERNAME              3
#define TD_INFO                  4
#define TD_BUTTON_LOGIN          5
#define TD_BUTTON_CANCEL         6

#define LOGIN_TD_COUNT           7


// ============================================================
// PLAYER TEXTDRAW DATA
// ============================================================

new PlayerText:gLoginTD[MAX_PLAYERS][LOGIN_TD_COUNT];


// ============================================================
// LOGIN LOGIC
// ============================================================

forward CRP_StartLogin(playerid);

forward CRP_LoginPassword(
    playerid,
    password[]
);


// ============================================================
// SHOW LOGIN UI REMOTE
// ============================================================

forward CRP_ShowLoginUIRemote(playerid);

public CRP_ShowLoginUIRemote(playerid)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    return CRP_ShowLoginUI(playerid);
}


// ============================================================
// CREATE LOGIN TEXTDRAW
// ============================================================

stock CRP_CreateLoginTextDraw(playerid)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    new name[MAX_PLAYER_NAME];
    new username[64];

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        username,
        sizeof(username),
        "USERNAME: %s",
        name
    );


    // ========================================================
    // BACKGROUND
    // ========================================================

    gLoginTD[playerid][TD_BACKGROUND] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            215.0,
            "_"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        0.0,
        15.0
    );

    PlayerTextDrawTextSize(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        0.0,
        430.0
    );

    PlayerTextDrawUseBox(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        0x111111EE
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        2
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_BACKGROUND],
        1
    );


    // ========================================================
    // TITLE
    // ========================================================

    gLoginTD[playerid][TD_TITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            232.0,
            "CRYSTAL ROLEPLAY"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_TITLE],
        0.35,
        1.5
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_TITLE],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_TITLE],
        1
    );


    // ========================================================
    // BODY
    // ========================================================

    gLoginTD[playerid][TD_BODY] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            265.0,
            "Selamat datang kembali di Crystal Roleplay"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_BODY],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_BODY],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_BODY],
        COLOR_WHITE
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_BODY],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_BODY],
        1
    );


    // ========================================================
    // USERNAME
    // ========================================================

    gLoginTD[playerid][TD_USERNAME] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            292.0,
            username
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_USERNAME],
        0.25,
        1.2
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_USERNAME],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_USERNAME],
        COLOR_GREY
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_USERNAME],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_USERNAME],
        1
    );


    // ========================================================
    // INFO
    // ========================================================

    gLoginTD[playerid][TD_INFO] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            318.0,
            "Account ditemukan. Silakan login untuk melanjutkan."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_INFO],
        0.20,
        1.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_INFO],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_INFO],
        COLOR_GREY
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_INFO],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_INFO],
        1
    );


    // ========================================================
    // LOGIN BUTTON
    // ========================================================

    gLoginTD[playerid][TD_BUTTON_LOGIN] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            350.0,
            "[ LOGIN ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        0.28,
        1.3
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        COLOR_GREEN
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gLoginTD[playerid][TD_BUTTON_LOGIN],
        1
    );


    // ========================================================
    // CANCEL BUTTON
    // ========================================================

    gLoginTD[playerid][TD_BUTTON_CANCEL] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            380.0,
            "[ KELUAR ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        0.28,
        1.3
    );

    PlayerTextDrawAlignment(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        COLOR_RED
    );

    PlayerTextDrawFont(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        2
    );

    PlayerTextDrawSetProportional(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gLoginTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    return 1;
}


// ============================================================
// SHOW LOGIN UI
// ============================================================

stock CRP_ShowLoginUI(playerid)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    for (
        new i = 0;
        i < LOGIN_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawShow(
            playerid,
            gLoginTD[playerid][i]
        );
    }

    SelectTextDraw(
        playerid,
        COLOR_WHITE
    );

    return 1;
}


// ============================================================
// HIDE LOGIN UI
// ============================================================

stock CRP_HideLoginUI(playerid)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    for (
        new i = 0;
        i < LOGIN_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawHide(
            playerid,
            gLoginTD[playerid][i]
        );
    }

    CancelSelectTextDraw(playerid);

    return 1;
}


// ============================================================
// SHOW PASSWORD DIALOG
// ============================================================

stock CRP_ShowLoginPassword(playerid)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    CRP_HideLoginUI(playerid);

    ShowPlayerDialog(
        playerid,
        DIALOG_LOGIN_PASSWORD,
        DIALOG_STYLE_PASSWORD,
        "CRYSTAL ROLEPLAY | LOGIN",
        "Masukkan password account kamu.\n\nPassword diperlukan untuk melanjutkan ke Character Selection.",
        "LOGIN",
        "KELUAR"
    );

    return 1;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    CRP_CreateLoginTextDraw(playerid);

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
        i < LOGIN_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawDestroy(
            playerid,
            gLoginTD[playerid][i]
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
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // LOGIN
    // --------------------------------------------------------

    if (
        playertextid
        == gLoginTD[playerid][TD_BUTTON_LOGIN]
    )
    {
        return CRP_ShowLoginPassword(playerid);
    }


    // --------------------------------------------------------
    // KELUAR
    // --------------------------------------------------------

    if (
        playertextid
        == gLoginTD[playerid][TD_BUTTON_CANCEL]
    )
    {
        CancelSelectTextDraw(playerid);

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP LOGIN] Login dibatalkan."
        );

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
    if (
        dialogid
        != DIALOG_LOGIN_PASSWORD
    )
    {
        return 0;
    }

    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // KELUAR
    // --------------------------------------------------------

    if (!response)
    {
        CRP_ShowLoginUI(playerid);

        return 1;
    }


    // --------------------------------------------------------
    // PASSWORD
    // --------------------------------------------------------

    CRP_LoginPassword(
        playerid,
        inputtext
    );

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Login TextDraw System v0.2");
    print(" Login UI Loaded");
    print(" Password Dialog Integration Loaded");
    print(" Remote Interface Connected");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP LOGIN TD] Login TextDraw unloaded."
    );

    return 1;
}