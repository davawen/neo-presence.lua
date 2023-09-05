#include <assert.h>
#include "discord_game_sdk.h"

struct IDiscordCore *core = NULL;
struct IDiscordActivityManager *activities = NULL;

enum EDiscordResult init() {
	struct DiscordCreateParams params = { 0 };
    DiscordCreateParamsSetDefault(&params);
    params.client_id = 998703402257240084;
    params.flags = DiscordCreateFlags_NoRequireDiscord;

    enum EDiscordResult r = DiscordCreate(DISCORD_VERSION, &params, &core);
	if (r != DiscordResult_Ok) {
		core = NULL;
		return r;
	}

	activities = core->get_activity_manager(core);

	return r;
}

enum EDiscordResult run_callbacks() {
	assert(core != NULL); // TODO: communicate null error to user

	return core->run_callbacks(core);
}

void quit() {
	if (core != NULL) core->destroy(core);
	core = NULL;
	activities = NULL;
}

typedef void (*lua_callback_t)(enum EDiscordResult result);

void update_activity_callback(void* data, enum EDiscordResult result) {
	((lua_callback_t) data)(result);
}

void set_activity(struct DiscordActivity *activity, lua_callback_t lua_callback) {
	assert(activities != NULL);

	activities->update_activity(activities, activity, lua_callback, update_activity_callback);
}
