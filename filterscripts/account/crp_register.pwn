#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Register System v0.5
//
// Fungsi:
// - Password 1/2
// - Password 2/2
// - Email 1/2
// - Email 2/2
// - Maksimal 3 kesalahan sinkronisasi
// - IP Registry
// - 1 IP hanya boleh membuat 1 UCP
// - Load 5 Character Slot setelah Register
// - Membuka Character Selection setelah Register
//
// UI:
// crp_register_textdraw.pwn
//
// Storage:
// crp_storage.pwn
//
// Character:
// crp_character_slot.pwn
//
// Character UI:
// crp_character_textdraw.pwn
//
// Komunikasi antar Filterscript:
// CallRemoteFunction()
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33
#define COLOR_YELLOW    0xFFFF00
#define COLOR_RED       0xFF3333
#define COLOR_GREY      0xAAAAAA


// ============================================================
// REGISTER STATE
// ============================================================

#define REGISTER_STATE_NONE          0
#define REGISTER_STATE_PASSWORD_1    1
#define REGISTER_STATE_PASSWORD_2    2
#define REGISTER_STATE_EMAIL_1       3
#define REGISTER_STATE_EMAIL_2       4
#define REGISTER_STATE_SUCCESS       5


// ============================================================
// REGISTER LIMIT
// ============================================================

#define REGISTER_MAX_ERRORS 3

#define REGISTER_PASSWORD_MIN 6
#define REGISTER_PASSWORD_MAX 64

#define REGISTER_EMAIL_MIN 5
#define REGISTER_EMAIL_MAX 64


// ============================================================
// STORAGE RETURN
// ============================================================

#define STORAGE_CREATE_FAILED        0
#define STORAGE_CREATE_SUCCESS       1
#define STORAGE_CREATE_IP_EXISTS     2


// ============================================================
// REGISTER DATA
// ============================================================

new gRegisterState[MAX_PLAYERS];

new gRegisterPassword[MAX_PLAYERS][65];

new gRegisterEmail[MAX_PLAYERS][65];

new gRegisterErrorCount[MAX_PLAYERS];


// ============================================================
// STORAGE REMOTE FUNCTION
// ============================================================

forward CRP_StorageCreateAccountRemote(
    playerid,
    password[],
    email[]
);


// ============================================================
// CHARACTER REMOTE FUNCTION
// ============================================================

forward CRP_LoadCharacterSlotsRemote(
    playerid
);

forward CRP_ShowCharacterSelectionRemote(
    playerid
);


// ============================================================
// REGISTER TEXTDRAW REMOTE FUNCTION
// ============================================================

forward CRP_ShowRegisterUIRemote(
    playerid
);


// ============================================================
// RESET REGISTER
// ============================================================

stock CRP_ResetRegister(
    playerid
)
{
    gRegisterState[playerid] =
        REGISTER_STATE_NONE;

    gRegisterPassword[playerid][0] =
        EOS;

    gRegisterEmail[playerid][0] =
        EOS;

    gRegisterErrorCount[playerid] =
        0;

    return 1;
}


// ============================================================
// START REGISTER
// ============================================================

forward CRP_StartRegister(
    playerid
);

public CRP_StartRegister(
    playerid
)
{
    CRP_ResetRegister(
        playerid
    );

    gRegisterState[playerid] =
        REGISTER_STATE_PASSWORD_1;


    // ========================================================
    // TAMPILKAN REGISTER TEXTDRAW
    // ========================================================

    CallRemoteFunction(
        "CRP_ShowRegisterUIRemote",
        "d",
        playerid
    );


    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP REGISTER] Silakan masukkan password kamu. Tahap 1/2."
    );

    return 1;
}


// ============================================================
// PASSWORD 1/2
// ============================================================

forward CRP_RegisterPassword1(
    playerid,
    password[]
);

public CRP_RegisterPassword1(
    playerid,
    password[]
)
{
    if (
        gRegisterState[playerid]
        != REGISTER_STATE_PASSWORD_1
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // MINIMUM PASSWORD
    // --------------------------------------------------------

    if (
        strlen(password)
        < REGISTER_PASSWORD_MIN
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Password minimal 6 karakter."
        );

        return 0;
    }

    // --------------------------------------------------------
    // MAXIMUM PASSWORD
    // --------------------------------------------------------

    if (
        strlen(password)
        > REGISTER_PASSWORD_MAX
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Password maksimal 64 karakter."
        );

        return 0;
    }

    // --------------------------------------------------------
    // SIMPAN PASSWORD
    // --------------------------------------------------------

    format(
        gRegisterPassword[playerid],
        65,
        "%s",
        password
    );

    gRegisterState[playerid] =
        REGISTER_STATE_PASSWORD_2;

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "[CRP REGISTER] Password tahap 1/2 berhasil disimpan."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP REGISTER] Silakan konfirmasi password kamu. Tahap 2/2."
    );

    return 1;
}


// ============================================================
// PASSWORD 2/2
// ============================================================

forward CRP_RegisterPassword2(
    playerid,
    password[]
);

public CRP_RegisterPassword2(
    playerid,
    password[]
)
{
    if (
        gRegisterState[playerid]
        != REGISTER_STATE_PASSWORD_2
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // CEK PASSWORD
    // --------------------------------------------------------

    if (
        strcmp(
            gRegisterPassword[playerid],
            password,
            false
        ) != 0
    )
    {
        gRegisterErrorCount[playerid]++;

        // ----------------------------------------------------
        // MAKSIMAL 3 KESALAHAN
        // ----------------------------------------------------

        if (
            gRegisterErrorCount[playerid]
            >= REGISTER_MAX_ERRORS
        )
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP REGISTER] Kamu gagal melakukan konfirmasi sebanyak 3 kali."
            );

            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP REGISTER] Silakan restart SA-MP untuk melakukan pendaftaran kembali."
            );

            Kick(
                playerid
            );

            return 0;
        }

        // ----------------------------------------------------
        // KEMBALI PASSWORD 1/2
        // ----------------------------------------------------

        gRegisterState[playerid] =
            REGISTER_STATE_PASSWORD_1;

        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Password kamu tidak sinkron dengan pengisian awal."
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP REGISTER] Kami akan mengembalikan kamu ke pengisian password awal - 1/2."
        );

        return 0;
    }

    // --------------------------------------------------------
    // PASSWORD BERHASIL
    // --------------------------------------------------------

    gRegisterState[playerid] =
        REGISTER_STATE_EMAIL_1;

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "[CRP REGISTER] Password berhasil dikonfirmasi."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP REGISTER] PENTING! Masukkan alamat email kamu. Tahap 1/2."
    );

    return 1;
}


// ============================================================
// EMAIL 1/2
// ============================================================

forward CRP_RegisterEmail1(
    playerid,
    email[]
);

public CRP_RegisterEmail1(
    playerid,
    email[]
)
{
    if (
        gRegisterState[playerid]
        != REGISTER_STATE_EMAIL_1
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // MINIMUM EMAIL
    // --------------------------------------------------------

    if (
        strlen(email)
        < REGISTER_EMAIL_MIN
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Alamat email tidak valid."
        );

        return 0;
    }

    // --------------------------------------------------------
    // MAXIMUM EMAIL
    // --------------------------------------------------------

    if (
        strlen(email)
        > REGISTER_EMAIL_MAX
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Alamat email terlalu panjang."
        );

        return 0;
    }

    // --------------------------------------------------------
    // SIMPAN EMAIL
    // --------------------------------------------------------

    format(
        gRegisterEmail[playerid],
        65,
        "%s",
        email
    );

    gRegisterState[playerid] =
        REGISTER_STATE_EMAIL_2;

    SendClientMessage(
        playerid,
        COLOR_WHITE,
        "[CRP REGISTER] Email tahap 1/2 berhasil disimpan."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "[CRP REGISTER] Silakan konfirmasi kembali alamat email kamu. Tahap 2/2."
    );

    return 1;
}


// ============================================================
// EMAIL 2/2
// ============================================================

forward CRP_RegisterEmail2(
    playerid,
    email[]
);

public CRP_RegisterEmail2(
    playerid,
    email[]
)
{
    if (
        gRegisterState[playerid]
        != REGISTER_STATE_EMAIL_2
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // CEK EMAIL
    // --------------------------------------------------------

    if (
        strcmp(
            gRegisterEmail[playerid],
            email,
            true
        ) != 0
    )
    {
        gRegisterErrorCount[playerid]++;

        // ----------------------------------------------------
        // MAKSIMAL 3 KESALAHAN
        // ----------------------------------------------------

        if (
            gRegisterErrorCount[playerid]
            >= REGISTER_MAX_ERRORS
        )
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP REGISTER] Kamu gagal melakukan konfirmasi sebanyak 3 kali."
            );

            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP REGISTER] Silakan restart SA-MP untuk melakukan pendaftaran kembali."
            );

            Kick(
                playerid
            );

            return 0;
        }

        // ----------------------------------------------------
        // KEMBALI EMAIL 1/2
        // ----------------------------------------------------

        gRegisterState[playerid] =
            REGISTER_STATE_EMAIL_1;

        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Alamat email kamu tidak sinkron dengan pengisian awal."
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP REGISTER] Kami akan mengembalikan kamu ke pengisian alamat email awal - 1/2."
        );

        return 0;
    }

    // --------------------------------------------------------
    // REGISTER BERHASIL
    // --------------------------------------------------------

    CRP_RegisterSuccess(
        playerid
    );

    return 1;
}


// ============================================================
// REGISTER SUCCESS
// ============================================================

forward CRP_RegisterSuccess(
    playerid
);

public CRP_RegisterSuccess(
    playerid
)
{
    new name[MAX_PLAYER_NAME];
    new message[144];
    new saved;

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );


    // ========================================================
    // BUAT ACCOUNT
    //
    // Storage:
    // 1. Cek username
    // 2. Cek IP Registry
    // 3. Membuat UCP
    // 4. Menyimpan RegisterIP
    // 5. Mencatat IP Registry
    //
    // Return:
    // 0 = gagal
    // 1 = berhasil
    // 2 = IP sudah digunakan
    // ========================================================

    saved = CallRemoteFunction(
        "CRP_StorageCreateAccountRemote",
        "dss",
        playerid,
        gRegisterPassword[playerid],
        gRegisterEmail[playerid]
    );


    // ========================================================
    // IP SUDAH TERDAFTAR
    // ========================================================

    if (
        saved
        == STORAGE_CREATE_IP_EXISTS
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "PERINGATAN!"
        );

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "Setiap pemain hanya wajib memiliki 1 User (Tidak lebih)."
        );

        SendClientMessage(
            playerid,
            COLOR_WHITE,
            "Silahkan login dengan User yang telah terdaftar."
        );

        CRP_ResetRegister(
            playerid
        );

        return 0;
    }


    // ========================================================
    // ACCOUNT GAGAL DIBUAT
    // ========================================================

    if (
        saved
        == STORAGE_CREATE_FAILED
    )
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Account gagal disimpan."
        );

        SendClientMessage(
            playerid,
            COLOR_RED,
            "[CRP REGISTER] Silakan hubungi administrator."
        );

        return 0;
    }


    // ========================================================
    // ACCOUNT BERHASIL
    // ========================================================

    gRegisterState[playerid] =
        REGISTER_STATE_SUCCESS;

    format(
        message,
        sizeof(message),
        "Selamat '%s' kamu berhasil bergabung dan telah terdaftar di Server Crystal Roleplay.",
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
        "Kami memberikan 5 slot karakter pada 1 user."
    );

    SendClientMessage(
        playerid,
        COLOR_YELLOW,
        "Data Character Slot sedang dimuat..."
    );


    // ========================================================
    // LOAD CHARACTER SLOT
    // ========================================================

    CallRemoteFunction(
        "CRP_LoadCharacterSlotsRemote",
        "d",
        playerid
    );


    // ========================================================
    // TAMPILKAN CHARACTER SELECTION
    // ========================================================

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
    CRP_ResetRegister(
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
    CRP_ResetRegister(
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
    print(" CRP Register System v0.5");
    print(" Password + Email Registration");
    print(" IP Registry Lock Enabled");
    print(" 1 IP = 1 UCP Registration");
    print(" Register TextDraw Integration Loaded");
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
        "[CRP REGISTER] Register System unloaded."
    );

    return 1;
}