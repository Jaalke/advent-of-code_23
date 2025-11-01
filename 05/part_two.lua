local input_file = io.open("./input.txt")

if input_file ~= nil then

    function seed_ranges_from_line(seeds, seed_ranges, line)

        mt = {
            __lt = function(a,b)
                return a["min"] < b["min"]
            end
        }

        for s in string.gmatch(line, "%d+%s%d+") do
            _, _, origin, length = string.find(s, "(%d+)%s(%d+)")
            range = {min = tonumber(origin), max = origin + length - 1}
            setmetatable(range, mt)
            table.insert(seed_ranges, range)
            table.insert(seeds, range["min"])
            table.insert(seeds, range["max"])
        end
    end

    function map_from_lines(fh)
        map = {}
        while true do
            line = fh:read("l")
            if line == nil or line == "" then
                return map
            end
            _, _, target, origin, length = string.find(line, "(%d+)%s(%d+)%s(%d+)")

            entry = {origin_min=tonumber(origin), 
            origin_max=origin + length - 1, 
            target_min=tonumber(target), 
            target_max=target + length - 1, 
            length=tonumber(length)}
            
            table.insert(map, entry)
        end
    end

    function location_from_seed(seed, maps)
        location = seed
        for _, map in ipairs(maps) do
            for _, mapping in ipairs(map) do
                if mapping["origin_min"] <= location and mapping["origin_max"] >= location then
                    location = mapping["target_min"] + (location - mapping["origin_min"])
                    break
                end
            end
        end
        return location
    end

    function seed_from_arbitrary(n, layer, maps) -- Finding argument of critical point
        seed = n
        for i = layer - 1, 1, -1 do 
            for _, mapping in ipairs(maps[i]) do
                if mapping["target_min"] <= seed and mapping["target_max"] >= seed then
                    seed = mapping["origin_min"] + (seed - mapping["target_min"])
                    break
                end
            end
        end
        return seed
    end


    seed_ranges = {}
    critical_points = {}
    maps = {}
    seeds = {}


    -- Parsing the input to get the seeds (as ranges),
    seed_line = input_file:read("L")
    seed_ranges_from_line(seeds, seed_ranges, seed_line)

    -- and the maps.
    while true do
        line = input_file:read("l")
        if line == nil then
            break
        elseif string.find(line, ":") ~= nil then
            map = map_from_lines(input_file)
            table.insert(maps, map)
        end
    end

    -- Finding the map-critical points:
    -- (these are the locations around which the derivative of location(seed) changes)
    for i, map in ipairs(maps) do
        for _, mapping in ipairs(map) do
            table.insert(critical_points, seed_from_arbitrary(mapping["origin_min"], i, maps))
            table.insert(critical_points, seed_from_arbitrary(mapping["origin_max"], i, maps))
        end
    end

    min_loc = math.huge

    table.sort(critical_points)
    table.sort(seed_ranges)

    -- Filtering out the critical points outside of existing seed ranges
    crit_i = 1
    seed_i = 1
    while crit_i <= #critical_points and seed_i <= #seed_ranges do
        crit = critical_points[crit_i]
        range = seed_ranges[seed_i]
        if crit >= range["min"] and crit <= range["max"] then
            table.insert(seeds, crit)
            crit_i = crit_i + 1
        elseif crit > range["max"] then
            seed_i = seed_i + 1 -- No more crits in this range
        else 
            crit_i = crit_i + 1 -- Crit not in any of the ranges
        end
    end

    -- Looping through all possible candidates for lowest location (critical points
    -- and seed range endpoints i.e. domain endpoints)
    for _, seed in ipairs(seeds) do
        location = location_from_seed(seed, maps)
        if location < min_loc then
            min_loc = location
        end
    end

    print("Lowest location: ", min_loc)

end