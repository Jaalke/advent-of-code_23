local input_file = io.open("./input.txt")

if input_file ~= nil then

    function map_from_lines(fh)
        map = {}
        while true do
            line = fh:read("l")
            if line == nil or line == "" then
                return map
            end
            _, _, target, origin, length = string.find(line, "(%d+)%s(%d+)%s(%d+)")
            entry = {origin_min=tonumber(origin), origin_max=origin + length - 1, target=tonumber(target), length=tonumber(length)}
            table.insert(map, entry)
        end
    end

    function location_from_seed(seed, maps)
        location = seed
        for _, map in ipairs(maps) do
            for _, mapping in ipairs(map) do
                if mapping["origin_min"] <= location and mapping["origin_max"] >= location then
                    location = mapping["target"] + (location - mapping["origin_min"])
                    break
                end
            end
        end
        return location
    end


    seeds = {}
    maps = {}
    locations = {}


    -- Parsing the input to get the seeds,
    seed_line = input_file:read("L")
    for s in string.gmatch(seed_line, "%d+") do
        table.insert(seeds, tonumber(s))
    end

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

    -- Passing each seed through the maps to get location
    for _, seed in ipairs(seeds) do
        table.insert(locations, location_from_seed(seed, maps))
    end

    -- Sorting the locations and returning the lowest one as the answer
    table.sort(locations)
    print("Lowest location: ", locations[1])
end