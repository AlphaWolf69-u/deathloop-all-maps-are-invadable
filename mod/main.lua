-- All maps are invadable for Deathloop Mod Manager.
local allowed = {}
local function district(folder, stem, times, suffix)
    for _, t in ipairs(times) do
        local n = string.format('%02d', t)
        allowed['maps/campaign/'..folder..'/'..folder..'_'..n..'/'..stem..'_'..n..suffix..'.map'] = true
    end
end
district('antenna', 'antenna', {1,2,3,4}, '_p')
district('island', 'island', {1,2,3}, '_p')
district('upper_city', 'uppercity', {1,2,3,4}, '_p')
district('wharf', 'wharf', {1,3,4}, '')
local q,u,b = game.read_u64,game.read_u32,game.read_u8
local function str(a) local p=q(a); if p==0 then return '' end; return game.read_string(p,512) end
local function registry(off)
    local r=game.base+off; local n=u(r+0x5C); assert(n<=256,'Unexpected registry count')
    local a=q(r+0x50); local out={}
    for i=0,n-1 do out[#out+1]=q(a+i*8) end
    return out
end
return function()
    local rows,maps,missions = {},{},{}
    local function add(a,v)
        local old=b(a); assert(old==0 or old==1,'Unexpected invasion flag')
        rows[a]={address=a,expected=old,value=v}
    end
    local function lists(start)
        for t=0,4 do
            local s=start+t*16; local n=u(s+12); assert(n<=64,'Unexpected mission list')
            local a=q(s)
            for i=0,n-1 do
                local p=a+i*120; local path=str(p+0x40)
                if allowed[path] then add(p+0x69,1); missions[path]=true end
            end
        end
    end
    local found=false
    assert(game.campaign_registry and game.map_registry and game.world_pointer, 'Requires Mod Manager 0.3.2 or later')
    for _,p in ipairs(registry(game.campaign_registry)) do
        if str(p+8)=='game/campaign/global_campaign_manager.campaignmanager' then lists(p+0x610); found=true end
    end
    assert(found,'Campaign declarations not loaded yet')
    for _,p in ipairs(registry(game.map_registry)) do
        local path=str(p+0x98)
        if allowed[path] then assert(u(p+0x1A0)==127,'Unexpected game modes'); add(p+0x1AC,0); maps[path]=true end
    end
    for path in pairs(allowed) do assert(maps[path] and missions[path],'District not loaded: '..path) end
    local world=q(game.base+game.world_pointer)
    if world~=0 then local campaign=q(world+0x34D8); if campaign~=0 then lists(campaign+0x1C940) end end
    local transaction={}
    for _,row in pairs(rows) do transaction[#transaction+1]=row end
    game.write_flags(transaction)
    return 'All 14 district/time maps enabled'
end
