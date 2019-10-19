import vibe.core.args;
import vibe.core.core;
import vibe.http.router;
import vibe.web.rest;

import korwin_bot.api : API;
import korwin_bot.wisdoms;

void main()
{
	auto routes = new URLRouter;
	auto settings = new HTTPServerSettings();
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	auto token = readRequiredOption!string("token", "Slack APP token");
	auto oAuthToken = readRequiredOption!string("oauth", "Slack OAuth2 token");

	Wisdoms.getInstance().load(
		readRequiredOption!string("wisdom-path", "Path to TXT file containing JKM's wisdoms")
	);
	registerRestInterface(routes, new API(token, oAuthToken));
	listenHTTP(settings, routes);
	runApplication();
}
