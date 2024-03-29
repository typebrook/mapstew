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

node_keys = { "amenity", "shop", "sport", "tourism", "place", "office", "natural", "aeroway", "survey_point" }
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

	-- Write 'poi'
	local rank, class, subclass = GetPOIRank(node)
	if rank then WritePOI(node,class,subclass,rank) end

	-- Write 'tourism'
    local tourism = node:Find("tourism")
	if tourismKeys[tourism] then
		node:Layer("tourism", false)
		SetNodeId(node)
		SetNameAttributes(node)
        node:Attribute("tourism", tourism) 
        local information = node:Find("information")
        local operator = node:Find("internet_access:operator")
		if information == "mobile" and operation ~= "" then
            node:Attribute("information", information) 
            node:Attribute("internet_access:operator", operator) 
        end
		if node:Holds("ref") then
            local ref = node:Find("ref")
            node:Attribute("ref", ref)
        end
	end

	-- Write 'peak' and 'water_name'
	local natural = node:Find("natural")
	local survey_point = node:Find("survey_point")
	if natural == "peak" or natural == "volcano" or survey_point ~= "" then
		node:Layer("peak", false)
		SetEleAttributes(node)
		SetNodeId(node)
		SetNameAttributes(node)
		if node:Holds("natural") then node:Attribute("natural", natural) end
		if survey_piont ~= "" then node:Attribute("survey_point", survey_point) end
		return
	end
end

-- POI key/value pairs: based on https://github.com/openmaptiles/openmaptiles/blob/master/layers/poi/mapping.yaml
poiTags         = { aerialway = Set { "station" },
					amenity = Set { "arts_centre", "bank", "bar", "bbq", "bicycle_parking", "bicycle_rental", "biergarten", "bus_station", "cafe", "cinema", "clinic", "college", "community_centre", "courthouse", "dentist", "doctors", "embassy", "fast_food", "ferry_terminal", "fire_station", "food_court", "fuel", "grave_yard", "hospital", "ice_cream", "kindergarten", "library", "marketplace", "motorcycle_parking", "nightclub", "nursing_home", "parking", "pharmacy", "place_of_worship", "police", "post_box", "post_office", "prison", "pub", "public_building", "recycling", "restaurant", "school", "shelter", "swimming_pool", "taxi", "telephone", "theatre", "toilets", "townhall", "university", "veterinary", "waste_basket" },
					barrier = Set { "bollard", "border_control", "cycle_barrier", "gate", "lift_gate", "sally_port", "stile", "toll_booth" },
					building = Set { "dormitory" },
					highway = Set { "bus_stop" },
					historic = Set { "monument", "castle", "ruins" },
					landuse = Set { "basin", "brownfield", "cemetery", "reservoir", "winter_sports" },
					leisure = Set { "dog_park", "escape_game", "garden", "golf_course", "ice_rink", "hackerspace", "marina", "miniature_golf", "park", "pitch", "playground", "sports_centre", "stadium", "swimming_area", "swimming_pool", "water_park" },
					railway = Set { "halt", "station", "subway_entrance", "train_station_entrance", "tram_stop" },
					shop = Set { "accessories", "alcohol", "antiques", "art", "bag", "bakery", "beauty", "bed", "beverages", "bicycle", "books", "boutique", "butcher", "camera", "car", "car_repair", "carpet", "charity", "chemist", "chocolate", "clothes", "coffee", "computer", "confectionery", "convenience", "copyshop", "cosmetics", "deli", "delicatessen", "department_store", "doityourself", "dry_cleaning", "electronics", "erotic", "fabric", "florist", "frozen_food", "furniture", "garden_centre", "general", "gift", "greengrocer", "hairdresser", "hardware", "hearing_aids", "hifi", "ice_cream", "interior_decoration", "jewelry", "kiosk", "lamps", "laundry", "mall", "massage", "mobile_phone", "motorcycle", "music", "musical_instrument", "newsagent", "optician", "outdoor", "perfume", "perfumery", "pet", "photo", "second_hand", "shoes", "sports", "stationery", "supermarket", "tailor", "tattoo", "ticket", "tobacco", "toys", "travel_agency", "video", "video_games", "watches", "weapons", "wholesale", "wine" },
					sport = Set { "american_football", "archery", "athletics", "australian_football", "badminton", "baseball", "basketball", "beachvolleyball", "billiards", "bmx", "boules", "bowls", "boxing", "canadian_football", "canoe", "chess", "climbing", "climbing_adventure", "cricket", "cricket_nets", "croquet", "curling", "cycling", "disc_golf", "diving", "dog_racing", "equestrian", "fatsal", "field_hockey", "free_flying", "gaelic_games", "golf", "gymnastics", "handball", "hockey", "horse_racing", "horseshoes", "ice_hockey", "ice_stock", "judo", "karting", "korfball", "long_jump", "model_aerodrome", "motocross", "motor", "multi", "netball", "orienteering", "paddle_tennis", "paintball", "paragliding", "pelota", "racquet", "rc_car", "rowing", "rugby", "rugby_league", "rugby_union", "running", "sailing", "scuba_diving", "shooting", "shooting_range", "skateboard", "skating", "skiing", "soccer", "surfing", "swimming", "table_soccer", "table_tennis", "team_handball", "tennis", "toboggan", "volleyball", "water_ski", "yoga" },
					waterway = Set { "dock" } }

-- POI "class" values: based on https://github.com/openmaptiles/openmaptiles/blob/master/layers/poi/poi.yaml
poiClasses      = { townhall="town_hall", public_building="town_hall", courthouse="town_hall", community_centre="town_hall",
					golf="golf", golf_course="golf", miniature_golf="golf",
					fast_food="fast_food", food_court="fast_food",
					park="park", bbq="park",
					bus_stop="bus", bus_station="bus",
					subway_entrance="entrance", train_station_entrance="entrance",
					camp_site="campsite", caravan_site="campsite",
					laundry="laundry", dry_cleaning="laundry",
					supermarket="grocery", deli="grocery", delicatessen="grocery", department_store="grocery", greengrocer="grocery", marketplace="grocery",
					books="library", library="library",
					university="college", college="college",
					hotel="lodging", motel="lodging", bed_and_breakfast="lodging", guest_house="lodging", hostel="lodging", chalet="lodging", alpine_hut="lodging", dormitory="lodging",
					chocolate="ice_cream", confectionery="ice_cream",
					post_box="post",  post_office="post",
					cafe="cafe",
					school="school",  kindergarten="school",
					alcohol="alcohol_shop",  beverages="alcohol_shop",  wine="alcohol_shop",
					bar="bar", nightclub="bar",
					marina="harbor", dock="harbor",
					car="car", car_repair="car", taxi="car",
					hospital="hospital", nursing_home="hospital",  clinic="hospital",
					grave_yard="cemetery", cemetery="cemetery",
					attraction="attraction", viewpoint="attraction",
					biergarten="beer", pub="beer",
					music="music", musical_instrument="music",
					american_football="stadium", stadium="stadium", soccer="stadium",
					art="art_gallery", artwork="art_gallery", gallery="art_gallery", arts_centre="art_gallery",
					bag="clothing_store", clothes="clothing_store",
					swimming_area="swimming", swimming="swimming",
					castle="castle", ruins="castle" }
poiClassRanks   = { hospital=1, railway=2, bus=3, attraction=4, harbor=5, college=6,
					school=7, stadium=8, zoo=9, town_hall=10, campsite=11, cemetery=12,
					park=13, library=14, police=15, post=16, golf=17, shop=18, grocery=19,
					fast_food=20, clothing_store=21, bar=22 }
poiKeys         = Set { "amenity", "sport", "office", "historic", "leisure", "landuse" }
tourismKeys     = Set { "alpine_hut", "attraction", "camp_site", "caravan_site", "chalet", "guest_house", "information", "picnic_site", "viewpoint" }
waterClasses    = Set { "river", "riverbank", "stream", "canal", "drain", "ditch", "dock" }
waterwayClasses = Set { "stream", "river", "canal", "drain", "ditch" }

-- Process way tags

majorRoadValues = Set { "motorway", "trunk" }
mainRoadValues  = Set { "primary", "motorway_link", "trunk_link", "primary_link" }
midRoadValues   = Set { "secondary", "tertiary", "secondary_link", "tertiary_link" }
minorRoadValues = Set { "unclassified", "residential", "road", "living_street" }
trackValues     = Set { "cycleway", "byway", "bridleway", "track" }
bigPathValues   = Set { "footway" }
pathValues      = Set { "path", "steps" }
linkValues      = Set { "motorway_link", "trunk_link", "primary_link", "secondary_link", "tertiary_link" }

function way_function(way)
    local boundary  = way:Find("boundary")
	local building = way:Find("building")
	local waterway = way:Find("waterway")
	local water    = way:Find("water")
	local landuse  = way:Find("landuse")
	local natural  = way:Find("natural")
	local highway  = way:Find("highway")
	local service  = way:Find("service")
	local isClosed = way:IsClosed()

    if highway == "proposed" or highway == "construction" then return end

    -- administrative boundaries
    if boundary=="administrative" and not (way:Find("maritime")=="yes") then
        local admin_level = tonumber(way:Find("admin_level")) or 11
        local mz = 7
        if admin_level <5 then mz=7
        elseif admin_level>=5 and admin_level<7 then mz=8
        elseif admin_level==7 then mz=10
        elseif admin_level==8 then mz=11
        else return
        end

        way:Layer("boundary",false)
        SetWayId(way)
        way:AttributeNumeric("admin_level", admin_level)
        way:MinZoom(mz)
        SetNameAttributes(way)
    end

	-- Set 'building' and associated
	if building~="" then
		way:Layer("building", true)
        SetWayId(way)
		SetMinZoomByArea(way)
        if way:Holds("name") then
            SetNameAttributes(way)
        end
	end
    
    -- Write POI related fields
    local rank, class, subclass = GetPOIRank(way)
    if rank then WritePOI2Way(way,class,subclass,rank) end

	-- Set 'waterway' and associated
	if waterwayClasses[waterway] and not isClosed then
		if waterway == "river" and way:Holds("name") then
			way:Layer("waterway", false)
		else
			way:Layer("waterway_detail", false)
		end
        SetWayId(way)
		if way:Find("intermittent")=="yes" then way:AttributeNumeric("intermittent", 1) else way:AttributeNumeric("intermittent", 0) end
		way:Attribute("waterway", waterway)
		SetNameAttributes(way)
		SetBrunnelAttributes(way)
	elseif waterway == "dam" then way:Layer("building",isClosed)
	end

	-- Set 'water'
	if natural=="water" or water ~= "" or landuse=="reservoir" or landuse=="basin" or waterClasses[waterway] then
		if way:Find("covered")=="yes" or not isClosed then return end

		way:Layer("water",true)
        SetWayId(way)
		SetMinZoomByArea(way)
		if natural ~= ""  then way:Attribute("natural", natural) end
		if landuse ~= ""  then way:Attribute("landuse", landuse) end
		if water ~= ""    then way:Attribute("water", water)     end
		if waterway ~= "" then way:Attribute("waterway", waterway) end
		if way:Find("intermittent")=="yes" then way:Attribute("intermittent",1) end
		if way:Holds("name") then SetNameAttributes(way) end
        way:AttributeNumeric("_area", math.floor(way:Area()))

		return
	end


	-- Set 'road'
	if highway~="" then
		local minzoom = 99
        local showAnyway = false
		if majorRoadValues[highway] then  minzoom = 4 ; showAnyway = true end
		if highway == "trunk"       then  minzoom = 5
		elseif highway == "primary" then  minzoom = 7 end
		if mainRoadValues[highway]  then  minzoom = 9 ; showAnyway = true end
		if midRoadValues[highway]   then  minzoom = 12; showAnyway = true end
		if linkValues[highway]      then  minzoom = 11 end
		if minorRoadValues[highway] then  minzoom = 12 end
		if highway=="service"       then  minzoom = 12 end
		if bigPathValues[highway]   then  minzoom = 12 end
		if pathValues[highway]      then  minzoom = 13 end
		if trackValues[highway]     then  minzoom = 13 end

		-- Write to layer
		if minzoom <= 14 then
			way:Layer("road", false)
            SetWayId(way)
            if showAnyway then way:MinZoom(minzoom)
            else SetMinZoomByLength(way, minzoom) end
			way:Attribute("highway", highway)
			SetNameAttributes(way)
			-- SetBrunnelAttributes(way)

			-- for hike
			if way:Holds("trail_visibility") then way:Attribute("trail_visibility", way:Find("trail_visibility")) end
			if way:Holds("sac_scale")        then way:Attribute("sac_scale",        way:Find("sac_scale")) end

			-- ref
			if way:Holds("ref") then way:Attribute("ref", way:Find("ref")) end

			-- service
			if highway == "service" and service ~="" then way:Attribute("service", service) end

            -- access
            local access = way:Find("access")
            if access ~= "service" then way:Attribute("access", access) end

            -- oneway
			local oneway = way:Find("oneway")
			if oneway == "yes" then
				way:Attribute("oneway", oneway)
			end
		end
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
    if obj:IsRelation() then
        obj:Attribute("id", "relation/" .. obj:Id())
    else
        obj:Attribute("id", "way/" .. obj:Id())
    end
end

-- Set ele on any object
function SetEleAttributes(obj)
    local ele = obj:Find("ele")
    if ele ~= "" then
        local meter = math.floor(tonumber(ele) or 0)
        obj:AttributeNumeric("ele", meter)
    end
end

-- Set name, name_en, and name_de on any object
function SetNameAttributes(obj)
    obj:Attribute("name", obj:Find("name"))
    -- **** do transliteration
end

function SetBrunnelAttributes(obj)
	if     obj:Find("bridge") == "yes" then obj:Attribute("brunnel", "bridge")
	elseif obj:Find("tunnel") == "yes" then obj:Attribute("brunnel", "tunnel")
	elseif obj:Find("ford")   == "yes" then obj:Attribute("brunnel", "ford")
	end
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

-- Set minimum zoom level by length
function SetMinZoomByLength(way, zoom)
    local length=way:Length()
    local properZoom = 8
    if     length>ZRES9 *20 then properZoom = 9
    elseif length>ZRES10*20 then properZoom = 10
    elseif length>ZRES11*20 then properZoom = 11
    elseif length>ZRES12*20 then properZoom = 12
    elseif length>ZRES13*20 then properZoom = 13
    else                         properZoom = 14 end

    if zoom < properZoom then zoom = properZoom end
    way:MinZoom(zoom)
end

-- Write a way centroid to POI layer
function WritePOI(obj,class,subclass,rank)
	local layer = "poi"
	if rank>4 then layer="poi_detail" end
	obj:LayerAsCentroid(layer)
	SetNameAttributes(obj)
    SetNodeId(obj)
	obj:AttributeNumeric("_rank", rank)
	obj:Attribute("_class", class)
	obj:Attribute("_subclass", subclass)
end

-- Write _rank, _class and _subclass to a way
function WritePOI2Way(obj,class,subclass,rank)
	obj:AttributeNumeric("_rank", rank)
	obj:Attribute("_class", class)
	obj:Attribute("_subclass", subclass)
end

-- Calculate POIs (typically rank 1-4 go to 'poi' z12-14, rank 5+ to 'poi_detail' z14)
-- returns rank, class, subclass
function GetPOIRank(obj)
	local k,list,v,class,rank

	-- Can we find the tag?
	for k,list in pairs(poiTags) do
		if list[obj:Find(k)] then
			v = obj:Find(k)	-- k/v are the OSM tag pair
			class = poiClasses[v] or v
			rank  = poiClassRanks[class] or 25
			return rank, class, v
		end
	end

	-- Catch-all for shops
	local shop = obj:Find("shop")
	if shop~="" then return poiClassRanks['shop'], "shop", shop end

	-- Nothing found
	return nil,nil,nil
end
