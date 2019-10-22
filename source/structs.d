module korwin_bot.structs;

import std.meta;

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
    @optional string user;
    string text;
    string ts;
    string event_ts;
    @byName ChannelType channel_type;
}

enum CallbackType
{
    url_verification,
    event_callback
}

enum ChannelType
{
    channel,
    group
}

struct Conversation
{
    string id;
    string name;
    bool is_channel;
    bool is_group;
    bool is_im;
    int created;
    string creator;
    bool is_archived;
    bool is_general;
    int unlinked;
    string name_normalized;
    @optional bool is_read_only;
    bool is_shared;
    bool is_ext_shared;
    bool is_org_shared;
    bool is_pending_ext_shared;
    bool is_member;
    bool is_private;
    bool is_mpim;
    string last_read;
    @optional string[] previous_names;
    @optional int num_members;
    @optional string locale;
}
