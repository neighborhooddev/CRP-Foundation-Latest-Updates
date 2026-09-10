#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Storage System v1.0
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fokus v1.0:
// - Account Storage
// - Account Registration
// - Account Login Verification
// - IP Registry
// - 5 Character Slots
// - Character Creation Storage
// - Character Basic Data
// - Character Full Data
// - Global PRID
// - Character Last Login
// - Character Last Logout
// - Remote API Contract
//
// Storage:
// scriptfiles/
// ├── accounts/
// │   └── Username.ini
// ├── ip_registry/
// │   └── ip_registry.ini
// └── registry/
//     ├── prid_counter.ini
//     └── characters/
//         └── 001.ini
//
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
// CONSTANT
// ============================================================

#define CRP_CHARACTER_SLOT_COUNT 5

#define CRP_ACCOUNT_FOLDER        "accounts"

#define CRP_IP_REGISTRY_FOLDER    "ip_registry"
#define CRP_IP_REGISTRY_FILE      "ip_registry/ip_registry.ini"

#define CRP_REGISTRY_FOLDER       "registry"
#define CRP_PRID_COUNTER_FILE     "registry/prid_counter.ini"
#define CRP_PRID_CHARACTER_FOLDER "registry/characters"


// ============================================================
// ACCOUNT CACHE
// ============================================================

new gStoragePassword[MAX_PLAYERS][65];
new gStorageEmail[MAX_PLAYERS][65];
new gStorageRegisterIP[MAX_PLAYERS][16];


// ============================================================
// CHARACTER CACHE
// ============================================================

new gStorageCharacterPRID[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT];

new gStorageCharacterName[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][25];

new gStorageCharacterLevel[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT];

new gStorageCharacterOrigin[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][64];

new gStorageCharacterGender[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][16];

new gStorageCharacterDOB[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][16];

new gStorageCharacterReligion[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][24];

new gStorageCharacterLastIP[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][16];

new gStorageCharacterLastLogin[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][32];

new gStorageCharacterLastLogout[MAX_PLAYERS]
    [CRP_CHARACTER_SLOT_COUNT][32];


// ============================================================
// PLAYER VALIDATION
// ============================================================

stock CRP_StorageIsValidPlayer(playerid)
{
    if (playerid < 0)
    {
        return 0;
    }

    if (playerid >= MAX_PLAYERS)
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
// SLOT VALIDATION
// ============================================================

stock CRP_StorageIsValidSlot(slot)
{
    if (slot < 0)
    {
        return 0;
    }

    if (slot >= CRP_CHARACTER_SLOT_COUNT)
    {
        return 0;
    }

    return 1;
}


// ============================================================
// RESET
// ============================================================

stock CRP_StorageReset(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    gStoragePassword[playerid][0] = EOS;
    gStorageEmail[playerid][0] = EOS;
    gStorageRegisterIP[playerid][0] = EOS;

    for (
        new slot = 0;
        slot < CRP_CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        gStorageCharacterPRID[playerid][slot] = 0;

        gStorageCharacterName[playerid][slot][0] = EOS;

        gStorageCharacterLevel[playerid][slot] = 0;

        gStorageCharacterOrigin[playerid][slot][0] = EOS;
        gStorageCharacterGender[playerid][slot][0] = EOS;
        gStorageCharacterDOB[playerid][slot][0] = EOS;
        gStorageCharacterReligion[playerid][slot][0] = EOS;

        gStorageCharacterLastIP[playerid][slot][0] = EOS;
        gStorageCharacterLastLogin[playerid][slot][0] = EOS;
        gStorageCharacterLastLogout[playerid][slot][0] = EOS;
    }

    return 1;
}


// ============================================================
// ACCOUNT FILE
// ============================================================

stock CRP_GetAccountFile(
    playerid,
    filepath[],
    size
)
{
    new name[MAX_PLAYER_NAME];

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        filepath[0] = EOS;
        return 0;
    }

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        filepath,
        size,
        CRP_ACCOUNT_FOLDER "/%s.ini",
        name
    );

    return 1;
}


// ============================================================
// PLAYER IP
// ============================================================

stock CRP_StorageGetPlayerIP(
    playerid,
    ip[],
    size
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        ip[0] = EOS;
        return 0;
    }

    GetPlayerIp(
        playerid,
        ip,
        size
    );

    return 1;
}


// ============================================================
// CURRENT DATETIME
// Format:
// DD/MM/YYYY HH:MM:SS
// ============================================================

stock CRP_StorageGetCurrentDateTime(
    output[],
    size
)
{
    new year;
    new month;
    new day;

    new hour;
    new minute;
    new second;

    getdate(
        year,
        month,
        day
    );

    gettime(
        hour,
        minute,
        second
    );

    format(
        output,
        size,
        "%02d/%02d/%04d %02d:%02d:%02d",
        day,
        month,
        year,
        hour,
        minute,
        second
    );

    return 1;
}


// ============================================================
// ACCOUNT EXISTS
// ============================================================

stock CRP_StorageAccountExists(playerid)
{
    new filepath[128];

    if (!CRP_GetAccountFile(
        playerid,
        filepath,
        sizeof(filepath)
    ))
    {
        return 0;
    }

    if (fexist(filepath))
    {
        return 1;
    }

    return 0;
}


// ============================================================
// IP REGISTRY CHECK
// ============================================================

stock CRP_StorageIPAlreadyRegistered(playerid)
{
    new ip[16];
    new line[144];

    new File:file;

    if (!CRP_StorageGetPlayerIP(
        playerid,
        ip,
        sizeof(ip)
    ))
    {
        return 0;
    }

    file = fopen(
        CRP_IP_REGISTRY_FILE,
        io_read
    );

    if (!file)
    {
        return 0;
    }

    while (fread(file, line))
    {
        if (
            !strcmp(
                line,
                ip,
                true,
                strlen(ip)
            )
        )
        {
            fclose(file);

            return 1;
        }
    }

    fclose(file);

    return 0;
}


// ============================================================
// REGISTER IP
// ============================================================

stock CRP_StorageRegisterIP(playerid)
{
    new ip[16];
    new name[MAX_PLAYER_NAME];

    new line[144];

    new File:file;

    if (!CRP_StorageGetPlayerIP(
        playerid,
        ip,
        sizeof(ip)
    ))
    {
        return 0;
    }

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    if (
        CRP_StorageIPAlreadyRegistered(
            playerid
        )
    )
    {
        return 0;
    }

    file = fopen(
        CRP_IP_REGISTRY_FILE,
        io_append
    );

    if (!file)
    {
        printf(
            "[CRP STORAGE] Gagal membuka IP Registry."
        );

        return 0;
    }

    format(
        line,
        sizeof(line),
        "%s=%s\r\n",
        ip,
        name
    );

    fwrite(
        file,
        line
    );

    fclose(file);

    printf(
        "[CRP STORAGE] IP Registry: %s -> %s",
        ip,
        name
    );

    return 1;
}


// ============================================================
// PRID GET NEXT
// ============================================================

stock CRP_PRID_GetNext()
{
    new File:file;
    new line[64];

    new nextprid = 1;

    file = fopen(
        CRP_PRID_COUNTER_FILE,
        io_read
    );

    if (!file)
    {
        return 1;
    }

    while (fread(file, line))
    {
        if (
            !strcmp(
                line,
                "NextPRID=",
                true,
                9
            )
        )
        {
            nextprid =
                strval(
                    line[9]
                );

            break;
        }
    }

    fclose(file);

    if (nextprid < 1)
    {
        nextprid = 1;
    }

    return nextprid;
}


// ============================================================
// PRID SAVE NEXT
// ============================================================

stock CRP_PRID_SaveNext(nextprid)
{
    new File:file;
    new line[64];

    file = fopen(
        CRP_PRID_COUNTER_FILE,
        io_write
    );

    if (!file)
    {
        printf(
            "[CRP STORAGE] Gagal menyimpan PRID Counter."
        );

        return 0;
    }

    format(
        line,
        sizeof(line),
        "NextPRID=%d\r\n",
        nextprid
    );

    fwrite(
        file,
        line
    );

    fclose(file);

    return 1;
}


// ============================================================
// GENERATE PRID
// ============================================================

stock CRP_PRID_Generate()
{
    new prid;
    new nextprid;

    prid =
        CRP_PRID_GetNext();

    if (prid < 1)
    {
        prid = 1;
    }

    nextprid =
        prid + 1;

    if (!CRP_PRID_SaveNext(
        nextprid
    ))
    {
        return 0;
    }

    printf(
        "[CRP STORAGE] PRID generated: %03d",
        prid
    );

    return prid;
}


// ============================================================
// FORMAT PRID
// ============================================================

stock CRP_PRID_Format(
    prid,
    output[],
    size
)
{
    format(
        output,
        size,
        "%03d",
        prid
    );

    return 1;
}


// ============================================================
// PRID CHARACTER FILE
// ============================================================

stock CRP_PRID_GetCharacterFile(
    prid,
    filepath[],
    size
)
{
    new pridtext[16];

    CRP_PRID_Format(
        prid,
        pridtext,
        sizeof(pridtext)
    );

    format(
        filepath,
        size,
        CRP_PRID_CHARACTER_FOLDER "/%s.ini",
        pridtext
    );

    return 1;
}


// ============================================================
// REGISTER CHARACTER TO PRID REGISTRY
// ============================================================

stock CRP_PRID_RegisterCharacter(
    playerid,
    slot,
    prid,
    charactername[]
)
{
    new accountname[MAX_PLAYER_NAME];

    new filepath[128];
    new line[256];
    new pridtext[16];

    new File:file;

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    if (prid <= 0)
    {
        return 0;
    }

    GetPlayerName(
        playerid,
        accountname,
        sizeof(accountname)
    );

    CRP_PRID_Format(
        prid,
        pridtext,
        sizeof(pridtext)
    );

    CRP_PRID_GetCharacterFile(
        prid,
        filepath,
        sizeof(filepath)
    );

    file = fopen(
        filepath,
        io_write
    );

    if (!file)
    {
        printf(
            "[CRP STORAGE] Gagal membuka Character Registry: %s",
            filepath
        );

        return 0;
    }

    format(
        line,
        sizeof(line),
        "PRID=%s\r\n",
        pridtext
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Character=%s\r\n",
        charactername
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Account=%s\r\n",
        accountname
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Slot=%d\r\n",
        slot + 1
    );

    fwrite(
        file,
        line
    );

    fclose(file);

    printf(
        "[CRP STORAGE] PRID Registry saved | PRID=%03d | Character=%s | Slot=%d",
        prid,
        charactername,
        slot + 1
    );

    return 1;
}


// ============================================================
// CREATE ACCOUNT
//
// Return:
// 0 = gagal
// 1 = berhasil
// 2 = IP sudah terdaftar
// ============================================================

stock CRP_StorageCreateAccount(
    playerid,
    password[],
    email[]
)
{
    new filepath[128];
    new line[256];

    new ip[16];
    new name[MAX_PLAYER_NAME];

    new File:file;

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (
        CRP_StorageAccountExists(
            playerid
        )
    )
    {
        return 0;
    }

    CRP_StorageGetPlayerIP(
        playerid,
        ip,
        sizeof(ip)
    );

    if (
        CRP_StorageIPAlreadyRegistered(
            playerid
        )
    )
    {
        return 2;
    }

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        gStoragePassword[playerid],
        65,
        "%s",
        password
    );

    format(
        gStorageEmail[playerid],
        65,
        "%s",
        email
    );

    format(
        gStorageRegisterIP[playerid],
        16,
        "%s",
        ip
    );

    CRP_GetAccountFile(
        playerid,
        filepath,
        sizeof(filepath)
    );

    file = fopen(
        filepath,
        io_write
    );

    if (!file)
    {
        printf(
            "[CRP STORAGE] Gagal membuat account: %s",
            filepath
        );

        return 0;
    }

    format(
        line,
        sizeof(line),
        "Username=%s\r\n",
        name
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Password=%s\r\n",
        password
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Email=%s\r\n",
        email
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "RegisterIP=%s\r\n",
        ip
    );

    fwrite(
        file,
        line
    );

    for (
        new slot = 0;
        slot < CRP_CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        format(
            line,
            sizeof(line),
            "Slot%d_PRID=0\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Name=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Level=0\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Origin=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Gender=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_DOB=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Religion=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastIP=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastLogin=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastLogout=\r\n",
            slot + 1
        );

        fwrite(
            file,
            line
        );
    }

    fclose(file);

    if (!CRP_StorageRegisterIP(
        playerid
    ))
    {
        printf(
            "[CRP STORAGE] WARNING: Account dibuat tetapi IP Registry gagal disimpan."
        );
    }

    printf(
        "[CRP STORAGE] Account created: %s",
        filepath
    );

    return 1;
}


// ============================================================
// SAVE ACCOUNT
// ============================================================

stock CRP_StorageSaveAccount(
    playerid
)
{
    new filepath[128];
    new line[256];
    new name[MAX_PLAYER_NAME];

    new File:file;

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    CRP_GetAccountFile(
        playerid,
        filepath,
        sizeof(filepath)
    );

    file = fopen(
        filepath,
        io_write
    );

    if (!file)
    {
        return 0;
    }

    GetPlayerName(
        playerid,
        name,
        sizeof(name)
    );

    format(
        line,
        sizeof(line),
        "Username=%s\r\n",
        name
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Password=%s\r\n",
        gStoragePassword[playerid]
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "Email=%s\r\n",
        gStorageEmail[playerid]
    );

    fwrite(
        file,
        line
    );

    format(
        line,
        sizeof(line),
        "RegisterIP=%s\r\n",
        gStorageRegisterIP[playerid]
    );

    fwrite(
        file,
        line
    );

    for (
        new slot = 0;
        slot < CRP_CHARACTER_SLOT_COUNT;
        slot++
    )
    {
        format(
            line,
            sizeof(line),
            "Slot%d_PRID=%d\r\n",
            slot + 1,
            gStorageCharacterPRID[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Name=%s\r\n",
            slot + 1,
            gStorageCharacterName[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Level=%d\r\n",
            slot + 1,
            gStorageCharacterLevel[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Origin=%s\r\n",
            slot + 1,
            gStorageCharacterOrigin[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Gender=%s\r\n",
            slot + 1,
            gStorageCharacterGender[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_DOB=%s\r\n",
            slot + 1,
            gStorageCharacterDOB[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_Religion=%s\r\n",
            slot + 1,
            gStorageCharacterReligion[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastIP=%s\r\n",
            slot + 1,
            gStorageCharacterLastIP[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastLogin=%s\r\n",
            slot + 1,
            gStorageCharacterLastLogin[playerid][slot]
        );

        fwrite(
            file,
            line
        );

        format(
            line,
            sizeof(line),
            "Slot%d_LastLogout=%s\r\n",
            slot + 1,
            gStorageCharacterLastLogout[playerid][slot]
        );

        fwrite(
            file,
            line
        );
    }

    fclose(file);

    return 1;
}


// ============================================================
// LOAD ACCOUNT
// ============================================================

stock CRP_StorageLoadAccount(
    playerid
)
{
    new filepath[128];
    new line[256];

    new File:file;

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageAccountExists(
        playerid
    ))
    {
        return 0;
    }

    CRP_GetAccountFile(
        playerid,
        filepath,
        sizeof(filepath)
    );

    file = fopen(
        filepath,
        io_read
    );

    if (!file)
    {
        return 0;
    }

    CRP_StorageReset(
        playerid
    );

    while (fread(
        file,
        line
    ))
    {
        if (
            !strcmp(
                line,
                "Password=",
                true,
                9
            )
        )
        {
            format(
                gStoragePassword[playerid],
                65,
                "%s",
                line[9]
            );

            continue;
        }

        if (
            !strcmp(
                line,
                "Email=",
                true,
                6
            )
        )
        {
            format(
                gStorageEmail[playerid],
                65,
                "%s",
                line[6]
            );

            continue;
        }

        if (
            !strcmp(
                line,
                "RegisterIP=",
                true,
                11
            )
        )
        {
            format(
                gStorageRegisterIP[playerid],
                16,
                "%s",
                line[11]
            );

            continue;
        }

        for (
            new slot = 0;
            slot < CRP_CHARACTER_SLOT_COUNT;
            slot++
        )
        {
            new slotnumber = slot + 1;

            new key[64];

            format(
                key,
                sizeof(key),
                "Slot%d_PRID=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                gStorageCharacterPRID[playerid][slot] =
                    strval(
                        line[strlen(key)]
                    );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_Name=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterName[playerid][slot],
                    25,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_Level=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                gStorageCharacterLevel[playerid][slot] =
                    strval(
                        line[strlen(key)]
                    );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_Origin=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterOrigin[playerid][slot],
                    64,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_Gender=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterGender[playerid][slot],
                    16,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_DOB=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterDOB[playerid][slot],
                    16,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_Religion=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterReligion[playerid][slot],
                    24,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_LastIP=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterLastIP[playerid][slot],
                    16,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_LastLogin=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterLastLogin[playerid][slot],
                    32,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }

            format(
                key,
                sizeof(key),
                "Slot%d_LastLogout=",
                slotnumber
            );

            if (
                !strcmp(
                    line,
                    key,
                    true,
                    strlen(key)
                )
            )
            {
                format(
                    gStorageCharacterLastLogout[playerid][slot],
                    32,
                    "%s",
                    line[strlen(key)]
                );

                break;
            }
        }
    }

    fclose(file);

    return 1;
}


// ============================================================
// CHECK PASSWORD
// ============================================================

stock CRP_StorageCheckPassword(
    playerid,
    password[]
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageAccountExists(
        playerid
    ))
    {
        return 0;
    }

    if (!CRP_StorageLoadAccount(
        playerid
    ))
    {
        return 0;
    }

    if (
        !strcmp(
            gStoragePassword[playerid],
            password,
            false
        )
    )
    {
        return 1;
    }

    return 0;
}


// ============================================================
// CHARACTER EXISTS
// ============================================================

stock CRP_StorageCharacterExists(
    playerid,
    slot
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    if (
        gStorageCharacterPRID[playerid][slot] > 0
        &&
        strlen(
            gStorageCharacterName[playerid][slot]
        ) > 0
    )
    {
        return 1;
    }

    return 0;
}


// ============================================================
// GET CHARACTER PRID
// ============================================================

stock CRP_StorageGetCharacterPRID(
    playerid,
    slot
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    return
        gStorageCharacterPRID[playerid][slot];
}


// ============================================================
// SAVE CHARACTER SLOT
// ============================================================

stock CRP_StorageSaveCharacterSlot(
    playerid,
    slot,
    charactername[],
    level,
    origin[],
    gender[],
    dob[],
    religion[],
    lastip[],
    lastlogout[]
)
{
    new prid;
    new isnewcharacter;

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    if (strlen(charactername) < 1)
    {
        return 0;
    }

    if (level < 1)
    {
        level = 1;
    }

    isnewcharacter =
        !CRP_StorageCharacterExists(
            playerid,
            slot
        );

    prid =
        gStorageCharacterPRID[playerid][slot];

    if (
        isnewcharacter &&
        prid == 0
    )
    {
        prid =
            CRP_PRID_Generate();

        if (!prid)
        {
            return 0;
        }

        gStorageCharacterPRID[playerid][slot] =
            prid;
    }

    format(
        gStorageCharacterName[playerid][slot],
        25,
        "%s",
        charactername
    );

    gStorageCharacterLevel[playerid][slot] =
        level;

    format(
        gStorageCharacterOrigin[playerid][slot],
        64,
        "%s",
        origin
    );

    format(
        gStorageCharacterGender[playerid][slot],
        16,
        "%s",
        gender
    );

    format(
        gStorageCharacterDOB[playerid][slot],
        16,
        "%s",
        dob
    );

    format(
        gStorageCharacterReligion[playerid][slot],
        24,
        "%s",
        religion
    );

    format(
        gStorageCharacterLastIP[playerid][slot],
        16,
        "%s",
        lastip
    );

    format(
        gStorageCharacterLastLogout[playerid][slot],
        32,
        "%s",
        lastlogout
    );

    if (isnewcharacter)
    {
        gStorageCharacterLastLogin[playerid][slot][0] =
            EOS;
    }

    if (!CRP_StorageSaveAccount(
        playerid
    ))
    {
        return 0;
    }

    CRP_PRID_RegisterCharacter(
        playerid,
        slot,
        prid,
        charactername
    );

    printf(
        "[CRP STORAGE] Character saved | PRID=%03d | Slot=%d | Name=%s",
        prid,
        slot + 1,
        charactername
    );

    return 1;
}


// ============================================================
// UPDATE CHARACTER LAST LOGIN
// ============================================================

stock CRP_StorageUpdateCharacterLastLogin(
    playerid,
    slot
)
{
    new ip[16];
    new datetime[32];

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    if (!CRP_StorageCharacterExists(
        playerid,
        slot
    ))
    {
        return 0;
    }

    CRP_StorageGetPlayerIP(
        playerid,
        ip,
        sizeof(ip)
    );

    CRP_StorageGetCurrentDateTime(
        datetime,
        sizeof(datetime)
    );

    format(
        gStorageCharacterLastIP[playerid][slot],
        16,
        "%s",
        ip
    );

    format(
        gStorageCharacterLastLogin[playerid][slot],
        32,
        "%s",
        datetime
    );

    if (!CRP_StorageSaveAccount(
        playerid
    ))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// UPDATE CHARACTER LAST LOGOUT
// ============================================================

stock CRP_StorageUpdateCharacterLastLogout(
    playerid,
    slot
)
{
    new ip[16];
    new datetime[32];

    if (!CRP_StorageIsValidPlayer(playerid))
    {
        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        return 0;
    }

    if (!CRP_StorageCharacterExists(
        playerid,
        slot
    ))
    {
        return 0;
    }

    CRP_StorageGetPlayerIP(
        playerid,
        ip,
        sizeof(ip)
    );

    CRP_StorageGetCurrentDateTime(
        datetime,
        sizeof(datetime)
    );

    format(
        gStorageCharacterLastIP[playerid][slot],
        16,
        "%s",
        ip
    );

    format(
        gStorageCharacterLastLogout[playerid][slot],
        32,
        "%s",
        datetime
    );

    if (!CRP_StorageSaveAccount(
        playerid
    ))
    {
        return 0;
    }

    return 1;
}


// ============================================================
// GET BASIC CHARACTER SLOT
// ============================================================

stock CRP_StorageGetCharacterSlot(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    lastlogin[],
    lastloginsize
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;

        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        charactername[0] = EOS;
        lastlogin[0] = EOS;
        level = 0;

        return 0;
    }

    format(
        charactername,
        namesize,
        "%s",
        gStorageCharacterName[playerid][slot]
    );

    level =
        gStorageCharacterLevel[playerid][slot];

    format(
        lastlogin,
        lastloginsize,
        "%s",
        gStorageCharacterLastLogin[playerid][slot]
    );

    return 1;
}


// ============================================================
// GET FULL CHARACTER DATA
// ============================================================

stock CRP_StorageGetCharacterFullData(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    origin[],
    originsize,
    gender[],
    gendersize,
    dob[],
    dobsize,
    religion[],
    religionsize,
    lastip[],
    ipsize,
    lastlogin[],
    loginsize,
    lastlogout[],
    logoutsize
)
{
    if (!CRP_StorageIsValidPlayer(playerid))
    {
        charactername[0] = EOS;
        origin[0] = EOS;
        gender[0] = EOS;
        dob[0] = EOS;
        religion[0] = EOS;
        lastip[0] = EOS;
        lastlogin[0] = EOS;
        lastlogout[0] = EOS;
        level = 0;

        return 0;
    }

    if (!CRP_StorageIsValidSlot(slot))
    {
        charactername[0] = EOS;
        origin[0] = EOS;
        gender[0] = EOS;
        dob[0] = EOS;
        religion[0] = EOS;
        lastip[0] = EOS;
        lastlogin[0] = EOS;
        lastlogout[0] = EOS;
        level = 0;

        return 0;
    }

    format(
        charactername,
        namesize,
        "%s",
        gStorageCharacterName[playerid][slot]
    );

    level =
        gStorageCharacterLevel[playerid][slot];

    format(
        origin,
        originsize,
        "%s",
        gStorageCharacterOrigin[playerid][slot]
    );

    format(
        gender,
        gendersize,
        "%s",
        gStorageCharacterGender[playerid][slot]
    );

    format(
        dob,
        dobsize,
        "%s",
        gStorageCharacterDOB[playerid][slot]
    );

    format(
        religion,
        religionsize,
        "%s",
        gStorageCharacterReligion[playerid][slot]
    );

    format(
        lastip,
        ipsize,
        "%s",
        gStorageCharacterLastIP[playerid][slot]
    );

    format(
        lastlogin,
        loginsize,
        "%s",
        gStorageCharacterLastLogin[playerid][slot]
    );

    format(
        lastlogout,
        logoutsize,
        "%s",
        gStorageCharacterLastLogout[playerid][slot]
    );

    return 1;
}


// ============================================================
// REMOTE API
// ============================================================


// ============================================================
// ACCOUNT EXISTS
// ============================================================

forward CRP_StorageAccountExistsRemote(
    playerid
);

public CRP_StorageAccountExistsRemote(
    playerid
)
{
    return
        CRP_StorageAccountExists(
            playerid
        );
}


// ============================================================
// IP ALREADY REGISTERED
// ============================================================

forward CRP_StorageIPAlreadyRegisteredRemote(
    playerid
);

public CRP_StorageIPAlreadyRegisteredRemote(
    playerid
)
{
    return
        CRP_StorageIPAlreadyRegistered(
            playerid
        );
}


// ============================================================
// REGISTER IP
// ============================================================

forward CRP_StorageRegisterIPRemote(
    playerid
);

public CRP_StorageRegisterIPRemote(
    playerid
)
{
    return
        CRP_StorageRegisterIP(
            playerid
        );
}


// ============================================================
// GET PLAYER IP
// ============================================================

forward CRP_StorageGetPlayerIPRemote(
    playerid,
    ip[],
    size
);

public CRP_StorageGetPlayerIPRemote(
    playerid,
    ip[],
    size
)
{
    return
        CRP_StorageGetPlayerIP(
            playerid,
            ip,
            size
        );
}


// ============================================================
// CREATE ACCOUNT
// ============================================================

forward CRP_StorageCreateAccountRemote(
    playerid,
    password[],
    email[]
);

public CRP_StorageCreateAccountRemote(
    playerid,
    password[],
    email[]
)
{
    return
        CRP_StorageCreateAccount(
            playerid,
            password,
            email
        );
}


// ============================================================
// SAVE ACCOUNT
// ============================================================

forward CRP_StorageSaveAccountRemote(
    playerid
);

public CRP_StorageSaveAccountRemote(
    playerid
)
{
    return
        CRP_StorageSaveAccount(
            playerid
        );
}


// ============================================================
// LOAD ACCOUNT
// ============================================================

forward CRP_StorageLoadAccountRemote(
    playerid
);

public CRP_StorageLoadAccountRemote(
    playerid
)
{
    return
        CRP_StorageLoadAccount(
            playerid
        );
}


// ============================================================
// CHECK PASSWORD
// ============================================================

forward CRP_StorageCheckPasswordRemote(
    playerid,
    password[]
);

public CRP_StorageCheckPasswordRemote(
    playerid,
    password[]
)
{
    return
        CRP_StorageCheckPassword(
            playerid,
            password
        );
}


// ============================================================
// CHARACTER EXISTS
// ============================================================

forward CRP_StorageCharacterExistsRemote(
    playerid,
    slot
);

public CRP_StorageCharacterExistsRemote(
    playerid,
    slot
)
{
    return
        CRP_StorageCharacterExists(
            playerid,
            slot
        );
}


// ============================================================
// GET CHARACTER PRID
// ============================================================

forward CRP_StorageGetCharacterPRIDRemote(
    playerid,
    slot
);

public CRP_StorageGetCharacterPRIDRemote(
    playerid,
    slot
)
{
    return
        CRP_StorageGetCharacterPRID(
            playerid,
            slot
        );
}


// ============================================================
// GET CHARACTER BASIC SLOT
// ============================================================

forward CRP_StorageGetCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    lastlogin[],
    lastloginsize
);

public CRP_StorageGetCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    lastlogin[],
    lastloginsize
)
{
    return
        CRP_StorageGetCharacterSlot(
            playerid,
            slot,
            charactername,
            namesize,
            level,
            lastlogin,
            lastloginsize
        );
}


// ============================================================
// SAVE CHARACTER
// ============================================================

forward CRP_StorageSaveCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    level,
    origin[],
    gender[],
    dob[],
    religion[],
    lastip[],
    lastlogout[]
);

public CRP_StorageSaveCharacterSlotRemote(
    playerid,
    slot,
    charactername[],
    level,
    origin[],
    gender[],
    dob[],
    religion[],
    lastip[],
    lastlogout[]
)
{
    return
        CRP_StorageSaveCharacterSlot(
            playerid,
            slot,
            charactername,
            level,
            origin,
            gender,
            dob,
            religion,
            lastip,
            lastlogout
        );
}


// ============================================================
// UPDATE LAST LOGIN
// ============================================================

forward CRP_StorageUpdateCharacterLastLoginRemote(
    playerid,
    slot
);

public CRP_StorageUpdateCharacterLastLoginRemote(
    playerid,
    slot
)
{
    return
        CRP_StorageUpdateCharacterLastLogin(
            playerid,
            slot
        );
}


// ============================================================
// UPDATE LAST LOGOUT
// ============================================================

forward CRP_StorageUpdateCharacterLastLogoutRemote(
    playerid,
    slot
);

public CRP_StorageUpdateCharacterLastLogoutRemote(
    playerid,
    slot
)
{
    return
        CRP_StorageUpdateCharacterLastLogout(
            playerid,
            slot
        );
}


// ============================================================
// GET FULL CHARACTER DATA
// ============================================================

forward CRP_StorageGetCharacterFullDataRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    origin[],
    originsize,
    gender[],
    gendersize,
    dob[],
    dobsize,
    religion[],
    religionsize,
    lastip[],
    ipsize,
    lastlogin[],
    loginsize,
    lastlogout[],
    logoutsize
);

public CRP_StorageGetCharacterFullDataRemote(
    playerid,
    slot,
    charactername[],
    namesize,
    &level,
    origin[],
    originsize,
    gender[],
    gendersize,
    dob[],
    dobsize,
    religion[],
    religionsize,
    lastip[],
    ipsize,
    lastlogin[],
    loginsize,
    lastlogout[],
    logoutsize
)
{
    return
        CRP_StorageGetCharacterFullData(
            playerid,
            slot,
            charactername,
            namesize,
            level,
            origin,
            originsize,
            gender,
            gendersize,
            dob,
            dobsize,
            religion,
            religionsize,
            lastip,
            ipsize,
            lastlogin,
            loginsize,
            lastlogout,
            logoutsize
        );
}


// ============================================================
// DEBUG COMMAND
// ============================================================

public OnPlayerCommandText(
    playerid,
    cmdtext[]
)
{
    if (
        !strcmp(
            cmdtext,
            "/storage",
            true
        )
    )
    {
        new filepath[128];

        CRP_GetAccountFile(
            playerid,
            filepath,
            sizeof(filepath)
        );

        if (
            CRP_StorageAccountExists(
                playerid
            )
        )
        {
            SendClientMessage(
                playerid,
                COLOR_GREEN,
                "[CRP STORAGE] Account file ditemukan."
            );
        }
        else
        {
            SendClientMessage(
                playerid,
                COLOR_YELLOW,
                "[CRP STORAGE] Account file belum ada."
            );
        }

        SendClientMessage(
            playerid,
            COLOR_GREY,
            filepath
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
    CRP_StorageReset(
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
    CRP_StorageReset(
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
    print(" Crystal Roleplay");
    print(" Storage System v1.0");
    print("---------------------------------------");
    print(" Account Storage        : READY");
    print(" Account Registration   : READY");
    print(" Account Login          : READY");
    print(" Password Verification  : READY");
    print(" IP Registry            : READY");
    print(" 5 Character Slots      : READY");
    print(" Character Creation     : READY");
    print(" Character Basic Data   : READY");
    print(" Character Full Data    : READY");
    print(" Character Last Login   : READY");
    print(" Character Last Logout  : READY");
    print(" Global PRID Registry   : READY");
    print(" Remote API Contract    : READY");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// FILTERSCRIPT EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP STORAGE] Storage System v1.0 unloaded."
    );

    return 1;
}