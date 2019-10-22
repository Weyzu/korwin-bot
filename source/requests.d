module krowin_bot.requests;

import std.format;

import vibe.core.log;
import vibe.data.json;
import vibe.http.client;

import korwin_bot.structs;


class SlackWebAPIClient
{
@safe:
public:
    this(const string token, const string oAuthToken)
    {
        this.token_ = token;
        this.oAuthToken_ = oAuthToken;
    }

    Conversation requestConversationInfo(const string channelId)
    {
        Conversation info;

        requestHTTP(
            format(
                "https://slack.com/api/conversations.info?token=%s&channel=%s",
                this.oAuthToken_,
                channelId
            ),
            (scope request) {
                request.method = HTTPMethod.GET;
                request.headers["Content-Type"] = "application/x-www-form-urlencoded";
            },
            (scope response) {
                const auto parsedResponse = response.readJson;
                logDebug("Received response: %s", parsedResponse);
                info = deserializeJson!Conversation(parsedResponse["channel"]);
            }
        );

        return info;
    }

    void postMessage(const string channelId, const string message)
    {
        requestHTTP(
            "https://slack.com/api/chat.postMessage",
            (scope request) {
                request.method = HTTPMethod.POST;
                request.headers["Authorization"] = "Bearer " ~ this.oAuthToken_;
                request.writeJsonBody(
                    [
                        "token": this.token_,
                        "channel": channelId,
                        "text": message
                    ]
                );
            },
            (scope response) {
                logDebug("Received response: %s", response.readJson);
            }
        );
    }

    @property const(string) token() { return this.token_; }

private:
    const string token_;
    const string oAuthToken_;
}
