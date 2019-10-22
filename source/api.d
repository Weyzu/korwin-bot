module korwin_bot.api;

import std.format;
import std.regex : matchFirst, ctRegex;

import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.web.rest;

import krowin_bot.requests;
import korwin_bot.structs;
import korwin_bot.wisdoms;

auto keySearchPhrase = ctRegex!(`.*(korwin(?!(-|\s)?piotrowska))|JKM|krul.*`, "i");

@path("/")
interface APIRoot
{
    @bodyParam("callback") @path("/callbacks") @method(HTTPMethod.POST)
    Json receiveEvent(SlackCallback callback);
}

class API : APIRoot
{
public:
    this(const string token, const string oAuthToken)
    {
        this.slackApiClient_ = new SlackWebAPIClient(token, oAuthToken);
    }

override
{
    Json receiveEvent(SlackCallback callback)
    {
        logDebug("Callback: %s", callback.serializeToJsonString());

        if (callback.token != this.slackApiClient_.token)
        {
            throw new RestException(401, serializeToJson(""));
        }

        if (callback.type == CallbackType.url_verification)
        {
            return serializeToJson(["challenge": callback.challenge]);
        }

        if (callback.event.channel !in this.conversationInfos_)
        {
            this.conversationInfos_[callback.event.channel] = this.slackApiClient_.requestConversationInfo(callback.event.channel);
            logInfo("Channel %s info cached.", callback.event.channel);
        }

        if (matchFirst(callback.event.text, keySearchPhrase))
        {
            const Conversation conversationInfo = this.conversationInfos_[callback.event.channel];

            if (!conversationInfo.is_general && conversationInfo.is_member)
            {
                this.slackApiClient_.postMessage(
                    callback.event.channel,
                    Wisdoms.getInstance().generate()
                );
            }
            else
            {
                logInfo(
                    "Channel '%s' of team '%s' not suitable for posting. Skipping.",
                    callback.event.channel,
                    callback.team_id
                );
            }
        }
        return serializeToJson("");
    }
}

private:
    SlackWebAPIClient slackApiClient_;
    Conversation[string] conversationInfos_;
}
