local list = core.get_mod_storage()
local unit_to_secs = {
	s = 1, m = 60, h = 3600,
	D = 86400, W = 604800, M = 2592000, Y = 31104000,
	[""] = 1,
}
local function parse_time(t)
	local secs = 0
	for num, unit in t:gmatch("(%d+)([smhDWMY]?)") do
		secs = secs + (tonumber(num) * (unit_to_secs[unit] or 1))
	end
	return secs
end
core.register_on_prejoinplayer(function(name, ip)
    local reason = list:get_string(name)
    local date = reason:match("until %d+")
    if date then date = date:gsub("until ","") end
    local now = os.date("%s")
    if reason and reason ~= "" and not date then
        return "ZBanned permanently for a reason: "..reason
    end
    if reason and reason ~= "" and date then
        if tonumber(date) > tonumber(now) then
            return "ZBanned until "..os.date("%c", date).." for a reason: "..reason:gsub(" |.+","")
        else
            list:set_string(name,"")
            core.unban_player_or_ip(name)
        end
    end
end)
core.register_chatcommand("zban",{
    description = "ZBan a player",
    privs = {ban=true},
    params = "<name> <reason>",
    func = function(name,param)
        local player,reason = param:match("^(%S+) (.+)$")
        if not player and not reason then return false, "Invalid params" end
        if player == "$zban_history" then return false, "Unallowed nickname" end
        core.ban_player(player)
        core.kick_player(player,"ZBanned permanently for a reason: "..reason)
        list:set_string(player,reason)
        if zban_history then
            zban_history.save(player,os.date().." ZBanned by "..name.." for a reason: "..reason)
        end
        return true, "ZBanned "..player
end})
core.register_chatcommand("ztban",{
    description = "Temporarily ZBan a player",
    privs = {ban=true},
    params = "<name> <duration> <reason>",
    func = function(name,param)
        local player,duration,reason = param:match("^(%S+) (%S+) (.+)$")
        if not player and not reason then return false, "Invalid params" end
        time = parse_time(duration)
		if time < 60 then
			return false, "Error: Minimum ban duration is 60 seconds."
		end
		local expires = os.time() + time
        core.ban_player(player)
        core.kick_player(player,"ZBanned until "..os.date("%c", expires).." for a reason: "..reason)
        list:set_string(player,reason.." | until "..expires)
        if zban_history then
            zban_history.save(player,os.date().." ZBanned until "..os.date("%c", expires).." by "..name.." for a reason: "..reason)
        end
        return true, "ZBanned "..player.." until "..os.date("%c", expires)
end})
core.register_chatcommand("zuban",{
    description = "ZUnban a player",
    privs = {ban=true},
    params = "<name>",
    func = function(name,param)
        list:set_string(param,"")
        core.unban_player_or_ip(param)
        if zban_history then
            zban_history.save(param,os.date().." ZUnbanned by "..name)
        end
        return true, "ZUnbanned "..param
end})
core.register_chatcommand("zbanned",{
    description = "Show list of ZBanned players",
    privs = {ban=true},
    func = function(name,param)
        local msg = "ZBanned: "
        local table = list:to_table().fields
        for nick,val in pairs(table) do
            local expires = val:match("until %d+")
            if expires then
                local time = expires:gsub("until ","")
                local date = os.date("%c",time)
                val = val:gsub("until %d+","until "..date)
            end
            msg = msg..nick.." ("..val.."),  "
        end
        return true, msg
end})
