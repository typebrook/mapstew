-- Enter/exit Tilemaker
function init_function()
end
function exit_function()
end

-- Implement Sets in tables
function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

-- Meters per pixel if tile is 256x256
ZRES5  = 4891.97
ZRES6  = 2445.98
ZRES7  = 1222.99
ZRES8  = 611.5
ZRES9  = 305.7
ZRES10 = 152.9
ZRES11 = 76.4
ZRES12 = 38.2
ZRES13 = 19.1

-- Process node tags

-- Process node/way tags
aerodromeValues = Set { "international", "public", "regional", "military", "private" }

-- Process node tags

node_keys = { "amenity", "shop", "sport", "tourism", "place", "office", "natural", "aeroway" }
function node_function(node)
    -- Write 'place'
    local place = node:Find("place")
    if place ~= "" then
        local rank = nil
        local mz = 13
        local pop = tonumber(node:Find("population")) or 0

        if     place == "continent"     then mz=0
        elseif place == "country"       then
            if     pop>50000000 then mz=1
            elseif pop>20000000 then mz=2
            else                     mz=3 end
        elseif place == "state"         then mz=4
        elseif place == "city"          then mz=5
        elseif place == "town" and pop>8000 then mz=7
        elseif place == "town"          then mz=8
        elseif place == "village" and pop>2000 then mz=9
        elseif place == "village"       then mz=10
        elseif place == "suburb"        then mz=11
        elseif place == "hamlet"        then mz=12
        elseif place == "neighbourhood" then mz=13
        elseif place == "locality"      then mz=13
        end

        node:Layer("place", false)
        SetNodeId(node)
        node:MinZoom(mz)
        if place=="country" then node:Attribute("iso_a2", node:Find("ISO3166-1:alpha2")) end
        node:Attribute("place", place)
        SetNameAttributes(node)
        return
    end
end

-- Process way tags

function way_function(way)
    local boundary  = way:Find("boundary")

    -- administrative boundaries
    if boundary=="administrative" and not (way:Find("maritime")=="yes") then
        local admin_level = tonumber(way:Find("admin_level")) or 11
        local mz = 7
        if admin_level>=5 and admin_level<7 then mz=8
        elseif admin_level==7 then mz=10
        elseif admin_level==8 then mz=11
        elseif admin_level>=8 then mz=12
        end

        way:Layer("boundary",false)
        SetWayId(way)
        way:AttributeNumeric("admin_level", admin_level)
        way:MinZoom(mz)
        SetNameAttributes(way)
    end

end

-- Remap coastlines
function attribute_function(attr)
    return { 
        admin_level=attr.admin,
        name=attr.name
    }
end

-- ==========================================================
-- Common functions

-- Set ID on node object
function SetNodeId(obj)
       obj:Attribute("id", "node/" .. obj:Id())
end

--  Set ID on way object
function SetWayId(obj)
    obj:Attribute("id", "way/" .. obj:Id())
end

-- Set ele and ele_ft on any object
function SetEleAttributes(obj)
    local ele = obj:Find("ele")
    if ele ~= "" then
        local meter = math.floor(tonumber(ele) or 0)
        local feet = math.floor(meter * 3.2808399)
        obj:AttributeNumeric("ele", meter)
        obj:AttributeNumeric("ele_ft", feet)
    end
end

-- Set name, name_en, and name_de on any object
function SetNameAttributes(obj)
    obj:Attribute("name", obj:Find("name"))
    -- **** do transliteration
end

-- Set minimum zoom level by area
function SetMinZoomByArea(way)
    local area=way:Area()
    if     area>ZRES5^2  then way:MinZoom(6)
    elseif area>ZRES6^2  then way:MinZoom(7)
    elseif area>ZRES7^2  then way:MinZoom(8)
    elseif area>ZRES8^2  then way:MinZoom(9)
    elseif area>ZRES9^2  then way:MinZoom(10)
    elseif area>ZRES10^2 then way:MinZoom(11)
    elseif area>ZRES11^2 then way:MinZoom(12)
    elseif area>ZRES12^2 then way:MinZoom(13)
    else                      way:MinZoom(14) end
end
