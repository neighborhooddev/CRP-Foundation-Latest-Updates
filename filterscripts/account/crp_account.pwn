#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Account System v0.3
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - Mendeteksi username player
// - Mengecek account melalui Storage System
// - Menentukan status account
// - Mengarahkan player ke Register / Login
// - Menjadi router awal Account System
//
// Storage:
// filterscripts/storage/crp_storage.pwn
//
// Register:
// filterscripts/account/crp_register.pwn
//
// Login:
// filterscripts/account/crp_login.pwn
//
// Catatan:
// - Account System TIDAK menyimpan password.
// - Account System TIDAK menangani Character.
// - Account System hanya menangani routing awal.
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
// ACCOUNT STATUS
// ============================================================

#define ACCOUNT_STATUS_UNREGISTERED   0
#define ACCOUNT_STATUS_REGISTERED     1


// ============================================================
// PLAYER ACCOUNT STATE
// ============================================================

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
// PLAYER VALIDATION
// ============================================================

stock CRP_IsValidAccountPlayer(playerid)
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
// RESET ACCOUNT STATE
// ============================================================

stock CRP_ResetAccountState(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    gAccountStatus[playerid] =
        ACCOUNT_STATUS_UNREGISTERED;

    return 1;
}


// ============================================================
// GET ACCOUNT STATUS
// ============================================================

stock CRP_GetAccountStatus(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return ACCOUNT_STATUS_UNREGISTERED;
    }

    return gAccountStatus[playerid];
}


// ============================================================
// CHECK ACCOUNT
// ============================================================

stock CRP_CheckAccount(playerid)
{
    if (!CRP_IsValidAccountPlayer(playerid))
    {
        return ACCOUNT_STATUS_UNREGISTERED;
    }

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
    if (!CRP_IsValidAccountPlayer(playerid))
    {
        return 0;
    }

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
    if (!CRP_IsValidAccountPlayer(playerid))
    {
        return 0;
    }

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
// ACCOUNT ROUTER
// ============================================================

stock CRP_RouteAccount(playerid)
{
    if (!CRP_IsValidAccountPlayer(playerid))
    {
        return 0;
    }

    if (
        gAccountStatus[playerid]
        == ACCOUNT_STATUS_UNREGISTERED
    )
    {
        return CRP_OpenRegister(playerid);
    }

    if (
        gAccountStatus[playerid]
        == ACCOUNT_STATUS_REGISTERED
    )
    {
        return CRP_OpenLogin(playerid);
    }

    return 0;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    CRP_ResetAccountState(playerid);

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
    // CHECK ACCOUNT
    // --------------------------------------------------------

    CRP_CheckAccount(playerid);


    // --------------------------------------------------------
    // ROUTE ACCOUNT
    // --------------------------------------------------------

    CRP_RouteAccount(playerid);

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
    CRP_ResetAccountState(playerid);

    return 1;
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Account System v0.3");
    print(" Account Detection & Router");
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