#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Register Spawn TextDraw v0.1
//
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fungsi:
// - UI pemilihan lokasi spawn karakter baru
// - 4 pilihan lokasi Register Spawn
// - Menampilkan nama dan deskripsi lokasi
// - Konfirmasi lokasi spawn
// - Batal kembali ke Character Selection
//
// Logic spawn:
// - crp_register_spawn.pwn
//
// UI:
// - File ini
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
// REGISTER SPAWN ID
// ============================================================

#define REGISTER_SPAWN_UNITY       0
#define REGISTER_SPAWN_AIRPORT     1
#define REGISTER_SPAWN_SANTA       2
#define REGISTER_SPAWN_EAST        3

#define REGISTER_SPAWN_MIN         REGISTER_SPAWN_UNITY
#define REGISTER_SPAWN_MAX         REGISTER_SPAWN_EAST


// ============================================================
// TEXTDRAW ID
// ============================================================

#define TD_BACKGROUND             0
#define TD_TITLE                  1
#define TD_SUBTITLE               2

#define TD_SPAWN_1                3
#define TD_SPAWN_2                4
#define TD_SPAWN_3                5
#define TD_SPAWN_4                6

#define TD_SPAWN_INFO_1           7
#define TD_SPAWN_INFO_2           8
#define TD_SPAWN_INFO_3           9
#define TD_SPAWN_INFO_4           10

#define TD_BUTTON_SELECT          11
#define TD_BUTTON_CANCEL          12

#define REGISTER_SPAWN_TD_COUNT   13


// ============================================================
// PLAYER TEXTDRAW
// ============================================================

new PlayerText:gRegisterSpawnTD[
    MAX_PLAYERS
][
    REGISTER_SPAWN_TD_COUNT
];


// ============================================================
// PLAYER STATE
// ============================================================

new gSelectedRegisterSpawn[
    MAX_PLAYERS
];


// ============================================================
// REMOTE FUNCTIONS
// ============================================================

forward CRP_StartNewCharacterSpawn(
    playerid,
    spawnid
);

forward CRP_ShowCharacterSelectionRemote(
    playerid
);


// ============================================================
// VALID PLAYER
// ============================================================

stock CRP_IsValidRegisterSpawnUIPlayer(
    playerid
)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    if (
        !IsPlayerConnected(playerid)
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// VALID SPAWN
// ============================================================

stock CRP_IsValidRegisterSpawnUI(
    spawnid
)
{
    if (
        spawnid < REGISTER_SPAWN_MIN ||
        spawnid > REGISTER_SPAWN_MAX
    )
    {
        return 0;
    }

    return 1;
}


// ============================================================
// RESET SELECTION
// ============================================================

stock CRP_ResetRegisterSpawnUI(
    playerid
)
{
    if (
        playerid < 0 ||
        playerid >= MAX_PLAYERS
    )
    {
        return 0;
    }

    gSelectedRegisterSpawn[playerid] = -1;

    return 1;
}


// ============================================================
// GET SPAWN NAME
// ============================================================

stock CRP_GetRegisterSpawnUIName(
    spawnid,
    name[],
    size
)
{
    if (
        size <= 0
    )
    {
        return 0;
    }

    switch (
        spawnid
    )
    {
        case REGISTER_SPAWN_UNITY:
        {
            format(
                name,
                size,
                "UNITY STATION"
            );
        }

        case REGISTER_SPAWN_AIRPORT:
        {
            format(
                name,
                size,
                "LOS SANTOS AIRPORT"
            );
        }

        case REGISTER_SPAWN_SANTA:
        {
            format(
                name,
                size,
                "SANTA MARIA BEACH"
            );
        }

        case REGISTER_SPAWN_EAST:
        {
            format(
                name,
                size,
                "EAST BEACH"
            );
        }

        default:
        {
            format(
                name,
                size,
                "UNKNOWN"
            );
        }
    }

    return 1;
}


// ============================================================
// GET SPAWN DESCRIPTION
// ============================================================

stock CRP_GetRegisterSpawnUIDescription(
    spawnid,
    description[],
    size
)
{
    if (
        size <= 0
    )
    {
        return 0;
    }

    switch (
        spawnid
    )
    {
        case REGISTER_SPAWN_UNITY:
        {
            format(
                description,
                size,
                "Pusat transportasi utama di kawasan pusat Los Santos."
            );
        }

        case REGISTER_SPAWN_AIRPORT:
        {
            format(
                description,
                size,
                "Bandara utama yang menjadi pintu masuk Los Santos."
            );
        }

        case REGISTER_SPAWN_SANTA:
        {
            format(
                description,
                size,
                "Kawasan pesisir dengan suasana pantai Los Santos."
            );
        }

        case REGISTER_SPAWN_EAST:
        {
            format(
                description,
                size,
                "Kawasan timur Los Santos dengan lingkungan permukiman."
            );
        }

        default:
        {
            format(
                description,
                size,
                "Lokasi awal karakter di Los Santos."
            );
        }
    }

    return 1;
}


// ============================================================
// CREATE TEXTDRAW
// ============================================================

stock CRP_CreateRegisterSpawnTextDraw(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnUIPlayer(playerid)
    )
    {
        return 0;
    }


    // --------------------------------------------------------
    // BACKGROUND
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_BACKGROUND] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            385.0,
            "_"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        0.0,
        14.5
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        640.0,
        0.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        COLOR_WHITE
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        0x09261FFF
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND],
        1
    );


    // --------------------------------------------------------
    // TITLE
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_TITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            210.0,
            "REGISTER SPAWN"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE],
        0.32,
        1.5
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE],
        0xD8B56AFF
    );

    PlayerTextDrawSetOutline(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE],
        1
    );


    // --------------------------------------------------------
    // SUBTITLE
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SUBTITLE] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            238.0,
            "PILIH LOKASI AWAL PERJALANAN KARAKTER KAMU"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SUBTITLE],
        0.18,
        0.9
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SUBTITLE],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SUBTITLE],
        COLOR_GREY
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SUBTITLE],
        1
    );


    // --------------------------------------------------------
    // SPAWN BUTTON 1
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SPAWN_1] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            275.0,
            "[ UNITY STATION ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        COLOR_WHITE
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        0x163B32FF
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        90.0,
        155.0
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1],
        1
    );


    // --------------------------------------------------------
    // SPAWN BUTTON 2
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SPAWN_2] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            315.0,
            "[ LOS SANTOS AIRPORT ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        COLOR_WHITE
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        0x163B32FF
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        90.0,
        155.0
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2],
        1
    );


    // --------------------------------------------------------
    // SPAWN BUTTON 3
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SPAWN_3] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            355.0,
            "[ SANTA MARIA BEACH ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        COLOR_WHITE
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        0x163B32FF
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        90.0,
        155.0
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3],
        1
    );


    // --------------------------------------------------------
    // SPAWN BUTTON 4
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SPAWN_4] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            395.0,
            "[ EAST BEACH ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        0.22,
        1.1
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        COLOR_WHITE
    );

    PlayerTextDrawUseBox(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        1
    );

    PlayerTextDrawBoxColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        0x163B32FF
    );

    PlayerTextDrawTextSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        90.0,
        155.0
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4],
        1
    );


    // --------------------------------------------------------
    // INFO
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            294.0,
            "Pusat transportasi utama Los Santos."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1],
        0.15,
        0.75
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1],
        COLOR_GREY
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1],
        1
    );


    gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            334.0,
            "Pintu masuk utama Los Santos."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2],
        0.15,
        0.75
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2],
        COLOR_GREY
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2],
        1
    );


    gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            374.0,
            "Kawasan pesisir Los Santos."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3],
        0.15,
        0.75
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3],
        COLOR_GREY
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3],
        1
    );


    gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4] =
        CreatePlayerTextDraw(
            playerid,
            320.0,
            414.0,
            "Kawasan timur Los Santos."
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4],
        0.15,
        0.75
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4],
        COLOR_GREY
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4],
        1
    );


    // --------------------------------------------------------
    // SELECT BUTTON
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_BUTTON_SELECT] =
        CreatePlayerTextDraw(
            playerid,
            270.0,
            455.0,
            "[ PILIH LOKASI ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT],
        0.20,
        1.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT],
        COLOR_WHITE
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT],
        1
    );


    // --------------------------------------------------------
    // CANCEL BUTTON
    // --------------------------------------------------------

    gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL] =
        CreatePlayerTextDraw(
            playerid,
            370.0,
            455.0,
            "[ BATAL ]"
        );

    PlayerTextDrawLetterSize(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL],
        0.20,
        1.0
    );

    PlayerTextDrawAlignment(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL],
        2
    );

    PlayerTextDrawColor(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL],
        COLOR_RED
    );

    PlayerTextDrawSetSelectable(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    PlayerTextDrawSetProportional(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL],
        1
    );

    return 1;
}


// ============================================================
// SHOW UI
// ============================================================

stock CRP_ShowRegisterSpawnSelection(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnUIPlayer(playerid)
    )
    {
        return 0;
    }

    CRP_ResetRegisterSpawnUI(
        playerid
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_BACKGROUND]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_TITLE]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SUBTITLE]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_1]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_2]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_3]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_4]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_1]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_2]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_3]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_SPAWN_INFO_4]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT]
    );

    PlayerTextDrawShow(
        playerid,
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL]
    );

    SelectTextDraw(
        playerid,
        0xD8B56AFF
    );

    return 1;
}


// ============================================================
// HIDE UI
// ============================================================

stock CRP_HideRegisterSpawnSelection(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnUIPlayer(playerid)
    )
    {
        return 0;
    }

    for (
        new i = 0;
        i < REGISTER_SPAWN_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawHide(
            playerid,
            gRegisterSpawnTD[playerid][i]
        );
    }

    CancelSelectTextDraw(
        playerid
    );

    return 1;
}


// ============================================================
// REMOTE
// ============================================================

forward CRP_ShowRegisterSpawnSelectionRemote(
    playerid
);

public CRP_ShowRegisterSpawnSelectionRemote(
    playerid
)
{
    if (
        !CRP_IsValidRegisterSpawnUIPlayer(playerid)
    )
    {
        return 0;
    }

    return CRP_ShowRegisterSpawnSelection(
        playerid
    );
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
        !CRP_IsValidRegisterSpawnUIPlayer(playerid)
    )
    {
        return 0;
    }


    // --------------------------------------------------------
    // SPAWN 1
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_SPAWN_1]
    )
    {
        gSelectedRegisterSpawn[playerid] =
            REGISTER_SPAWN_UNITY;

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP SPAWN] Unity Station dipilih."
        );

        return 1;
    }


    // --------------------------------------------------------
    // SPAWN 2
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_SPAWN_2]
    )
    {
        gSelectedRegisterSpawn[playerid] =
            REGISTER_SPAWN_AIRPORT;

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP SPAWN] Los Santos Airport dipilih."
        );

        return 1;
    }


    // --------------------------------------------------------
    // SPAWN 3
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_SPAWN_3]
    )
    {
        gSelectedRegisterSpawn[playerid] =
            REGISTER_SPAWN_SANTA;

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP SPAWN] Santa Maria Beach dipilih."
        );

        return 1;
    }


    // --------------------------------------------------------
    // SPAWN 4
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_SPAWN_4]
    )
    {
        gSelectedRegisterSpawn[playerid] =
            REGISTER_SPAWN_EAST;

        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "[CRP SPAWN] East Beach dipilih."
        );

        return 1;
    }


    // --------------------------------------------------------
    // SELECT
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_BUTTON_SELECT]
    )
    {
        if (
            !CRP_IsValidRegisterSpawnUI(
                gSelectedRegisterSpawn[playerid]
            )
        )
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "[CRP SPAWN] Pilih lokasi spawn terlebih dahulu."
            );

            return 1;
        }


        new spawnid =
            gSelectedRegisterSpawn[playerid];


        CRP_HideRegisterSpawnSelection(
            playerid
        );


        SendClientMessage(
            playerid,
            COLOR_GREEN,
            "[CRP SPAWN] Lokasi awal dikonfirmasi."
        );


        CRP_StartNewCharacterSpawn(
            playerid,
            spawnid
        );

        return 1;
    }


    // --------------------------------------------------------
    // CANCEL
    // --------------------------------------------------------

    if (
        playertextid ==
        gRegisterSpawnTD[playerid][TD_BUTTON_CANCEL]
    )
    {
        CRP_HideRegisterSpawnSelection(
            playerid
        );

        CRP_ResetRegisterSpawnUI(
            playerid
        );

        SendClientMessage(
            playerid,
            COLOR_GREY,
            "[CRP SPAWN] Pemilihan lokasi dibatalkan."
        );


        CallRemoteFunction(
            "CRP_ShowCharacterSelectionRemote",
            "d",
            playerid
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
    CRP_ResetRegisterSpawnUI(
        playerid
    );

    CRP_CreateRegisterSpawnTextDraw(
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
    CRP_ResetRegisterSpawnUI(
        playerid
    );

    for (
        new i = 0;
        i < REGISTER_SPAWN_TD_COUNT;
        i++
    )
    {
        PlayerTextDrawDestroy(
            playerid,
            gRegisterSpawnTD[playerid][i]
        );
    }

    return 1;
}


// ============================================================
// INIT
// ============================================================

public OnFilterScriptInit()
{
    print("---------------------------------------");
    print(" CRP Register Spawn TextDraw v0.1");
    print(" Register Spawn Selection UI Loaded");
    print(" 4 Spawn Locations Loaded");
    print("---------------------------------------");

    return 1;
}


// ============================================================
// EXIT
// ============================================================

public OnFilterScriptExit()
{
    print(
        "[CRP REGISTER SPAWN UI] System unloaded."
    );

    return 1;
}