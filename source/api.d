module korwin_bot.api;

import std.format;
import std.regex : matchFirst, ctRegex;

import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.web.rest;

import korwin_bot.structs;
import korwin_bot.wisdoms;

auto keySearchPhrase = ctRegex!(`.*(korwin(?!(-|\s)?piotrowska))|JKM|krul.*`, "i");

@path("/")
interface APIRoot
{
    @safe
    @bodyParam("callback") @path("/callbacks") @method(HTTPMethod.POST)
    Json receiveEvent(SlackCallback callback);
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

        if (callback.event.channel !in this.channelsInfos_)
        {
            requestHTTP(
                format(
                    "https://slack.com/api/channels.info?token=%s&channel=%s",
                    this.oAuthToken_,
                    callback.event.channel
                ),
                (scope request) {
                    request.method = HTTPMethod.GET;
                    request.headers["Content-Type"] = "application/x-www-form-urlencoded";
                },
                (scope response) {
                    this.channelsInfos_[callback.event.channel] = deserializeJson!ChannelInfo(response.readJson["channel"]);
                    logInfo("Channel %s info cached.", callback.event.channel);
                }
            );
        }

        if (matchFirst(callback.event.text, keySearchPhrase))
        {
            const auto channelInfo = this.channelsInfos_[callback.event.channel];

            if (!channelInfo.is_general && channelInfo.is_member)
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
            else
            {
                logInfo("Not a member of channel %s. Skipping.", callback.event.channel);
            }
        }
        return serializeToJson("");
    }

private:
    const string token_;
    const string oAuthToken_;
    ChannelInfo[string] channelsInfos_;
}
