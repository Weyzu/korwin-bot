module korwin_bot.api;

import std.regex : matchFirst, ctRegex;

import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.web.rest;

import korwin_bot.wisdoms;

auto keySearchPhrase = ctRegex!(`.*(korwin(?!(-|\s)?piotrowska))|JKM|krul.*`, "i");

@path("/")
interface APIRoot
{
    @safe
    @bodyParam("callback") @path("/callbacks") @method(HTTPMethod.POST)
    Json receiveEvent(SlackCallback callback);

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
}

class API : APIRoot
{
public:
    this(const string token, const string oAuthToken)
    {
        this.token_ = token;
        this.oAuthToken_ = oAuthToken;
    }

@safe
override:
    Json receiveEvent(SlackCallback callback)
    {
        if (callback.token != this.token_)
        {
            throw new RestException(401, serializeToJson(""));
        }

        if (callback.type == CallbackType.url_verification)
        {
            return serializeToJson(["challenge": callback.challenge]);
        }

        if (matchFirst(callback.event.text, keySearchPhrase))
        {
            requestHTTP(
                "https://slack.com/api/chat.postMessage",
                (scope request) {
                    request.method = HTTPMethod.POST;
                    request.headers["Authorization"] = "Bearer " ~ this.oAuthToken_;
                    request.writeJsonBody(
                        [
                            "token": this.token_,
                            "channel": callback.event.channel,
                            "text": Wisdoms.getInstance().generate()
                        ]
                    );
                },
                (scope response) {
                    logInfo("%s", response.readJson);
                }
            );
        }
        return serializeToJson("");
    }

private:
    const string token_;
    const string oAuthToken_;
}
