#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Login System v0.2
//
// Fungsi:
// - Login account
// - Verifikasi password melalui Storage
// - Maksimal 3x kesalahan password
// - Login berhasil -> Character Slot
// - Login TextDraw Integration
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

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33
#define COLOR_YELLOW    0xFFFF00
#define COLOR_RED       0xFF3333
#define COLOR_GREY      0xAAAAAA

#define LOGIN_STATE_NONE        0
#define LOGIN_STATE_PASSWORD    1
#define LOGIN_STATE_SUCCESS     2

#define LOGIN_MAX_ERRORS        3
#define LOGIN_PASSWORD_MIN      1
#define LOGIN_PASSWORD_MAX      64

#define DIALOG_LOGIN_PASSWORD   2300

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
// RESET LOGIN
// ============================================================

stock CRP_ResetLogin(
    playerid
)
{
    gLoginState[playerid] =
        LOGIN_STATE_NONE;

    gLoginErrorCount[playerid] =
        0;

    return 1;
}


// ============================================================
// START LOGIN
// ============================================================

forward CRP_StartLogin(
    playerid
);

public CRP_StartLogin(
    playerid
)
{
    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }


    CRP_ResetLogin(
        playerid
    );


    gLoginState[playerid] =
        LOGIN_STATE_PASSWORD;


    // ========================================================
    // TAMPILKAN LOGIN TEXTDRAW
    // ========================================================

    CallRemoteFunction(
        "CRP_ShowLoginUIRemote",
        "d",
        playerid
    );


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


    if (
        gLoginState[playerid]
        != LOGIN_STATE_PASSWORD
    )
    {
        return 0;
    }


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


            CRP_ResetLogin(
                playerid
            );


            Kick(
                playerid
            );

            return 0;
        }


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


    // --------------------------------------------------------
    // PASSWORD BENAR
    // --------------------------------------------------------

    gLoginState[playerid] =
        LOGIN_STATE_SUCCESS;


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
    // KELUAR
    // --------------------------------------------------------

    if (!response)
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP LOGIN] Login dibatalkan."
        );


        CRP_ResetLogin(
            playerid
        );


        Kick(
            playerid
        );


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

public OnPlayerConnect(
    playerid
)
{
    CRP_ResetLogin(
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
    CRP_ResetLogin(
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
    print(" CRP Login System v0.2");
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