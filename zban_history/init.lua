zban_history = {}
local hist = core.get_mod_storage()

function zban_history.save(player,text)
    hist:set_string(player,hist:get_string(player)..text.."\n")
end

core.register_chatcommand("zbanhist",{
    description = "Show history of ZBanned player, add `-t` for text-only format",
    privs = {ban=true},
    params = "<playername> [-t]",
    func = function(name,param)
        local player = param:match("%S+")
        if not player then return false, "Erro: No Player!" end
        local textonly = param:match(" %-t")
        if textonly then
            return true, hist:get_string(player)
        else
            core.show_formspec(name,"zbanhist","size[16,9]" ..
"textarea[0.4,0.3;15.7,10;New TextArea;Ban history of "..player..":;"..hist:get_string(player).."]")
        end
end})
