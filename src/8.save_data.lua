function get_furthest_level()
    if dget(0) == nil then return 1 end
    return dget(0)
end

function update_furthest_level(level_number)
    if level_number > get_furthest_level() then
        dset(0, level_number)
    end
end

-- settings: (1) colorblind mode (2) game speed (3) clear save [clear furthest level]