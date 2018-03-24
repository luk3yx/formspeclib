--
-- formspeclib pre-baked objects
--
-- Making formspecs even more fun!
--

--
-- formspeclib:player_inventory - The current player's inventory
--
-- Syntax: x, y
--
formspeclib.register_object('formspeclib:player_inventory', function(obj, safe_mode)
    if type(obj.y) ~= 'number' then return false end
    return {{
        type = 'inventory',
        x = obj.x,
        y = obj.y,
        width = 8,
        height = 1,
        location = 'current_player',
        name = 'main',
        shift_click = true,
    },
    {
        type = 'inventory',
        x = obj.x,
        y = obj.y + 1.23,
        width = 8,
        height = 3,
        location = 'current_player',
        name = 'main',
        start_at = 8,
    }}
end)

--
-- formspeclib:node_inventory - The current node's inventory
--
-- Syntax: x, y, width(?), height(?), name(?)
--
formspeclib.register_object('formspeclib:node_inventory', function(obj, safe_mode)
    return {{
        type = 'inventory',
        x = obj.x,
        y = obj.y,
        width = obj.width or 8,
        height = obj.height or 4,
        location = 'context',
        name = obj.name or 'main',
        shift_click = true,
    }}
end)

--
-- formspeclib:chest - Most useful with chest touchscreens.
--
-- Syntax: x(?), y(?), width(?), height(?)
--
formspeclib.register_object('formspeclib:chest', function(obj, safe_mode)
    local r = not obj.x and not obj.y
    
    if type(obj.x) ~= 'number' then obj.x = 0 end
    if type(obj.y) ~= 'number' then obj.y = 0 end
    if type(obj.width) ~= 'number' then obj.width = 8 end
    if type(obj.height) ~= 'number' then obj.height = 4 end
    
    return {
        width = r and obj.width,
        height = r and obj.height + 5,
        {
            type = 'formspeclib:node_inventory',
            x = obj.x,
            y = obj.y + 0.3,
            width = obj.width,
            height = obj.height,
            name = obj.name,
        },
        {
            type = 'formspeclib:player_inventory',
            x = obj.x + (obj.width / 2) - 4,
            y = obj.y + obj.height + 0.82,
        },
    }
end)
