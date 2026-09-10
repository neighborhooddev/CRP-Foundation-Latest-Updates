#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Account System v0.2
//
// Fungsi:
// - Mendeteksi username player
// - Mengecek account melalui Storage System
// - Mengarahkan player ke Register / Login
//
// Storage:
// filterscripts/storage/crp_storage.pwn
//
// Register:
// filterscripts/account/crp_register.pwn
//
// Login:
// filterscripts/account/crp_login.pwn
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33
#define COLOR_YELLOW    0xFFFF00
#define COLOR_RED       0xFF3333
#define COLOR_GREY      0xAAAAAA

#define ACCOUNT_STATUS_UNREGISTERED   0
#define ACCOUNT_STATUS_REGISTERED     1

new gAccountStatus[MAX_PLAYERS];


// ============================================================
// STORAGE INTERFACE
// ============================================================

forward CRP_StorageAccountExistsRemote(playerid);


// ============================================================
// REGISTER INTERFACE
// ============================================================

forward CRP_StartRegister(playerid);


// ============================================================
// LOGIN INTERFACE
// ============================================================

forward CRP_StartLogin(playerid);


// ============================================================
// CHECK ACCOUNT
// ============================================================

stock CRP_CheckAccount(playerid)
{
    new exists;

    exists = CallRemoteFunction(
        "CRP_StorageAccountExistsRemote",
        "d",
        playerid
    );

    if (exists)
    {
        gAccountStatus[playerid] =
            ACCOUNT_STATUS_REGISTERED;
    }
    else
    {
        gAccountStatus[playerid] =
            ACCOUNT_STATUS_UNREGISTERED;
    }

    return gAccountStatus[playerid];
}


// ============================================================
// OPEN REGISTER
// ============================================================

stock CRP_OpenRegister(playerid)
{
    new name[MAX_PLAYER_NAME];
    new message[144];

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        message,
        sizeof(message),
        "Selamat datang di Server Crystal Roleplay, kami mendeteksi username kamu '%s' belum terdaftar.",
        name
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Silakan melakukan Register untuk melanjutkan."
    );

    CallRemoteFunction(
        "CRP_StartRegister",
        "d",
        playerid
    );

    return 1;
}


// ============================================================
// OPEN LOGIN
// ============================================================

stock CRP_OpenLogin(playerid)
{
    new name[MAX_PLAYER_NAME];
    new message[144];

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        message,
        sizeof(message),
        "Selamat datang kembali, %s.",
        name
    );

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        message
    );

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "Account kamu telah ditemukan. Silakan Login untuk melanjutkan."
    );

    CallRemoteFunction(
        "CRP_StartLogin",
        "d",
        playerid
    );

    return 1;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    gAccountStatus[playerid] =
        ACCOUNT_STATUS_UNREGISTERED;

    new name[MAX_PLAYER_NAME];
    new message[144];

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        message,
        sizeof(message),
        "[CRP ACCOUNT] Username terdeteksi: %s",
        name
    );

    SendClientMessage(
        playerid,
        COLOR_GREY,
        message
    );

    // --------------------------------------------------------
    // CHECK STORAGE
    // --------------------------------------------------------

    CRP_CheckAccount(playerid);

    // --------------------------------------------------------
    // ROUTER
    // --------------------------------------------------------

    if (
        gAccountStatus[playerid]
        == ACCOUNT_STATUS_UNREGISTERED
    )
    {
        CRP_OpenRegister(playerid);
    }
    else
    {
        CRP_OpenLogin(playerid);
    }

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
    gAccountStatus[playerid] =
        ACCOUNT_STATUS_UNREGISTERED;

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Account System v0.2");
    print(" Storage Account Router");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP ACCOUNT] Account System unloaded."
    );

    return 1;
}