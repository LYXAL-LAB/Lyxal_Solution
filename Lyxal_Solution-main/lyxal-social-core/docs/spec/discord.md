# Spec Discord — Primitives endpoint-level (Phase 2)

Convention : `social::discord::<domaine>::<action>`. 1 primitive = 1 endpoint officiel. Pas de logique métier.

## Auth / scopes
- type: bot (Bot Token)
- scopes (OAuth si usage user) : `identify`, `email`, `guilds`, `connections`, `messages.read`, `applications.commands`, etc. Bot privilégié pour messages/channels/guild routes.

## Primitives

### Utilisateurs
- primitive: social::discord::users::get_me  
  endpoint: GET /users/@me  
  inputs: none  
  outputs: user{id, username, discriminator, avatar, flags}  
  pagination: none  
  rate_limit: per-route (X-RateLimit-*)  
  errors: INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR  
  notes: OAuth user token

- primitive: social::discord::users::list_guilds  
  endpoint: GET /users/@me/guilds  
  inputs: { before?: snowflake, after?: snowflake, limit?: int<=200 }  
  outputs: guilds[]  
  pagination: before/after  
  rate_limit: per-route  
  errors: ...  
  notes: OAuth user token

### Guilds
- primitive: social::discord::guilds::create  
  endpoint: POST /guilds  
  inputs: { name: string, icon?: dataURI, verification_level?, default_message_notifications?, roles?, channels? }  
  outputs: guild  
  pagination: none  
  rate_limit: per-route  
  errors: INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR  

- primitive: social::discord::guilds::get  
  endpoint: GET /guilds/{guild_id}  
  inputs: { guild_id: snowflake, with_counts?: bool }  
  outputs: guild  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::update  
  endpoint: PATCH /guilds/{guild_id}  
  inputs: guild settings payload  
  outputs: guild  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::delete  
  endpoint: DELETE /guilds/{guild_id}  
  inputs: { guild_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::list_channels  
  endpoint: GET /guilds/{guild_id}/channels  
  inputs: { guild_id }  
  outputs: channels[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::create_channel  
  endpoint: POST /guilds/{guild_id}/channels  
  inputs: { guild_id, name, type, topic?, bitrate?, user_limit?, rate_limit_per_user?, position?, permission_overwrites?, parent_id?, nsfw? }  
  outputs: channel  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::reorder_channels  
  endpoint: PATCH /guilds/{guild_id}/channels  
  inputs: { guild_id, positions: [{id, position}] }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::list_members  
  endpoint: GET /guilds/{guild_id}/members  
  inputs: { guild_id, limit?: int<=1000, after?: snowflake }  
  outputs: members[]  
  pagination: after  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::get_member  
  endpoint: GET /guilds/{guild_id}/members/{user_id}  
  inputs: { guild_id, user_id }  
  outputs: member  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::add_member  
  endpoint: PUT /guilds/{guild_id}/members/{user_id}  
  inputs: { guild_id, user_id, access_token, nick?, roles?, mute?, deaf? }  
  outputs: member  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::modify_member  
  endpoint: PATCH /guilds/{guild_id}/members/{user_id}  
  inputs: member patch  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::remove_member  
  endpoint: DELETE /guilds/{guild_id}/members/{user_id}  
  inputs: { guild_id, user_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::ban_member  
  endpoint: PUT /guilds/{guild_id}/bans/{user_id}  
  inputs: { guild_id, user_id, delete_message_seconds? }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::unban_member  
  endpoint: DELETE /guilds/{guild_id}/bans/{user_id}  
  inputs: { guild_id, user_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::list_bans  
  endpoint: GET /guilds/{guild_id}/bans  
  inputs: { guild_id, limit?: int, before?: snowflake, after?: snowflake }  
  outputs: bans[]  
  pagination: before/after  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::list_roles  
  endpoint: GET /guilds/{guild_id}/roles  
  inputs: { guild_id }  
  outputs: roles[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::create_role  
  endpoint: POST /guilds/{guild_id}/roles  
  inputs: { guild_id, name?, permissions?, color?, hoist?, mentionable? }  
  outputs: role  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::reorder_roles  
  endpoint: PATCH /guilds/{guild_id}/roles  
  inputs: { guild_id, roles: [{id, position}] }  
  outputs: roles[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::update_role  
  endpoint: PATCH /guilds/{guild_id}/roles/{role_id}  
  inputs: role patch  
  outputs: role  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::guilds::delete_role  
  endpoint: DELETE /guilds/{guild_id}/roles/{role_id}  
  inputs: { guild_id, role_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Channels
- primitive: social::discord::channels::get  
  endpoint: GET /channels/{channel_id}  
  inputs: { channel_id }  
  outputs: channel  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::channels::update  
  endpoint: PATCH /channels/{channel_id}  
  inputs: channel patch  
  outputs: channel  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::channels::delete  
  endpoint: DELETE /channels/{channel_id}  
  inputs: { channel_id }  
  outputs: channel (deleted)  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::channels::list_messages  
  endpoint: GET /channels/{channel_id}/messages  
  inputs: { channel_id, around?: snowflake, before?: snowflake, after?: snowflake, limit?: int<=100 }  
  outputs: messages[]  
  pagination: before/after/around  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::messages::get  
  endpoint: GET /channels/{channel_id}/messages/{message_id}  
  inputs: { channel_id, message_id }  
  outputs: message  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::messages::create  
  endpoint: POST /channels/{channel_id}/messages  
  inputs: { channel_id, content?: string, embeds?: array, components?: array, attachments?: file[], sticker_ids?: array }  
  outputs: message {id, channel_id, author, content, timestamp, attachments, embeds}  
  pagination: none  
  rate_limit: per-route  
  errors: INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR  
  notes: multipart upload supported

- primitive: social::discord::messages::edit  
  endpoint: PATCH /channels/{channel_id}/messages/{message_id}  
  inputs: { channel_id, message_id, content?, embeds?, flags? }  
  outputs: message  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::messages::delete  
  endpoint: DELETE /channels/{channel_id}/messages/{message_id}  
  inputs: { channel_id, message_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::messages::bulk_delete  
  endpoint: POST /channels/{channel_id}/messages/bulk-delete  
  inputs: { channel_id, messages: snowflake[] }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route (strict)  
  errors: ...  

### Reactions
- primitive: social::discord::reactions::add  
  endpoint: PUT /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me  
  inputs: { channel_id, message_id, emoji }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::reactions::remove  
  endpoint: DELETE /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me  
  inputs: { channel_id, message_id, emoji }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::reactions::remove_user  
  endpoint: DELETE /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/{user_id}  
  inputs: { channel_id, message_id, emoji, user_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::reactions::list  
  endpoint: GET /channels/{channel_id}/messages/{message_id}/reactions/{emoji}  
  inputs: { channel_id, message_id, emoji, after?: snowflake, limit?: int<=100 }  
  outputs: users[]  
  pagination: after  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::reactions::clear_all  
  endpoint: DELETE /channels/{channel_id}/messages/{message_id}/reactions  
  inputs: { channel_id, message_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::reactions::clear_emoji  
  endpoint: DELETE /channels/{channel_id}/messages/{message_id}/reactions/{emoji}  
  inputs: { channel_id, message_id, emoji }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Pins
- primitive: social::discord::pins::list  
  endpoint: GET /channels/{channel_id}/pins  
  inputs: { channel_id }  
  outputs: messages[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::pins::add  
  endpoint: PUT /channels/{channel_id}/pins/{message_id}  
  inputs: { channel_id, message_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::pins::remove  
  endpoint: DELETE /channels/{channel_id}/pins/{message_id}  
  inputs: { channel_id, message_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Threads
- primitive: social::discord::threads::start_from_message  
  endpoint: POST /channels/{channel_id}/messages/{message_id}/threads  
  inputs: { channel_id, message_id, name, auto_archive_duration?, rate_limit_per_user? }  
  outputs: channel(thread)  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::start  
  endpoint: POST /channels/{channel_id}/threads  
  inputs: { channel_id, name, auto_archive_duration?, type?, invitable?, rate_limit_per_user? }  
  outputs: channel(thread)  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::list_public_archived  
  endpoint: GET /channels/{channel_id}/threads/archived/public  
  inputs: { channel_id, before?: timestamp, limit?: int<=100 }  
  outputs: threads[] + has_more  
  pagination: before  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::list_private_archived  
  endpoint: GET /channels/{channel_id}/threads/archived/private  
  inputs: { channel_id, before?: timestamp, limit?: int<=100 }  
  outputs: threads[] + has_more  
  pagination: before  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::list_active  
  endpoint: GET /channels/{channel_id}/threads/active  
  inputs: { channel_id }  
  outputs: threads[] + has_more  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::add_member  
  endpoint: PUT /channels/{thread_id}/thread-members/@me  
  inputs: { thread_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::remove_member  
  endpoint: DELETE /channels/{thread_id}/thread-members/@me  
  inputs: { thread_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::threads::get_member  
  endpoint: GET /channels/{thread_id}/thread-members/{user_id}  
  inputs: { thread_id, user_id }  
  outputs: thread_member  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Webhooks
- primitive: social::discord::webhooks::create  
  endpoint: POST /channels/{channel_id}/webhooks  
  inputs: { channel_id, name, avatar? }  
  outputs: webhook  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::list_channel  
  endpoint: GET /channels/{channel_id}/webhooks  
  inputs: { channel_id }  
  outputs: webhooks[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::get  
  endpoint: GET /webhooks/{webhook_id}  
  inputs: { webhook_id }  
  outputs: webhook  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::update  
  endpoint: PATCH /webhooks/{webhook_id}  
  inputs: { webhook_id, name?, avatar?, channel_id? }  
  outputs: webhook  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::delete  
  endpoint: DELETE /webhooks/{webhook_id}  
  inputs: { webhook_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::execute  
  endpoint: POST /webhooks/{webhook_id}/{token}  
  inputs: { webhook_id, token, content?, embeds?, components?, files?, wait?, thread_id? }  
  outputs: message (if wait=true) or empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  
  notes: multipart upload supported

- primitive: social::discord::webhooks::edit_message  
  endpoint: PATCH /webhooks/{webhook_id}/{token}/messages/{message_id}  
  inputs: { webhook_id, token, message_id, content?, embeds?, components?, files? }  
  outputs: message  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::webhooks::delete_message  
  endpoint: DELETE /webhooks/{webhook_id}/{token}/messages/{message_id}  
  inputs: { webhook_id, token, message_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Invites
- primitive: social::discord::invites::create  
  endpoint: POST /channels/{channel_id}/invites  
  inputs: { channel_id, max_age?, max_uses?, temporary?, unique?, target_type?, target_user_id?, target_application_id? }  
  outputs: invite  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::invites::get  
  endpoint: GET /invites/{invite_code}  
  inputs: { invite_code, with_counts?: bool, with_expiration?: bool, guild_scheduled_event_id?: snowflake }  
  outputs: invite  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::invites::delete  
  endpoint: DELETE /invites/{invite_code}  
  inputs: { invite_code }  
  outputs: invite  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Emojis / Stickers
- primitive: social::discord::emojis::list  
  endpoint: GET /guilds/{guild_id}/emojis  
  inputs: { guild_id }  
  outputs: emojis[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::emojis::get  
  endpoint: GET /guilds/{guild_id}/emojis/{emoji_id}  
  inputs: { guild_id, emoji_id }  
  outputs: emoji  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::emojis::create  
  endpoint: POST /guilds/{guild_id}/emojis  
  inputs: { guild_id, name, image(dataURI), roles? }  
  outputs: emoji  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::emojis::update  
  endpoint: PATCH /guilds/{guild_id}/emojis/{emoji_id}  
  inputs: { guild_id, emoji_id, name?, roles? }  
  outputs: emoji  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::emojis::delete  
  endpoint: DELETE /guilds/{guild_id}/emojis/{emoji_id}  
  inputs: { guild_id, emoji_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::list_packs  
  endpoint: GET /sticker-packs  
  inputs: none  
  outputs: sticker_packs[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::list_guild  
  endpoint: GET /guilds/{guild_id}/stickers  
  inputs: { guild_id }  
  outputs: stickers[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::get  
  endpoint: GET /guilds/{guild_id}/stickers/{sticker_id}  
  inputs: { guild_id, sticker_id }  
  outputs: sticker  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::create  
  endpoint: POST /guilds/{guild_id}/stickers  
  inputs: { guild_id, name, description?, tags, file }  
  outputs: sticker  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::update  
  endpoint: PATCH /guilds/{guild_id}/stickers/{sticker_id}  
  inputs: { guild_id, sticker_id, name?, description?, tags? }  
  outputs: sticker  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stickers::delete  
  endpoint: DELETE /guilds/{guild_id}/stickers/{sticker_id}  
  inputs: { guild_id, sticker_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Scheduled Events
- primitive: social::discord::events::list  
  endpoint: GET /guilds/{guild_id}/scheduled-events  
  inputs: { guild_id, with_user_count?: bool }  
  outputs: events[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::events::create  
  endpoint: POST /guilds/{guild_id}/scheduled-events  
  inputs: { guild_id, name, scheduled_start_time, entity_type, privacy_level, channel_id?, description?, image?, scheduled_end_time?, entity_metadata? }  
  outputs: event  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::events::get  
  endpoint: GET /guilds/{guild_id}/scheduled-events/{event_id}  
  inputs: { guild_id, event_id, with_user_count?: bool }  
  outputs: event  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::events::update  
  endpoint: PATCH /guilds/{guild_id}/scheduled-events/{event_id}  
  inputs: event patch  
  outputs: event  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::events::delete  
  endpoint: DELETE /guilds/{guild_id}/scheduled-events/{event_id}  
  inputs: { guild_id, event_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::events::list_users  
  endpoint: GET /guilds/{guild_id}/scheduled-events/{event_id}/users  
  inputs: { guild_id, event_id, limit?: int<=100, with_member?: bool, before?: snowflake, after?: snowflake }  
  outputs: users[]  
  pagination: before/after  
  rate_limit: per-route  
  errors: ...  

### Stage Instances
- primitive: social::discord::stages::create  
  endpoint: POST /stage-instances  
  inputs: { channel_id, topic, privacy_level? }  
  outputs: stage_instance  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stages::get  
  endpoint: GET /stage-instances/{channel_id}  
  inputs: { channel_id }  
  outputs: stage_instance  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stages::update  
  endpoint: PATCH /stage-instances/{channel_id}  
  inputs: { channel_id, topic?, privacy_level? }  
  outputs: stage_instance  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::stages::delete  
  endpoint: DELETE /stage-instances/{channel_id}  
  inputs: { channel_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Auto Moderation
- primitive: social::discord::automod::list_rules  
  endpoint: GET /guilds/{guild_id}/auto-moderation/rules  
  inputs: { guild_id }  
  outputs: rules[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::automod::get_rule  
  endpoint: GET /guilds/{guild_id}/auto-moderation/rules/{rule_id}  
  inputs: { guild_id, rule_id }  
  outputs: rule  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::automod::create_rule  
  endpoint: POST /guilds/{guild_id}/auto-moderation/rules  
  inputs: { guild_id, name, event_type, trigger_type, trigger_metadata, actions, enabled?, exempt_roles?, exempt_channels? }  
  outputs: rule  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::automod::update_rule  
  endpoint: PATCH /guilds/{guild_id}/auto-moderation/rules/{rule_id}  
  inputs: rule patch  
  outputs: rule  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::automod::delete_rule  
  endpoint: DELETE /guilds/{guild_id}/auto-moderation/rules/{rule_id}  
  inputs: { guild_id, rule_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Audit Log
- primitive: social::discord::audit::list  
  endpoint: GET /guilds/{guild_id}/audit-logs  
  inputs: { guild_id, user_id?: snowflake, action_type?: int, before?: snowflake, limit?: int<=100 }  
  outputs: audit_log{entries, users, webhooks, integrations, threads}  
  pagination: before  
  rate_limit: per-route  
  errors: ...  

### Templates
- primitive: social::discord::templates::get  
  endpoint: GET /guilds/templates/{code}  
  inputs: { code }  
  outputs: template  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::create_from_code  
  endpoint: POST /guilds/templates/{code}  
  inputs: { code, name?, icon? }  
  outputs: guild  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::list_guild  
  endpoint: GET /guilds/{guild_id}/templates  
  inputs: { guild_id }  
  outputs: templates[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::create  
  endpoint: POST /guilds/{guild_id}/templates  
  inputs: { guild_id, name, description? }  
  outputs: template  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::sync  
  endpoint: PUT /guilds/{guild_id}/templates/{code}  
  inputs: { guild_id, code }  
  outputs: template  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::update  
  endpoint: PATCH /guilds/{guild_id}/templates/{code}  
  inputs: { guild_id, code, name?, description? }  
  outputs: template  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::templates::delete  
  endpoint: DELETE /guilds/{guild_id}/templates/{code}  
  inputs: { guild_id, code }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Voice / Regions
- primitive: social::discord::voice::list_regions  
  endpoint: GET /voice/regions  
  inputs: none  
  outputs: regions[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Commands / Interactions (Application Commands)
- primitive: social::discord::commands::list_global  
  endpoint: GET /applications/{application_id}/commands  
  inputs: { application_id }  
  outputs: commands[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::create_global  
  endpoint: POST /applications/{application_id}/commands  
  inputs: command definition  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::get_global  
  endpoint: GET /applications/{application_id}/commands/{command_id}  
  inputs: { application_id, command_id }  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::update_global  
  endpoint: PATCH /applications/{application_id}/commands/{command_id}  
  inputs: command patch  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::delete_global  
  endpoint: DELETE /applications/{application_id}/commands/{command_id}  
  inputs: { application_id, command_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::bulk_overwrite_global  
  endpoint: PUT /applications/{application_id}/commands  
  inputs: commands[] definitions  
  outputs: commands[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::list_guild  
  endpoint: GET /applications/{application_id}/guilds/{guild_id}/commands  
  inputs: { application_id, guild_id }  
  outputs: commands[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::create_guild  
  endpoint: POST /applications/{application_id}/guilds/{guild_id}/commands  
  inputs: command definition  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::get_guild  
  endpoint: GET /applications/{application_id}/guilds/{guild_id}/commands/{command_id}  
  inputs: { application_id, guild_id, command_id }  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::update_guild  
  endpoint: PATCH /applications/{application_id}/guilds/{guild_id}/commands/{command_id}  
  inputs: command patch  
  outputs: command  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::delete_guild  
  endpoint: DELETE /applications/{application_id}/guilds/{guild_id}/commands/{command_id}  
  inputs: { application_id, guild_id, command_id }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::commands::bulk_overwrite_guild  
  endpoint: PUT /applications/{application_id}/guilds/{guild_id}/commands  
  inputs: commands[] definitions  
  outputs: commands[]  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Voice States (Guild)
- primitive: social::discord::voice::get_guild_voice_states  
  endpoint: GET /guilds/{guild_id}/voice-states/{user_id}  
  inputs: { guild_id, user_id }  
  outputs: voice_state  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::voice::modify_self_voice_state  
  endpoint: PATCH /guilds/{guild_id}/voice-states/@me  
  inputs: { guild_id, channel_id?, suppress?, request_to_speak_timestamp? }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

- primitive: social::discord::voice::modify_user_voice_state  
  endpoint: PATCH /guilds/{guild_id}/voice-states/{user_id}  
  inputs: { guild_id, user_id, channel_id?, suppress? }  
  outputs: empty  
  pagination: none  
  rate_limit: per-route  
  errors: ...  

### Webhooks Events (Gateway) — référence uniquement
- Les événements Gateway (MESSAGE_CREATE, etc.) ne sont pas des endpoints HTTP ; ils restent listés pour liaison event-driven (pas de primitive HTTP).

