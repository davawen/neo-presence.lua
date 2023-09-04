#include <assert.h>
#include "discord_game_sdk.h"

#define DISCORD_REQUIRE(x) assert(x == DiscordResult_Ok)

void DISCORD_CALLBACK UpdateActivityCallback(void* data, enum EDiscordResult result)
{
    DISCORD_REQUIRE(result);
}

struct IDiscordUserEvents users_events = { 0 };
struct IDiscordActivityEvents activities_events = { 0 };
struct IDiscordRelationshipEvents relationships_events = { 0 };

struct IDiscordCore *core;
struct IDiscordActivityManager *activities;

void init() {
	struct DiscordCreateParams params = { 0 };
    DiscordCreateParamsSetDefault(&params);
    params.client_id = 998703402257240084;
    params.flags = DiscordCreateFlags_Default;
    params.activity_events = &activities_events;
    params.relationship_events = &relationships_events;
    params.user_events = &users_events;

    DISCORD_REQUIRE(DiscordCreate(DISCORD_VERSION, &params, &core));

	activities = core->get_activity_manager(core);
}

void set_activity(struct DiscordActivity *activity) {
	activities->update_activity(activities, activity, NULL, UpdateActivityCallback);
}

void run_callbacks() {
	DISCORD_REQUIRE(core->run_callbacks(core));
}

void quit() {
	activities->clear_activity(activities, NULL, UpdateActivityCallback);
}
