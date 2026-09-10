#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Login System v0.3
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - Login account
// - Verifikasi password melalui Storage
// - Maksimal 3x kesalahan password
// - Login berhasil -> Character Slot
// - Login TextDraw Integration
// - Login State Management
//
// Storage:
// crp_storage.pwn
//
// Character:
// crp_character_slot.pwn
//
// UI:
// crp_login_textdraw.pwn
//
// Komunikasi:
// CallRemoteFunction()
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
// LOGIN STATE
// ============================================================

#define LOGIN_STATE_NONE        0
#define LOGIN_STATE_PASSWORD    1
#define LOGIN_STATE_SUCCESS     2


// ============================================================
// LOGIN CONFIGURATION
// ============================================================

#define LOGIN_MAX_ERRORS        3
#define LOGIN_PASSWORD_MIN      1
#define LOGIN_PASSWORD_MAX      64

#define DIALOG_LOGIN_PASSWORD   2300


// ============================================================
// PLAYER LOGIN DATA
// ============================================================

new gLoginState[MAX_PLAYERS];
new gLoginErrorCount[MAX_PLAYERS];


// ============================================================
// STORAGE
// ============================================================

forward CRP_StorageCheckPasswordRemote(
    playerid,
    password[]
);


// ============================================================
// LOGIN TEXTDRAW
// ============================================================

forward CRP_ShowLoginUIRemote(
    playerid
);


// ============================================================
// CHARACTER SLOT
// ============================================================

forward CRP_LoadCharacterSlotsRemote(
    playerid
);

forward CRP_ShowCharacterSelectionRemote(
    playerid
);


// ============================================================
// PLAYER VALIDATION
// ============================================================

stock CRP_IsValidLoginPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// RESET LOGIN
// ============================================================

stock CRP_ResetLogin(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    gLoginState[playerid] =
        LOGIN_STATE_NONE;

    gLoginErrorCount[playerid] =
        0;

    return 1;
}


// ============================================================
// GET LOGIN STATE
// ============================================================

stock CRP_GetLoginState(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return LOGIN_STATE_NONE;
    }

    return gLoginState[playerid];
}


// ============================================================
// GET LOGIN ERROR COUNT
// ============================================================

stock CRP_GetLoginErrorCount(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    return gLoginErrorCount[playerid];
}


// ============================================================
// CHECK WHETHER PLAYER HAS SUCCESSFULLY LOGGED IN
// ============================================================

stock CRP_IsPlayerLoggedIn(playerid)
{
    if (!CRP_IsValidLoginPlayer(playerid))
    {
        return 0;
    }

    if (
        gLoginState[playerid]
        != LOGIN_STATE_SUCCESS
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// START LOGIN
// ============================================================

forward CRP_StartLogin(playerid);

public CRP_StartLogin(playerid)
{
    if (!CRP_IsValidLoginPlayer(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // JIKA SUDAH LOGIN
    // --------------------------------------------------------

    if (
        gLoginState[playerid]
        == LOGIN_STATE_SUCCESS
    )
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP LOGIN] Account kamu sudah login."
        );

        return 1;
    }


    // --------------------------------------------------------
    // RESET SESSION LOGIN
    // --------------------------------------------------------

    CRP_ResetLogin(playerid);

    gLoginState[playerid] =
        LOGIN_STATE_PASSWORD;


    // --------------------------------------------------------
    // TAMPILKAN LOGIN TEXTDRAW
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_ShowLoginUIRemote",
        "d",
        playerid
    );


    // --------------------------------------------------------
    // MESSAGE
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP LOGIN] Account ditemukan."
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "[CRP LOGIN] Silakan klik LOGIN untuk melanjutkan."
    );

    return 1;
}


// ============================================================
// CHECK PASSWORD
// ============================================================

stock CRP_LoginPassword(
    playerid,
    password[]
)
{
    new verified;


    // --------------------------------------------------------
    // PLAYER VALIDATION
    // --------------------------------------------------------

    if (!CRP_IsValidLoginPlayer(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // LOGIN STATE VALIDATION
    // --------------------------------------------------------

    if (
        gLoginState[playerid]
        != LOGIN_STATE_PASSWORD
    )
    {
        return 0;
    }


    // --------------------------------------------------------
    // PASSWORD MINIMUM
    // --------------------------------------------------------

    if (
        strlen(password)
        < LOGIN_PASSWORD_MIN
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP LOGIN] Password tidak boleh kosong."
        );

        return 0;
    }


    // --------------------------------------------------------
    // PASSWORD MAXIMUM
    // --------------------------------------------------------

    if (
        strlen(password)
        > LOGIN_PASSWORD_MAX
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP LOGIN] Password terlalu panjang."
        );

        return 0;
    }


    // --------------------------------------------------------
    // VERIFIKASI PASSWORD KE STORAGE
    // --------------------------------------------------------

    verified = CallRemoteFunction(
        "CRP_StorageCheckPasswordRemote",
        "ds",
        playerid,
        password
    );


    // --------------------------------------------------------
    // PASSWORD SALAH
    // --------------------------------------------------------

    if (!verified)
    {
        gLoginErrorCount[playerid]++;


        // ----------------------------------------------------
        // BATAS 3 KALI
        // ----------------------------------------------------

        if (
            gLoginErrorCount[playerid]
            >= LOGIN_MAX_ERRORS
        )
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP LOGIN] Kamu telah gagal memasukkan password sebanyak 3 kali."
            );

            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP LOGIN] Silakan masuk kembali untuk mencoba lagi."
            );


            CRP_ResetLogin(playerid);

            Kick(playerid);

            return 0;
        }


        // ----------------------------------------------------
        // HITUNG KESEMPATAN
        // ----------------------------------------------------

        new remaining;
        new message[144];

        remaining =
            LOGIN_MAX_ERRORS
            - gLoginErrorCount[playerid];


        format(
            message,
            sizeof(message),
            "[CRP LOGIN] Password salah. Kesalahan %d/%d. Kesempatan tersisa: %d.",
            gLoginErrorCount[playerid],
            LOGIN_MAX_ERRORS,
            remaining
        );


        SendClientMessage(
            playerid,
            COLOR_RED,
            message
        );


        // ----------------------------------------------------
        // PASSWORD DIALOG ULANG
        // ----------------------------------------------------

        ShowPlayerDialog(
            playerid,
            DIALOG_LOGIN_PASSWORD,
            DIALOG_STYLE_PASSWORD,
            "CRYSTAL ROLEPLAY | LOGIN",
            "Password yang kamu masukkan salah.\n\nSilakan masukkan kembali password account kamu.",
            "LOGIN",
            "KELUAR"
        );

        return 0;
    }


    // ========================================================
    // PASSWORD BENAR
    // ========================================================

    gLoginState[playerid] =
        LOGIN_STATE_SUCCESS;


    // Reset counter setelah berhasil.
    gLoginErrorCount[playerid] = 0;


    // --------------------------------------------------------
    // MESSAGE
    // --------------------------------------------------------

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP LOGIN] Password benar."
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP LOGIN] Account berhasil login."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP LOGIN] Character Slot sedang dimuat..."
    );


    // --------------------------------------------------------
    // LOAD CHARACTER SLOT
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_LoadCharacterSlotsRemote",
        "d",
        playerid
    );


    // --------------------------------------------------------
    // TAMPILKAN CHARACTER SELECTION
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_ShowCharacterSelectionRemote",
        "d",
        playerid
    );


    return 1;
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


    // --------------------------------------------------------
    // PLAYER VALIDATION
    // --------------------------------------------------------

    if (!CRP_IsValidLoginPlayer(playerid))
    {
        return 0;
    }


    // --------------------------------------------------------
    // KELUAR
    // --------------------------------------------------------

    if (!response)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP LOGIN] Login dibatalkan."
        );


        CRP_ResetLogin(playerid);

        Kick(playerid);

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
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    CRP_ResetLogin(playerid);

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
    CRP_ResetLogin(playerid);

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Login System v0.3");
    print(" Account Password Verification Loaded");
    print(" Maximum Login Error: 3");
    print(" Login TextDraw Integration Loaded");
    print(" Character Slot Integration Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP LOGIN] Login System unloaded."
    );

    return 1;
}