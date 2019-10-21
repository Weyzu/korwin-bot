module korwin_bot.structs;

import vibe.data.json;

struct SlackCallback
{
    string token;
    @optional string team_id;
    @optional string challenge;
    @optional string api_app_id;
    @optional MessageChannelsEvent event;
    @byName CallbackType type;
    @optional string[] authed_teams;
    @optional string[] authed_users;
    @optional string event_id;
    @optional int event_time;
}

struct MessageChannelsEvent
{
    string type;
    string channel;
    string user;
    string text;
    string ts;
    string event_ts;
    string channel_type;
}

enum CallbackType
{
    url_verification,
    event_callback
}

struct ChannelInfo
{
    string id;
    string name;
    bool is_channel;
    int created;
    string creator;
    bool is_archived;
    bool is_general;
    string name_normalized;
    bool is_shared;
    bool is_org_shared;
    bool is_member;
    bool is_private;
    bool is_mpim;
    string[] members;
}
