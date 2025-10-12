local input_file = io.open("./input.txt")

if input_file ~= nil then
    while true do
        line = input_file:read("l")
        if line == nil then
            break
        end
        print(line)
    end
end

map = {}

function map_from_lines(fh)
    return nil
end