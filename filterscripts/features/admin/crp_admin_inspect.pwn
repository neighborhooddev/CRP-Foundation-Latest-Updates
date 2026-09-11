#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin Inspect Backend v1.0
//
// File      : filterscripts/features/admin/crp_admin_inspect.pwn
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fokus v1.0:
// - Backend /check
// - Backend /ainspect
// - Membaca Active Character
// - Membaca PRID
// - Membaca Character Identity
// - Membaca Character Profile
// - Membaca Last IP
// - Membaca Last Login
// - Membaca Last Logout
//
// Dependency:
// - crp_character_activation.pwn
// - crp_admin.pwn
// - crp_admin_cmd.pwn
//
// CATATAN:
// - File ini TIDAK menangani permission admin.
// - Permission R2+ dan On-Duty tetap berada di crp_admin_cmd.pwn.
// - File ini TIDAK membuat Storage API baru.
// - File ini hanya membaca API Character Activation yang sudah ada.
// - Tidak ada MySQL.
// - Tidak ada perubahan Character data.
// ============================================================


// ============================================================
// COLORS
// ============================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_RED       0xFF3333FF
#define COLOR_GREY      0xAAAAAAFF
#define COLOR_GOLD      0xD8B56AFF
#define COLOR_EMERALD   0x09261FFF


// ============================================================
// CHARACTER ACTIVATION REMOTE
// ============================================================

forward CRP_IsCharacterActiveRemote(
    playerid
);

forward CRP_GetActiveCharacterSlotRemote(
    playerid
);

forward CRP_GetActiveCharacterPRIDRemote(
    playerid
);

forward CRP_GetActiveCharacterNameRemote(
    playerid,
    name[],
    size
);

forward CRP_GetActiveCharacterLevelRemote(
    playerid
);

forward CRP_GetActiveCharacterOriginRemote(
    playerid,
    origin[],
    size
);

forward CRP_GetActiveCharacterGenderRemote(
    playerid,
    gender[],
    size
);

forward CRP_GetActiveCharacterDOBRemote(
    playerid,
    dob[],
    size
);

forward CRP_GetActiveCharacterReligionRemote(
    playerid,
    religion[],
    size
);

forward CRP_GetActiveCharacterLastIPRemote(
    playerid,
    ip[],
    size
);

forward CRP_GetActiveCharacterLastLoginRemote(
    playerid,
    lastlogin[],
    size
);

forward CRP_GetActiveCharacterLastLogoutRemote(
    playerid,
    lastlogout[],
    size
);


// ============================================================
// ADMIN ACCOUNT IDENTITY REMOTE
//
// Foundation API:
// CRP_AdminGetAccountUsername
//
// Digunakan hanya untuk menampilkan identity admin
// yang menjalankan inspection.
// ============================================================

forward CRP_AdminGetAccountUsername(
    playerid,
    username[],
    size
);


// ============================================================
// TARGET VALIDATION
// ============================================================

stock CRP_AdminInspectIsValidTarget(
    targetid
)
{
    if (
        targetid < 0 ||
        targetid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (
        !IsPlayerConnected(targetid)
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// GET TARGET CHARACTER NAME
// ============================================================

stock CRP_AdminInspectGetCharacterName(
    targetid,
    name[],
    size
)
{
    name[0] = EOS;

    if (
        !CRP_AdminInspectIsValidTarget(targetid)
    )
    {
        return 0;
    }

    if (
        !CallRemoteFunction(
            "CRP_IsCharacterActiveRemote",
            "d",
            targetid
        )
    )
    {
        return 0;
    }

    if (
        !CallRemoteFunction(
            "CRP_GetActiveCharacterNameRemote",
            "dds",
            targetid,
            name,
            size
        )
    )
    {
        return 0;
    }

    if (
        name[0] == EOS
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// CHECK TARGET CHARACTER ACTIVE
// ============================================================

stock CRP_AdminInspectCheckActive(
    targetid
)
{
    if (
        !CRP_AdminInspectIsValidTarget(targetid)
    )
    {
        return 0;
    }

    if (
        !CallRemoteFunction(
            "CRP_IsCharacterActiveRemote",
            "d",
            targetid
        )
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// /CHECK BACKEND
//
// Tujuan:
// Menampilkan informasi ringkas Character aktif.
//
// Data:
// - Player ID
// - Character Name
// - PRID
// - Level
// - Origin
// - Gender
//
// Permission:
// Ditangani oleh crp_admin_cmd.pwn.
// ============================================================

stock CRP_AdminInspectCheck(
    adminid,
    targetid
)
{
    new charactername[25];
    new origin[64];
    new gender[16];

    new prid;
    new level;
    new slot;

    new message[144];

    // --------------------------------------------------------
    // VALIDATE ADMIN
    //
    // Backend tidak menentukan rank/duty.
    // Hanya memastikan actor valid.
    // --------------------------------------------------------

    if (
        adminid < 0 ||
        adminid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (
        !IsPlayerConnected(adminid)
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // VALIDATE TARGET
    // --------------------------------------------------------

    if (
        !CRP_AdminInspectIsValidTarget(targetid)
    )
    {
        SendClientMessage(
            adminid,
            COLOR_RED,
            "[CRP ADMIN] Target tidak valid atau tidak online."
        );

        return 0;
    }

    // --------------------------------------------------------
    // CHECK ACTIVE CHARACTER
    // --------------------------------------------------------

    if (
        !CRP_AdminInspectCheckActive(targetid)
    )
    {
        SendClientMessage(
            adminid,
            COLOR_YELLOW,
            "[CRP ADMIN] Target belum memiliki Character aktif."
        );

        return 0;
    }

    // --------------------------------------------------------
    // LOAD CHARACTER NAME
    // --------------------------------------------------------

    if (
        !CRP_AdminInspectGetCharacterName(
            targetid,
            charactername,
            sizeof(charactername)
        )
    )
    {
        SendClientMessage(
            adminid,
            COLOR_RED,
            "[CRP ADMIN] Gagal membaca Character target."
        );

        return 0;
    }

    // --------------------------------------------------------
    // LOAD PRID
    // --------------------------------------------------------

    prid = CallRemoteFunction(
        "CRP_GetActiveCharacterPRIDRemote",
        "d",
        targetid
    );

    if (
        prid <= 0
    )
    {
        SendClientMessage(
            adminid,
            COLOR_RED,
            "[CRP ADMIN] PRID Character tidak valid."
        );

        return 0;
    }

    // --------------------------------------------------------
    // LOAD LEVEL
    // --------------------------------------------------------

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        targetid
    );

    // --------------------------------------------------------
    // LOAD ORIGIN
    // --------------------------------------------------------

    origin[0] = EOS;

    CallRemoteFunction(
        "CRP_GetActiveCharacterOriginRemote",
        "dds",
        targetid,
        origin,
        sizeof(origin)
    );

    // --------------------------------------------------------
    // LOAD GENDER
    // --------------------------------------------------------

    gender[0] = EOS;

    CallRemoteFunction(
        "CRP_GetActiveCharacterGenderRemote",
        "dds",
        targetid,
        gender,
        sizeof(gender)
    );

    // --------------------------------------------------------
    // OUTPUT
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "[CRP CHECK] ID %d | Character: %s",
        targetid,
        charactername
    );

    SendClientMessage(
        adminid,
        COLOR_GOLD,
        message
    );

    format(
        message,
        sizeof(message),
        "[CRP CHECK] PRID: %03d | Level: %d | Slot: %d",
        prid,
        level,
        slot = CallRemoteFunction(
            "CRP_GetActiveCharacterSlotRemote",
            "d",
            targetid
        )
    );

    SendClientMessage(
        adminid,
        COLOR_WHITE,
        message
    );

    format(
        message,
        sizeof(message),
        "[CRP CHECK] Origin: %s | Gender: %s",
        origin[0] != EOS ? origin : "N/A",
        gender[0] != EOS ? gender : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    return 1;
}


// ============================================================
// /AINSPECT BACKEND
//
// Tujuan:
// Menampilkan informasi Character secara lebih lengkap.
//
// Data:
// - Player ID
// - Character Name
// - PRID
// - Slot
// - Level
// - Origin
// - Gender
// - DOB
// - Religion
// - Last IP
// - Last Login
// - Last Logout
//
// Permission:
// Ditangani oleh crp_admin_cmd.pwn.
// ============================================================

stock CRP_AdminInspectAInspect(
    adminid,
    targetid
)
{
    new charactername[25];
    new origin[64];
    new gender[16];
    new dob[16];
    new religion[24];
    new lastip[16];
    new lastlogin[32];
    new lastlogout[32];

    new prid;
    new level;
    new slot;

    new message[144];

    // --------------------------------------------------------
    // VALIDATE ADMIN
    // --------------------------------------------------------

    if (
        adminid < 0 ||
        adminid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (
        !IsPlayerConnected(adminid)
    )
    {
        return 0;
    }

    // --------------------------------------------------------
    // VALIDATE TARGET
    // --------------------------------------------------------

    if (
        !CRP_AdminInspectIsValidTarget(targetid)
    )
    {
        SendClientMessage(
            adminid,
            COLOR_RED,
            "[CRP ADMIN] Target tidak valid atau tidak online."
        );

        return 0;
    }

    // --------------------------------------------------------
    // CHECK ACTIVE CHARACTER
    // --------------------------------------------------------

    if (
        !CRP_AdminInspectCheckActive(targetid)
    )
    {
        SendClientMessage(
            adminid,
            COLOR_YELLOW,
            "[CRP ADMIN] Target belum memiliki Character aktif."
        );

        return 0;
    }

    // --------------------------------------------------------
    // INITIALIZE BUFFERS
    // --------------------------------------------------------

    charactername[0] = EOS;
    origin[0] = EOS;
    gender[0] = EOS;
    dob[0] = EOS;
    religion[0] = EOS;
    lastip[0] = EOS;
    lastlogin[0] = EOS;
    lastlogout[0] = EOS;

    // --------------------------------------------------------
    // LOAD BASIC IDENTITY
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_GetActiveCharacterNameRemote",
        "dds",
        targetid,
        charactername,
        sizeof(charactername)
    );

    prid = CallRemoteFunction(
        "CRP_GetActiveCharacterPRIDRemote",
        "d",
        targetid
    );

    slot = CallRemoteFunction(
        "CRP_GetActiveCharacterSlotRemote",
        "d",
        targetid
    );

    level = CallRemoteFunction(
        "CRP_GetActiveCharacterLevelRemote",
        "d",
        targetid
    );

    // --------------------------------------------------------
    // LOAD PROFILE
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_GetActiveCharacterOriginRemote",
        "dds",
        targetid,
        origin,
        sizeof(origin)
    );

    CallRemoteFunction(
        "CRP_GetActiveCharacterGenderRemote",
        "dds",
        targetid,
        gender,
        sizeof(gender)
    );

    CallRemoteFunction(
        "CRP_GetActiveCharacterDOBRemote",
        "dds",
        targetid,
        dob,
        sizeof(dob)
    );

    CallRemoteFunction(
        "CRP_GetActiveCharacterReligionRemote",
        "dds",
        targetid,
        religion,
        sizeof(religion)
    );

    // --------------------------------------------------------
    // LOAD SESSION INFORMATION
    // --------------------------------------------------------

    CallRemoteFunction(
        "CRP_GetActiveCharacterLastIPRemote",
        "dds",
        targetid,
        lastip,
        sizeof(lastip)
    );

    CallRemoteFunction(
        "CRP_GetActiveCharacterLastLoginRemote",
        "dds",
        targetid,
        lastlogin,
        sizeof(lastlogin)
    );

    CallRemoteFunction(
        "CRP_GetActiveCharacterLastLogoutRemote",
        "dds",
        targetid,
        lastlogout,
        sizeof(lastlogout)
    );

    // --------------------------------------------------------
    // HEADER
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "========== CRP ADMIN INSPECT | ID %d ==========",
        targetid
    );

    SendClientMessage(
        adminid,
        COLOR_GOLD,
        message
    );

    // --------------------------------------------------------
    // IDENTITY
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "Character : %s",
        charactername[0] != EOS ? charactername : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_WHITE,
        message
    );

    format(
        message,
        sizeof(message),
        "PRID      : %03d | Slot: %d | Level: %d",
        prid,
        slot,
        level
    );

    SendClientMessage(
        adminid,
        COLOR_WHITE,
        message
    );

    // --------------------------------------------------------
    // PROFILE
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "Origin    : %s",
        origin[0] != EOS ? origin : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    format(
        message,
        sizeof(message),
        "Gender    : %s | DOB: %s",
        gender[0] != EOS ? gender : "N/A",
        dob[0] != EOS ? dob : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    format(
        message,
        sizeof(message),
        "Religion  : %s",
        religion[0] != EOS ? religion : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    // --------------------------------------------------------
    // SESSION
    // --------------------------------------------------------

    format(
        message,
        sizeof(message),
        "Last IP   : %s",
        lastip[0] != EOS ? lastip : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    format(
        message,
        sizeof(message),
        "Last Login: %s",
        lastlogin[0] != EOS ? lastlogin : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    format(
        message,
        sizeof(message),
        "Last Logout: %s",
        lastlogout[0] != EOS ? lastlogout : "N/A"
    );

    SendClientMessage(
        adminid,
        COLOR_GREY,
        message
    );

    // --------------------------------------------------------
    // FOOTER
    // --------------------------------------------------------

    SendClientMessage(
        adminid,
        COLOR_GOLD,
        "================================================"
    );

    return 1;
}


// ============================================================
// REMOTE: /CHECK
// ============================================================

forward CRP_AdminInspectCheckRemote(
    adminid,
    targetid
);

public CRP_AdminInspectCheckRemote(
    adminid,
    targetid
)
{
    return CRP_AdminInspectCheck(
        adminid,
        targetid
    );
}


// ============================================================
// REMOTE: /AINSPECT
// ============================================================

forward CRP_AdminInspectAInspectRemote(
    adminid,
    targetid
);

public CRP_AdminInspectAInspectRemote(
    adminid,
    targetid
)
{
    return CRP_AdminInspectAInspect(
        adminid,
        targetid
    );
}


// ============================================================
// FILTERSCRIPT INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Admin Inspect Backend v1.0");
    print(" /check Backend Loaded");
    print(" /ainspect Backend Loaded");
    print(" Character Activation API Connected");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP ADMIN INSPECT] Backend unloaded."
    );

    return 1;
}