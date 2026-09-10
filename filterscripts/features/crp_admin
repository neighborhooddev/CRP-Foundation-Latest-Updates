#include <a_samp>

// ============================================================
// CRYSTAL ROLEPLAY
// Admin System v2.1
//
// File      : filterscripts/feature/crp_admin.pwn
// Developer : Muhammad Rizal
// Project   : Crystal Roleplay
//
// Fokus v2.1:
// - Admin Rank Foundation
// - Account Username Identity
// - RankName + Username Admin Chat
// - Bright Admin Chat Color
// - /aon and /aoff
// - Duty Timer Foundation
// - Admin Panel /ap
// - Admin List
// - Duty Online
// - Set Admin Foundation
// - Admin Logs Foundation
// - Archives > Reports
// - Player Reports
// - Report Accept / Reject
// - Report Timeout 10 Minutes
// - /reports
// - /myreports
// - /check
// - AdminCmd: category
// - BotCmd: category
// - Developer Protection
// - Developer Actions Never Logged
//
// IMPORTANT:
// Admin rank is ACCOUNT based, NOT CHARACTER based.
// Do not store admin rank inside character slots.
// ============================================================


// ============================================================
// COLORS
// ============================================================

#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_RED               0xFF0000FF
#define COLOR_GREEN             0x00FF00FF
#define COLOR_YELLOW            0xFFFF00FF
#define COLOR_GREY              0xBFC0C2FF

// Bright Admin Chat
#define COLOR_ADMIN_CHAT        0xFF4444FF
#define COLOR_ADMIN_RANK        0xFF6666FF
#define COLOR_ADMIN_USERNAME    0xFF4444FF
#define COLOR_ADMIN_MESSAGE     0xFFFFFFFF

#define COLOR_ADMIN_PANEL       0xD8B56AFF
#define COLOR_EMERALD           0x09261FFF


// ============================================================
// ADMIN RANK
// ============================================================

#define ADMIN_NO_STAFF          0
#define ADMIN_INTERN            1
#define ADMIN_HELPER            2
#define ADMIN_SENIOR_HELPER     3
#define ADMIN_ADMIN             4
#define ADMIN_SENIOR_ADMIN      5
#define ADMIN_SUPERVISOR        6
#define ADMIN_HIGH_ADMIN        7
#define ADMIN_ADMIN_DIRECTOR    8
#define ADMIN_SERVER_DIRECTOR   9
#define ADMIN_DEVELOPER         10


// ============================================================
// PERMISSION RESULT
// ============================================================

#define ADMIN_RESULT_OK         1
#define ADMIN_RESULT_DENIED     0


// ============================================================
// PANEL
// ============================================================

#define ADMIN_PANEL_NONE        0
#define ADMIN_PANEL_MAIN        1
#define ADMIN_PANEL_LIST        2
#define ADMIN_PANEL_DUTY        3
#define ADMIN_PANEL_ADMINS      4
#define ADMIN_PANEL_SETADMIN    5
#define ADMIN_PANEL_LOGS        6
#define ADMIN_PANEL_ARCHIVES    7
#define ADMIN_PANEL_REPORTS     8


// ============================================================
// LOG CATEGORY
// ============================================================

#define ADMIN_LOG_NONE          0
#define ADMIN_LOG_BAN           1
#define ADMIN_LOG_KICK          2
#define ADMIN_LOG_JAIL          3
#define ADMIN_LOG_OTHER         4


// ============================================================
// REPORT STATUS
// ============================================================

#define REPORT_STATUS_NONE          0
#define REPORT_STATUS_PENDING       1
#define REPORT_STATUS_ACCEPTED      2
#define REPORT_STATUS_REJECTED      3
#define REPORT_STATUS_NOT_RESPONDED 4


// ============================================================
// REPORT CONSTANTS
// ============================================================

#define MAX_ADMIN_REPORTS        100
#define MAX_REPORT_REASON        128
#define MAX_REPORT_TARGET        32

#define REPORT_TIMEOUT_MS        600000


// ============================================================
// ADMIN LOG CONSTANTS
// ============================================================

#define MAX_ADMIN_LOGS           100
#define MAX_ADMIN_LOG_TEXT       160


// ============================================================
// PLAYER ADMIN DATA
// ============================================================

new gPlayerAdminRank[MAX_PLAYERS];

new gPlayerAccountUsername[MAX_PLAYERS][25];

new bool:gPlayerAdminDuty[MAX_PLAYERS];
new gPlayerAdminDutyStart[MAX_PLAYERS];
new gPlayerAdminDutyTotal[MAX_PLAYERS];

new gPlayerAdminPanel[MAX_PLAYERS];


// ============================================================
// REPORT DATA
// ============================================================

new gReportID[MAX_ADMIN_REPORTS];
new gReportPlayer[MAX_ADMIN_REPORTS];
new gReportTarget[MAX_ADMIN_REPORTS][MAX_REPORT_TARGET];
new gReportReason[MAX_ADMIN_REPORTS][MAX_REPORT_REASON];

new gReportStatus[MAX_ADMIN_REPORTS];
new gReportCreatedAt[MAX_ADMIN_REPORTS];

new gReportArchiveID[MAX_ADMIN_REPORTS];
new gReportArchivePlayer[MAX_ADMIN_REPORTS];
new gReportArchiveTarget[MAX_ADMIN_REPORTS][MAX_REPORT_TARGET];
new gReportArchiveReason[MAX_ADMIN_REPORTS][MAX_REPORT_REASON];
new gReportArchiveStatus[MAX_ADMIN_REPORTS];

new gNextReportID = 1;
new gNextReportArchiveID = 1;


// ============================================================
// REPORT UI CACHE
// ============================================================

new gSelectedReportIndex[MAX_PLAYERS];


// ============================================================
// LOG DATA
// ============================================================

new gAdminLogCategory[MAX_ADMIN_LOGS];
new gAdminLogTarget[MAX_ADMIN_LOGS];
new gAdminLogText[MAX_ADMIN_LOGS][MAX_ADMIN_LOG_TEXT];
new gAdminLogTimestamp[MAX_ADMIN_LOGS];

new gAdminLogCount;


// ============================================================
// ADMIN PANEL DIALOGS
// ============================================================

#define DIALOG_ADMIN_MAIN          3000
#define DIALOG_ADMIN_LIST          3001
#define DIALOG_ADMIN_DUTY          3002
#define DIALOG_ADMIN_ADMINS        3003
#define DIALOG_ADMIN_SETADMIN      3004
#define DIALOG_ADMIN_LOGS          3005
#define DIALOG_ADMIN_ARCHIVES      3006
#define DIALOG_ADMIN_ARCHIVE_REPORTS 3007

#define DIALOG_REPORT_LIST          3010
#define DIALOG_REPORT_DETAIL        3011
#define DIALOG_REPORT_ACTION        3012
#define DIALOG_MYREPORTS            3013

#define DIALOG_ADMIN_CHECK          3020


// ============================================================
// FORWARDS
// ============================================================

forward CRP_AdminProcessReportTimeout();


// ============================================================
// RANK NAME
// ============================================================

stock CRP_GetAdminRankName(rank, output[], size)
{
    switch(rank)
    {
        case ADMIN_DEVELOPER:
        {
            format(output, size, "Developer");
        }

        case ADMIN_SERVER_DIRECTOR:
        {
            format(output, size, "Server Director");
        }

        case ADMIN_ADMIN_DIRECTOR:
        {
            format(output, size, "Admin Director");
        }

        case ADMIN_HIGH_ADMIN:
        {
            format(output, size, "High Admin");
        }

        case ADMIN_SUPERVISOR:
        {
            format(output, size, "Supervisor Admin");
        }

        case ADMIN_SENIOR_ADMIN:
        {
            format(output, size, "Senior Admin");
        }

        case ADMIN_ADMIN:
        {
            format(output, size, "Admin");
        }

        case ADMIN_SENIOR_HELPER:
        {
            format(output, size, "Senior Helper");
        }

        case ADMIN_HELPER:
        {
            format(output, size, "Helper");
        }

        case ADMIN_INTERN:
        {
            format(output, size, "Intern Staff");
        }

        default:
        {
            format(output, size, "No Staff");
        }
    }

    return 1;
}


// ============================================================
// ACCOUNT IDENTITY
// ============================================================
//
// Current authentication architecture uses player username
// as account identity before character activation.
// Therefore admin identity follows Account Username.
//
// Character Name is intentionally NOT used here.
// ============================================================

stock CRP_AdminLoadAccountIdentity(playerid)
{
    if(!IsPlayerConnected(playerid))
    {
        return 0;
    }

    GetPlayerName(playerid, gPlayerAccountUsername[playerid], 25);

    return 1;
}


// ============================================================
// BASIC VALIDATION
// ============================================================

stock CRP_AdminIsValidPlayer(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    if(!IsPlayerConnected(playerid))
    {
        return 0;
    }

    return 1;
}


stock CRP_AdminIsStaff(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] > ADMIN_NO_STAFF;
}


stock CRP_AdminIsDeveloper(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    return gPlayerAdminRank[playerid] == ADMIN_DEVELOPER;
}


// ============================================================
// DEVELOPER INTERNAL SETTER
// ============================================================
//
// IMPORTANT:
// This is intentionally NOT exposed as a command.
//
// Rank 10 cannot be assigned through /setadmin.
// ============================================================

stock CRP_SetDeveloperInternal(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    gPlayerAdminRank[playerid] = ADMIN_DEVELOPER;

    return 1;
}


// ============================================================
// TARGET HIERARCHY
// ============================================================
//
// Rules:
//
// Lower rank cannot target same rank.
// Lower rank cannot target higher rank.
// Developer cannot be targeted by other admins.
// Developer can target lower ranks.
// ============================================================

stock CRP_AdminCanTarget(actorid, targetid)
{
    if(!CRP_AdminIsValidPlayer(actorid))
    {
        return 0;
    }

    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(!CRP_AdminIsStaff(actorid))
    {
        return 0;
    }

    if(actorid == targetid)
    {
        return 0;
    }

    // Developer is completely protected.
    if(CRP_AdminIsDeveloper(targetid))
    {
        return 0;
    }

    // Developer may target lower ranks.
    if(CRP_AdminIsDeveloper(actorid))
    {
        return 1;
    }

    // Same or higher rank cannot be targeted.
    if(gPlayerAdminRank[targetid] >= gPlayerAdminRank[actorid])
    {
        return 0;
    }

    return 1;
}


// ============================================================
// SET ADMIN MAXIMUM
// ============================================================

stock CRP_GetSetAdminMaximumRank(actorid)
{
    if(!CRP_AdminIsStaff(actorid))
    {
        return ADMIN_NO_STAFF;
    }

    switch(gPlayerAdminRank[actorid])
    {
        case ADMIN_ADMIN_DIRECTOR:
        {
            return ADMIN_INTERN;
        }

        case ADMIN_SERVER_DIRECTOR:
        {
            return ADMIN_SENIOR_ADMIN;
        }

        case ADMIN_DEVELOPER:
        {
            return ADMIN_SERVER_DIRECTOR;
        }
    }

    return ADMIN_NO_STAFF;
}


// ============================================================
// SET ADMIN VALIDATION
// ============================================================

stock CRP_AdminCanSetRank(actorid, targetid, newrank)
{
    if(!CRP_AdminIsValidPlayer(actorid))
    {
        return 0;
    }

    if(!CRP_AdminIsValidPlayer(targetid))
    {
        return 0;
    }

    if(!CRP_AdminIsStaff(actorid))
    {
        return 0;
    }

    // Developer cannot be targeted.
    if(CRP_AdminIsDeveloper(targetid))
    {
        return 0;
    }

    // Rank 10 can NEVER be assigned by Set Admin.
    if(newrank >= ADMIN_DEVELOPER)
    {
        return 0;
    }

    if(newrank < ADMIN_NO_STAFF)
    {
        return 0;
    }

    new maximum = CRP_GetSetAdminMaximumRank(actorid);

    if(maximum <= ADMIN_NO_STAFF)
    {
        return 0;
    }

    if(newrank > maximum)
    {
        return 0;
    }

    // Non-developer cannot modify same/higher admin.
    if(!CRP_AdminIsDeveloper(actorid))
    {
        if(gPlayerAdminRank[targetid] >= gPlayerAdminRank[actorid])
        {
            return 0;
        }
    }

    return 1;
}


// ============================================================
// ADMIN LOG
// ============================================================
//
// Developer actions are intentionally NEVER recorded.
// ============================================================

stock CRP_AdminLogAction(actorid, category, targetid, const action[])
{
    if(!CRP_AdminIsValidPlayer(actorid))
    {
        return 0;
    }

    // Developer is invisible in logs.
    if(CRP_AdminIsDeveloper(actorid))
    {
        return 0;
    }

    if(gAdminLogCount >= MAX_ADMIN_LOGS)
    {
        for(new i = 1; i < MAX_ADMIN_LOGS; i++)
        {
            gAdminLogCategory[i - 1] = gAdminLogCategory[i];
            gAdminLogTarget[i - 1] = gAdminLogTarget[i];
            gAdminLogTimestamp[i - 1] = gAdminLogTimestamp[i];

            format(
                gAdminLogText[i - 1],
                MAX_ADMIN_LOG_TEXT,
                "%s",
                gAdminLogText[i]
            );
        }

        gAdminLogCount = MAX_ADMIN_LOGS - 1;
    }

    gAdminLogCategory[gAdminLogCount] = category;
    gAdminLogTarget[gAdminLogCount] = targetid;
    gAdminLogTimestamp[gAdminLogCount] = gettime();

    format(
        gAdminLogText[gAdminLogCount],
        MAX_ADMIN_LOG_TEXT,
        "%s",
        action
    );

    gAdminLogCount++;

    return 1;
}


// ============================================================
// LOG PREFIX
// ============================================================

stock CRP_GetLogPrefix(category, output[], size)
{
    switch(category)
    {
        case ADMIN_LOG_BAN,
        ADMIN_LOG_KICK,
        ADMIN_LOG_JAIL,
        ADMIN_LOG_OTHER:
        {
            format(output, size, "AdminCmd:");
        }

        default:
        {
            format(output, size, "BotCmd:");
        }
    }

    return 1;
}


// ============================================================
// ADMIN CHAT
// ============================================================
//
// Format:
//
// Developer Defender: message
// Senior Admin Username: message
//
// RankName + Account Username.
//
// Character Name is never used.
// ============================================================

stock CRP_AdminSendChat(playerid, const message[])
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new rankname[32];
    new output[192];

    CRP_GetAdminRankName(
        gPlayerAdminRank[playerid],
        rankname,
        sizeof(rankname)
    );

    // Admin chat uses bright identity.
    format(
        output,
        sizeof(output),
        "{FF6666}%s {FF4444}%s:{FFFFFF} %s",
        rankname,
        gPlayerAccountUsername[playerid],
        message
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        SendClientMessage(i, COLOR_WHITE, output);
    }

    return 1;
}


// ============================================================
// DUTY DISPLAY
// ============================================================

stock CRP_AdminGetDutySeconds(playerid)
{
    if(!CRP_AdminIsValidPlayer(playerid))
    {
        return 0;
    }

    new total = gPlayerAdminDutyTotal[playerid];

    if(gPlayerAdminDuty[playerid])
    {
        total += gettime() - gPlayerAdminDutyStart[playerid];
    }

    return total;
}


// ============================================================
// DUTY ON
// ============================================================

stock CRP_AdminDutyOn(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(gPlayerAdminDuty[playerid])
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "Admin: Anda sudah dalam status ON DUTY."
        );

        return 1;
    }

    gPlayerAdminDuty[playerid] = true;
    gPlayerAdminDutyStart[playerid] = gettime();

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "Admin: Anda sekarang ON DUTY."
    );

    SendClientMessage(
        playerid,
        COLOR_ADMIN_CHAT,
        "Admin Chat: Identitas Admin Chat sekarang menggunakan RankName + Account Username."
    );

    return 1;
}


// ============================================================
// DUTY OFF
// ============================================================

stock CRP_AdminDutyOff(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(!gPlayerAdminDuty[playerid])
    {
        SendClientMessage(
            playerid,
            COLOR_YELLOW,
            "Admin: Anda tidak sedang ON DUTY."
        );

        return 1;
    }

    gPlayerAdminDutyTotal[playerid] +=
        gettime() - gPlayerAdminDutyStart[playerid];

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;

    new total = gPlayerAdminDutyTotal[playerid];
    new hours = total / 3600;
    new minutes = (total % 3600) / 60;

    new message[144];

    format(
        message,
        sizeof(message),
        "Admin: Anda sekarang OFF DUTY. Total duty: %d jam %d menit.",
        hours,
        minutes
    );

    SendClientMessage(playerid, COLOR_GREEN, message);

    return 1;
}


// ============================================================
// REPORT FREE SLOT
// ============================================================

stock CRP_ReportFindFreeSlot()
{
    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportStatus[i] == REPORT_STATUS_NONE)
        {
            return i;
        }
    }

    return -1;
}


// ============================================================
// REPORT FIND BY ID
// ============================================================

stock CRP_ReportFindByID(reportid)
{
    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportStatus[i] == REPORT_STATUS_NONE)
        {
            continue;
        }

        if(gReportID[i] == reportid)
        {
            return i;
        }
    }

    return -1;
}


// ============================================================
// REPORT ARCHIVE
// ============================================================

stock CRP_ReportArchive(index)
{
    if(index < 0 || index >= MAX_ADMIN_REPORTS)
    {
        return 0;
    }

    if(gReportStatus[index] == REPORT_STATUS_NONE)
    {
        return 0;
    }

    new archive = -1;

    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportArchiveStatus[i] == REPORT_STATUS_NONE)
        {
            archive = i;
            break;
        }
    }

    if(archive == -1)
    {
        return 0;
    }

    gReportArchiveID[archive] = gNextReportArchiveID++;
    gReportArchivePlayer[archive] = gReportPlayer[index];

    format(
        gReportArchiveTarget[archive],
        MAX_REPORT_TARGET,
        "%s",
        gReportTarget[index]
    );

    format(
        gReportArchiveReason[archive],
        MAX_REPORT_REASON,
        "%s",
        gReportReason[index]
    );

    gReportArchiveStatus[archive] = gReportStatus[index];

    gReportStatus[index] = REPORT_STATUS_NONE;
    gReportID[index] = 0;
    gReportPlayer[index] = INVALID_PLAYER_ID;
    gReportCreatedAt[index] = 0;

    return 1;
}


// ============================================================
// REPORT NOTIFICATION
// ============================================================

stock CRP_ReportNotifyAdmins(playerid)
{
    new characterName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, characterName, sizeof(characterName));

    new message[192];

    format(
        message,
        sizeof(message),
        "[ID:%d] %s: mengirimkan laporan, cek '/reports' untuk lebih jelas.",
        playerid,
        characterName
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        SendClientMessage(i, COLOR_YELLOW, message);
    }

    return 1;
}


// ============================================================
// CREATE REPORT
// ============================================================

stock CRP_CreateReport(
    playerid,
    const target[],
    const reason[]
)
{
    new index = CRP_ReportFindFreeSlot();

    if(index == -1)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "REPORTS: Sistem laporan sedang penuh."
        );

        return 0;
    }

    gReportID[index] = gNextReportID++;
    gReportPlayer[index] = playerid;

    format(
        gReportTarget[index],
        MAX_REPORT_TARGET,
        "%s",
        target
    );

    format(
        gReportReason[index],
        MAX_REPORT_REASON,
        "%s",
        reason
    );

    gReportStatus[index] = REPORT_STATUS_PENDING;
    gReportCreatedAt[index] = gettime();

    SendClientMessage(
        playerid,
        COLOR_GREEN,
        "REPORTS: Anda berhasil mengirimkan laporan, silahkan cek '/reports' untuk status laporan anda."
    );

    CRP_ReportNotifyAdmins(playerid);

    return 1;
}


// ============================================================
// REPORT STATUS TEXT
// ============================================================

stock CRP_GetReportStatusName(status, output[], size)
{
    switch(status)
    {
        case REPORT_STATUS_PENDING:
        {
            format(output, size, "PENDING");
        }

        case REPORT_STATUS_ACCEPTED:
        {
            format(output, size, "ACCEPTED");
        }

        case REPORT_STATUS_REJECTED:
        {
            format(output, size, "REJECTED");
        }

        case REPORT_STATUS_NOT_RESPONDED:
        {
            format(output, size, "NOT RESPONDED");
        }

        default:
        {
            format(output, size, "UNKNOWN");
        }
    }

    return 1;
}


// ============================================================
// REPORT ACCEPT
// ============================================================

stock CRP_ReportAccept(adminid, index)
{
    if(!CRP_AdminIsStaff(adminid))
    {
        return 0;
    }

    if(index < 0 || index >= MAX_ADMIN_REPORTS)
    {
        return 0;
    }

    if(gReportStatus[index] != REPORT_STATUS_PENDING)
    {
        return 0;
    }

    new targetPlayer = gReportPlayer[index];

    gReportStatus[index] = REPORT_STATUS_ACCEPTED;

    if(
        targetPlayer != INVALID_PLAYER_ID &&
        CRP_AdminIsValidPlayer(targetPlayer)
    )
    {
        new message[144];

        format(
            message,
            sizeof(message),
            "REPORTS: %s telah menerima laporan anda.",
            gPlayerAccountUsername[adminid]
        );

        SendClientMessage(
            targetPlayer,
            COLOR_GREEN,
            message
        );
    }

    new logMessage[192];

    format(
        logMessage,
        sizeof(logMessage),
        "%s melakukan tinjauan pada report ID %d.",
        gPlayerAccountUsername[adminid],
        gReportID[index]
    );

    CRP_AdminLogAction(
        adminid,
        ADMIN_LOG_OTHER,
        targetPlayer,
        logMessage
    );

    CRP_ReportArchive(index);

    return 1;
}


// ============================================================
// REPORT REJECT
// ============================================================

stock CRP_ReportReject(adminid, index)
{
    if(!CRP_AdminIsStaff(adminid))
    {
        return 0;
    }

    if(index < 0 || index >= MAX_ADMIN_REPORTS)
    {
        return 0;
    }

    if(gReportStatus[index] != REPORT_STATUS_PENDING)
    {
        return 0;
    }

    new targetPlayer = gReportPlayer[index];

    gReportStatus[index] = REPORT_STATUS_REJECTED;

    if(
        targetPlayer != INVALID_PLAYER_ID &&
        CRP_AdminIsValidPlayer(targetPlayer)
    )
    {
        new message[144];

        format(
            message,
            sizeof(message),
            "REPORTS: %s telah menolak laporan anda.",
            gPlayerAccountUsername[adminid]
        );

        SendClientMessage(
            targetPlayer,
            COLOR_RED,
            message
        );
    }

    new logMessage[192];

    format(
        logMessage,
        sizeof(logMessage),
        "%s melakukan penolakan pada report ID %d.",
        gPlayerAccountUsername[adminid],
        gReportID[index]
    );

    CRP_AdminLogAction(
        adminid,
        ADMIN_LOG_OTHER,
        targetPlayer,
        logMessage
    );

    CRP_ReportArchive(index);

    return 1;
}


// ============================================================
// REPORT TIMEOUT
// ============================================================

public CRP_AdminProcessReportTimeout()
{
    new now = gettime();

    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportStatus[i] != REPORT_STATUS_PENDING)
        {
            continue;
        }

        if(now - gReportCreatedAt[i] < 600)
        {
            continue;
        }

        new playerid = gReportPlayer[i];

        gReportStatus[i] = REPORT_STATUS_NOT_RESPONDED;

        if(
            playerid != INVALID_PLAYER_ID &&
            CRP_AdminIsValidPlayer(playerid)
        )
        {
            SendClientMessage(
                playerid,
                COLOR_YELLOW,
                "REPORTS: Laporan anda tidak mendapat tanggapan dalam 10 menit dan telah dipindahkan ke arsip."
            );
        }

        CRP_ReportArchive(i);
    }

    return 1;
}


// ============================================================
// ADMIN LIST
// ============================================================

stock CRP_ShowAdminList(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new text[2048];
    text[0] = EOS;

    strcat(
        text,
        "Rank\tUsername\tStatus\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        // Developer is hidden from lower-ranked admins.
        if(
            CRP_AdminIsDeveloper(i) &&
            !CRP_AdminIsDeveloper(playerid)
        )
        {
            continue;
        }

        new rankname[32];
        new status[16];
        new line[128];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        if(gPlayerAdminDuty[i])
        {
            format(status, sizeof(status), "ON DUTY");
        }
        else
        {
            format(status, sizeof(status), "OFF DUTY");
        }

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\n",
            rankname,
            gPlayerAccountUsername[i],
            status
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Admin List",
        text,
        "Tutup",
        ""
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_LIST;

    return 1;
}


// ============================================================
// DUTY ONLINE
// ============================================================

stock CRP_ShowDutyOnline(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new text[2048];
    text[0] = EOS;

    strcat(
        text,
        "Rank\tUsername\tDuty\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(!CRP_AdminIsStaff(i))
        {
            continue;
        }

        if(!gPlayerAdminDuty[i])
        {
            continue;
        }

        if(
            CRP_AdminIsDeveloper(i) &&
            !CRP_AdminIsDeveloper(playerid)
        )
        {
            continue;
        }

        new rankname[32];
        new dutyText[64];
        new line[128];

        new seconds = CRP_AdminGetDutySeconds(i);
        new hours = seconds / 3600;
        new minutes = (seconds % 3600) / 60;

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        format(
            dutyText,
            sizeof(dutyText),
            "%d jam %d menit",
            hours,
            minutes
        );

        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\n",
            rankname,
            gPlayerAccountUsername[i],
            dutyText
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_DUTY,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Duty Online",
        text,
        "Tutup",
        ""
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_DUTY;

    return 1;
}


// ============================================================
// ADMINS
// ============================================================

stock CRP_ShowAdmins(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new text[2048];
    text[0] = EOS;

    strcat(
        text,
        "Rank\tUsername\n"
    );

    for(new rank = ADMIN_DEVELOPER; rank >= ADMIN_INTERN; rank--)
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!CRP_AdminIsValidPlayer(i))
            {
                continue;
            }

            if(gPlayerAdminRank[i] != rank)
            {
                continue;
            }

            if(
                CRP_AdminIsDeveloper(i) &&
                !CRP_AdminIsDeveloper(playerid)
            )
            {
                continue;
            }

            new rankname[32];
            new line[128];

            CRP_GetAdminRankName(
                rank,
                rankname,
                sizeof(rankname)
            );

            format(
                line,
                sizeof(line),
                "%s\t%s\n",
                rankname,
                gPlayerAccountUsername[i]
            );

            strcat(text, line);
        }
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ADMINS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Admins",
        text,
        "Tutup",
        ""
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ADMINS;

    return 1;
}


// ============================================================
// SET ADMIN
// ============================================================

stock CRP_ShowSetAdmin(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new maximum = CRP_GetSetAdminMaximumRank(playerid);

    if(maximum <= ADMIN_NO_STAFF)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "Admin: Anda tidak memiliki akses Set Admin."
        );

        return 1;
    }

    new text[2048];
    text[0] = EOS;

    strcat(
        text,
        "ID\tUsername\tCurrent Rank\n"
    );

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!CRP_AdminIsValidPlayer(i))
        {
            continue;
        }

        if(i == playerid)
        {
            continue;
        }

        if(CRP_AdminIsDeveloper(i))
        {
            continue;
        }

        if(gPlayerAdminRank[i] >= gPlayerAdminRank[playerid])
        {
            continue;
        }

        new rankname[32];
        new line[128];

        CRP_GetAdminRankName(
            gPlayerAdminRank[i],
            rankname,
            sizeof(rankname)
        );

        format(
            line,
            sizeof(line),
            "%d\t%s\t%s\n",
            i,
            gPlayerAccountUsername[i],
            rankname
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_SETADMIN,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Set Admin",
        text,
        "Pilih",
        "Tutup"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_SETADMIN;

    return 1;
}


// ============================================================
// LOGS
// ============================================================

stock CRP_ShowAdminLogs(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    if(gPlayerAdminRank[playerid] < ADMIN_ADMIN_DIRECTOR)
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "Admin: Logs hanya dapat diakses Rank 8 ke atas."
        );

        return 1;
    }

    new text[4096];
    text[0] = EOS;

    strcat(
        text,
        "Latest\tTarget\tAction\n"
    );

    for(new i = MAX_ADMIN_LOGS - 1; i >= 0; i--)
    {
        if(i >= gAdminLogCount)
        {
            continue;
        }

        new prefix[16];
        new line[256];
        new targetName[MAX_PLAYER_NAME];

        CRP_GetLogPrefix(
            gAdminLogCategory[i],
            prefix,
            sizeof(prefix)
        );

        if(
            gAdminLogTarget[i] != INVALID_PLAYER_ID &&
            CRP_AdminIsValidPlayer(gAdminLogTarget[i])
        )
        {
            GetPlayerName(
                gAdminLogTarget[i],
                targetName,
                sizeof(targetName)
            );
        }
        else
        {
            format(targetName, sizeof(targetName), "-");
        }

        // Every log entry starts with a category.
        format(
            line,
            sizeof(line),
            "%s\t%s\t%s\n",
            prefix,
            targetName,
            gAdminLogText[i]
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_LOGS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Logs",
        text,
        "Tutup",
        ""
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_LOGS;

    return 1;
}


// ============================================================
// ARCHIVES
// ============================================================

stock CRP_ShowArchives(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new text[1024];

    format(
        text,
        sizeof(text),
        "Reports\n"
    );

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ARCHIVES,
        DIALOG_STYLE_LIST,
        "Admin Panel > Archives",
        text,
        "Buka",
        "Tutup"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_ARCHIVES;

    return 1;
}


// ============================================================
// REPORT ARCHIVES
// ============================================================

stock CRP_ShowReportArchives(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        return 0;
    }

    new text[4096];
    text[0] = EOS;

    strcat(
        text,
        "ID\tTarget\tStatus\n"
    );

    for(new i = MAX_ADMIN_REPORTS - 1; i >= 0; i--)
    {
        if(gReportArchiveStatus[i] == REPORT_STATUS_NONE)
        {
            continue;
        }

        new status[32];
        new line[192];

        CRP_GetReportStatusName(
            gReportArchiveStatus[i],
            status,
            sizeof(status)
        );

        format(
            line,
            sizeof(line),
            "[R:%02d]\t%s\t%s\n",
            gReportArchiveID[i],
            gReportArchiveTarget[i],
            status
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_ARCHIVE_REPORTS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Admin Panel > Archives > Reports",
        text,
        "Tutup",
        ""
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_REPORTS;

    return 1;
}


// ============================================================
// ACTIVE REPORTS
// ============================================================

stock CRP_ShowReports(playerid)
{
    new text[4096];
    text[0] = EOS;

    strcat(
        text,
        "Report ID\tName\tReason\n"
    );

    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportStatus[i] != REPORT_STATUS_PENDING)
        {
            continue;
        }

        if(
            !CRP_AdminIsStaff(playerid) &&
            gReportPlayer[i] != playerid
        )
        {
            continue;
        }

        new reporterName[MAX_PLAYER_NAME];
        new line[256];

        if(
            gReportPlayer[i] != INVALID_PLAYER_ID &&
            CRP_AdminIsValidPlayer(gReportPlayer[i])
        )
        {
            GetPlayerName(
                gReportPlayer[i],
                reporterName,
                sizeof(reporterName)
            );
        }
        else
        {
            format(
                reporterName,
                sizeof(reporterName),
                "Offline"
            );
        }

        format(
            line,
            sizeof(line),
            "[R:%02d]\t%s\t%s\n",
            gReportID[i],
            reporterName,
            gReportReason[i]
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_REPORT_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Reports",
        text,
        "Pilih",
        "Tutup"
    );

    return 1;
}


// ============================================================
// MY REPORTS
// ============================================================

stock CRP_ShowMyReports(playerid)
{
    new text[4096];
    text[0] = EOS;

    strcat(
        text,
        "Report ID\tTarget\tStatus\n"
    );

    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportStatus[i] == REPORT_STATUS_NONE)
        {
            continue;
        }

        if(gReportPlayer[i] != playerid)
        {
            continue;
        }

        new status[32];
        new line[192];

        CRP_GetReportStatusName(
            gReportStatus[i],
            status,
            sizeof(status)
        );

        format(
            line,
            sizeof(line),
            "[R:%02d]\t%s\t%s\n",
            gReportID[i],
            gReportTarget[i],
            status
        );

        strcat(text, line);
    }

    for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
    {
        if(gReportArchiveStatus[i] == REPORT_STATUS_NONE)
        {
            continue;
        }

        if(gReportArchivePlayer[i] != playerid)
        {
            continue;
        }

        new status[32];
        new line[192];

        CRP_GetReportStatusName(
            gReportArchiveStatus[i],
            status,
            sizeof(status)
        );

        format(
            line,
            sizeof(line),
            "[A:%02d]\t%s\t%s\n",
            gReportArchiveID[i],
            gReportArchiveTarget[i],
            status
        );

        strcat(text, line);
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_MYREPORTS,
        DIALOG_STYLE_TABLIST_HEADERS,
        "My Reports",
        text,
        "Tutup",
        ""
    );

    return 1;
}


// ============================================================
// CHECK
// ============================================================

stock CRP_AdminCheckPlayer(adminid, targetid)
{
    if(!CRP_AdminIsStaff(adminid))
    {
        return 0;
    }

    if(!CRP_AdminCanTarget(adminid, targetid))
    {
        SendClientMessage(
            adminid,
            COLOR_RED,
            "Admin: Anda tidak memiliki akses untuk memeriksa target tersebut."
        );

        return 1;
    }

    new rankname[32];
    new duty[16];
    new text[1024];

    CRP_GetAdminRankName(
        gPlayerAdminRank[targetid],
        rankname,
        sizeof(rankname)
    );

    if(gPlayerAdminDuty[targetid])
    {
        format(duty, sizeof(duty), "ON DUTY");
    }
    else
    {
        format(duty, sizeof(duty), "OFF DUTY");
    }

    format(
        text,
        sizeof(text),
        "Account Username: %s\nAdmin Rank: %s\nDuty: %s\nAdmin Duty Total: %d detik\nPlayer ID: %d",
        gPlayerAccountUsername[targetid],
        rankname,
        duty,
        CRP_AdminGetDutySeconds(targetid),
        targetid
    );

    ShowPlayerDialog(
        adminid,
        DIALOG_ADMIN_CHECK,
        DIALOG_STYLE_MSGBOX,
        "Account Statistics",
        text,
        "Tutup",
        ""
    );

    return 1;
}


// ============================================================
// MAIN ADMIN PANEL
// ============================================================

stock CRP_ShowAdminPanel(playerid)
{
    if(!CRP_AdminIsStaff(playerid))
    {
        SendClientMessage(
            playerid,
            COLOR_RED,
            "Admin: Anda tidak memiliki akses Admin Panel."
        );

        return 1;
    }

    new text[2048];

    if(gPlayerAdminRank[playerid] >= ADMIN_ADMIN_DIRECTOR)
    {
        format(
            text,
            sizeof(text),
            "Admin List\nDuty Online\nAdmins\nSet Admin\nLogs\nArchives"
        );
    }
    else
    {
        format(
            text,
            sizeof(text),
            "Admin List\nDuty Online\nAdmins\nArchives"
        );
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_ADMIN_MAIN,
        DIALOG_STYLE_LIST,
        "Crystal Roleplay > Admin Panel",
        text,
        "Pilih",
        "Tutup"
    );

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_MAIN;

    return 1;
}


// ============================================================
// PLAYER COMMAND
// ============================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    // --------------------------------------------------------
    // ADMIN CHAT
    // --------------------------------------------------------

    if(!strcmp(cmdtext, "/aon", true))
    {
        if(!CRP_AdminIsStaff(playerid))
        {
            return 0;
        }

        CRP_AdminDutyOn(playerid);
        return 1;
    }

    if(!strcmp(cmdtext, "/aoff", true))
    {
        if(!CRP_AdminIsStaff(playerid))
        {
            return 0;
        }

        CRP_AdminDutyOff(playerid);
        return 1;
    }

    if(!strcmp(cmdtext, "/a", true))
    {
        if(!CRP_AdminIsStaff(playerid))
        {
            return 0;
        }

        SendClientMessage(
            playerid,
            COLOR_ADMIN_CHAT,
            "Admin: Gunakan /a [pesan]."
        );

        return 1;
    }


    if(!strcmp(cmdtext, "/ap", true))
    {
        CRP_ShowAdminPanel(playerid);
        return 1;
    }


    if(!strcmp(cmdtext, "/adminpanel", true))
    {
        CRP_ShowAdminPanel(playerid);
        return 1;
    }


    if(!strcmp(cmdtext, "/reports", true))
    {
        CRP_ShowReports(playerid);
        return 1;
    }


    if(!strcmp(cmdtext, "/myreports", true))
    {
        CRP_ShowMyReports(playerid);
        return 1;
    }


    // --------------------------------------------------------
    // REPORT
    // --------------------------------------------------------

    if(!strcmp(cmdtext, "/report", true))
    {
        if(!CRP_AdminIsValidPlayer(playerid))
        {
            return 1;
        }

        ShowPlayerDialog(
            playerid,
            DIALOG_REPORT_DETAIL,
            DIALOG_STYLE_INPUT,
            "REPORTS",
            "PENTING!\nBerikan ID dan nama karakter/nomor masker dengan jelas.\n\nMasukkan target laporan:",
            "Lanjut",
            "Batal"
        );

        return 1;
    }


    // --------------------------------------------------------
    // ADMIN CHECK
    // --------------------------------------------------------

    if(!strcmp(cmdtext, "/check", true))
    {
        if(!CRP_AdminIsStaff(playerid))
        {
            return 0;
        }

        SendClientMessage(
            playerid,
            COLOR_ADMIN_CHAT,
            "Admin: Gunakan /check [ID]."
        );

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
    // ========================================================
    // ADMIN MAIN
    // ========================================================

    if(dialogid == DIALOG_ADMIN_MAIN)
    {
        if(!response)
        {
            gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;
            return 1;
        }

        if(gPlayerAdminRank[playerid] >= ADMIN_ADMIN_DIRECTOR)
        {
            switch(listitem)
            {
                case 0:
                {
                    CRP_ShowAdminList(playerid);
                }

                case 1:
                {
                    CRP_ShowDutyOnline(playerid);
                }

                case 2:
                {
                    CRP_ShowAdmins(playerid);
                }

                case 3:
                {
                    CRP_ShowSetAdmin(playerid);
                }

                case 4:
                {
                    CRP_ShowAdminLogs(playerid);
                }

                case 5:
                {
                    CRP_ShowArchives(playerid);
                }
            }
        }
        else
        {
            switch(listitem)
            {
                case 0:
                {
                    CRP_ShowAdminList(playerid);
                }

                case 1:
                {
                    CRP_ShowDutyOnline(playerid);
                }

                case 2:
                {
                    CRP_ShowAdmins(playerid);
                }

                case 3:
                {
                    CRP_ShowArchives(playerid);
                }
            }
        }

        return 1;
    }


    // ========================================================
    // ARCHIVES
    // ========================================================

    if(dialogid == DIALOG_ADMIN_ARCHIVES)
    {
        if(!response)
        {
            CRP_ShowAdminPanel(playerid);
            return 1;
        }

        if(listitem == 0)
        {
            CRP_ShowReportArchives(playerid);
        }

        return 1;
    }


    // ========================================================
    // SET ADMIN
    // ========================================================

    if(dialogid == DIALOG_ADMIN_SETADMIN)
    {
        if(!response)
        {
            CRP_ShowAdminPanel(playerid);
            return 1;
        }

        new selectedPlayer = -1;
        new count = 0;

        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!CRP_AdminIsValidPlayer(i))
            {
                continue;
            }

            if(i == playerid)
            {
                continue;
            }

            if(CRP_AdminIsDeveloper(i))
            {
                continue;
            }

            if(gPlayerAdminRank[i] >= gPlayerAdminRank[playerid])
            {
                continue;
            }

            if(count == listitem)
            {
                selectedPlayer = i;
                break;
            }

            count++;
        }

        if(selectedPlayer == -1)
        {
            return 1;
        }

        new maximum = CRP_GetSetAdminMaximumRank(playerid);

        new dialogText[1024];

        format(
            dialogText,
            sizeof(dialogText),
            "Target: %s\n\nPilih rank baru:\n\n0 - No Staff\n1 - Intern Staff\n2 - Helper\n3 - Senior Helper\n4 - Admin\n5 - Senior Admin\n6 - Supervisor Admin\n7 - High Admin\n8 - Admin Director\n9 - Server Director\n\nMaksimum rank yang dapat diberikan: %d",
            gPlayerAccountUsername[selectedPlayer],
            maximum
        );

        // Store selected target in listitem cache.
        gSelectedReportIndex[playerid] = selectedPlayer;

        ShowPlayerDialog(
            playerid,
            DIALOG_ADMIN_CHECK,
            DIALOG_STYLE_INPUT,
            "Set Admin",
            dialogText,
            "Set",
            "Batal"
        );

        return 1;
    }


    // ========================================================
    // REPORT TARGET INPUT
    // ========================================================

    if(dialogid == DIALOG_REPORT_DETAIL)
    {
        if(!response)
        {
            SendClientMessage(
                playerid,
                COLOR_GREY,
                "REPORTS: Pengiriman laporan dibatalkan."
            );

            return 1;
        }

        if(strlen(inputtext) < 1)
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "REPORTS: Target laporan tidak boleh kosong."
            );

            return 1;
        }

        format(
            gReportTarget[playerid],
            MAX_REPORT_TARGET,
            "%s",
            inputtext
        );

        ShowPlayerDialog(
            playerid,
            DIALOG_REPORT_ACTION,
            DIALOG_STYLE_INPUT,
            "REPORTS",
            "Masukkan alasan laporan:",
            "Konfirmasi",
            "Batal"
        );

        return 1;
    }


    // ========================================================
    // REPORT REASON INPUT
    // ========================================================

    if(dialogid == DIALOG_REPORT_ACTION)
    {
        if(!response)
        {
            SendClientMessage(
                playerid,
                COLOR_GREY,
                "REPORTS: Pengiriman laporan dibatalkan."
            );

            return 1;
        }

        if(strlen(inputtext) < 3)
        {
            SendClientMessage(
                playerid,
                COLOR_RED,
                "REPORTS: Alasan laporan terlalu singkat."
            );

            return 1;
        }

        new target[32];

        format(
            target,
            sizeof(target),
            "%s",
            gReportTarget[playerid]
        );

        CRP_CreateReport(
            playerid,
            target,
            inputtext
        );

        gReportTarget[playerid][0] = EOS;

        return 1;
    }


    // ========================================================
    // REPORT LIST
    // ========================================================

    if(dialogid == DIALOG_REPORT_LIST)
    {
        if(!response)
        {
            return 1;
        }

        new count = 0;
        new selected = -1;

        for(new i = 0; i < MAX_ADMIN_REPORTS; i++)
        {
            if(gReportStatus[i] != REPORT_STATUS_PENDING)
            {
                continue;
            }

            if(
                !CRP_AdminIsStaff(playerid) &&
                gReportPlayer[i] != playerid
            )
            {
                continue;
            }

            if(count == listitem)
            {
                selected = i;
                break;
            }

            count++;
        }

        if(selected == -1)
        {
            return 1;
        }

        // FIX:
        // The actual report index is cached before opening detail.
        gSelectedReportIndex[playerid] = selected;

        new detail[1024];

        new reporterName[MAX_PLAYER_NAME];

        if(
            gReportPlayer[selected] != INVALID_PLAYER_ID &&
            CRP_AdminIsValidPlayer(gReportPlayer[selected])
        )
        {
            GetPlayerName(
                gReportPlayer[selected],
                reporterName,
                sizeof(reporterName)
            );
        }
        else
        {
            format(
                reporterName,
                sizeof(reporterName),
                "Offline"
            );
        }

        format(
            detail,
            sizeof(detail),
            "Report ID: [R:%02d]\nName: %s\nTarget: %s\nReason: %s\n\nPilih tindakan:",
            gReportID[selected],
            reporterName,
            gReportTarget[selected],
            gReportReason[selected]
        );

        if(CRP_AdminIsStaff(playerid))
        {
            ShowPlayerDialog(
                playerid,
                DIALOG_REPORT_ACTION,
                DIALOG_STYLE_MSGBOX,
                "Report Review",
                detail,
                "Terima",
                "Tolak"
            );
        }

        return 1;
    }


    // ========================================================
    // REPORT ACTION
    // ========================================================

    if(dialogid == DIALOG_REPORT_ACTION)
    {
        // This dialog is also used by report reason input.
        // Report review is handled through cached report index
        // only when the cached index points to a pending report.

        new index = gSelectedReportIndex[playerid];

        if(
            CRP_AdminIsStaff(playerid) &&
            index >= 0 &&
            index < MAX_ADMIN_REPORTS &&
            gReportStatus[index] == REPORT_STATUS_PENDING
        )
        {
            if(response)
            {
                CRP_ReportAccept(playerid, index);
            }
            else
            {
                CRP_ReportReject(playerid, index);
            }

            gSelectedReportIndex[playerid] = -1;

            return 1;
        }

        return 1;
    }


    return 0;
}


// ============================================================
// PLAYER CONNECT
// ============================================================

public OnPlayerConnect(playerid)
{
    gPlayerAdminRank[playerid] = ADMIN_NO_STAFF;

    gPlayerAccountUsername[playerid][0] = EOS;

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;
    gPlayerAdminDutyTotal[playerid] = 0;

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;

    gSelectedReportIndex[playerid] = -1;

    CRP_AdminLoadAccountIdentity(playerid);

    return 1;
}


// ============================================================
// PLAYER DISCONNECT
// ============================================================

public OnPlayerDisconnect(playerid, reason)
{
    if(gPlayerAdminDuty[playerid])
    {
        gPlayerAdminDutyTotal[playerid] +=
            gettime() - gPlayerAdminDutyStart[playerid];
    }

    gPlayerAdminDuty[playerid] = false;
    gPlayerAdminDutyStart[playerid] = 0;

    gPlayerAdminRank[playerid] = ADMIN_NO_STAFF;

    gPlayerAccountUsername[playerid][0] = EOS;

    gPlayerAdminPanel[playerid] = ADMIN_PANEL_NONE;

    gSelectedReportIndex[playerid] = -1;

    return 1;
}


// ============================================================
// INITIALIZATION
// ============================================================

public OnFilterScriptInit()
{
    SetTimer(
        "CRP_AdminProcessReportTimeout",
        30000,
        true
    );

    print("============================================================");
    print(" Crystal Roleplay - Admin System v2.1");
    print(" Account Based Admin Foundation");
    print(" Admin Chat: RankName + Account Username");
    print(" Admin Chat Color: Bright Red");
    print(" Logs: AdminCmd / BotCmd");
    print(" Developer Protection: ENABLED");
    print(" Developer Log Trace: DISABLED");
    print(" Report Timeout: 10 Minutes");
    print("============================================================");

    return 1;
}


public OnFilterScriptExit()
{
    return 1;
}
