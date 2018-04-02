--
-- formspeclib core - Better and easier formspecs for Minetest
--
-- © 2017 by luk3yx
--

-- This is only the core rendering process.

formspeclib = {}

local objects = {}

-- formspeclib.version: The version of formspeclib.
formspeclib.version = 0.1

--
-- formspeclib.render(): Renders a formspeclib object into a formspec.
-- 
-- Syntax: formspeclib.render(formspeclib_object, safe_mode, no_iterations)
--
--  formspeclib_object: The formspeclib object to render.
--  safe_mode:          Optional. If it is enabled, the renderer does safety
--                        checks so the server does not crash.
--  no_iterations:      Optional, not recommended. Only allows formspeclib
--                        objects that produce a direct formspec string.
--
formspeclib.render = function(formspec, safe_mode, no_iterations)
    if safe_mode and type(formspec) ~= 'table' then
        -- Don't throw an error, just don't render the formspec.
        return false
    end
    local compiled = ''
    local i
    local width
    local height
    if type(formspec.width) == 'number' then
        width = formspec.width
    else
        width = 0
    end
    if type(formspec.height) == 'number' then
        height = formspec.height
    else
        height = 0
    end
    if type(no_iterations) ~= 'number' and no_iterations then
        no_iterations = 1
    end
    for i = 1, #formspec do
        if safe_mode and type(formspec[i]) ~= 'table' then
            return false
        elseif not formspec[i].type then
            -- The formspec is defining the global width/height.
            if type(formspec[i].width) == 'number' then
                width = obj.width
            end
            if type(formspec[i].height) == 'number' then
                height = obj.height
            end
        elseif objects[formspec[i].type] then
            local a
            local o
            if safe_mode then
                a, o = pcall(objects[formspec[i].type], formspec[i], safe_mode)
                if not a then o = false end
            else
                o = objects[formspec[i].type](formspec[i], safe_mode)
            end
            if type(o) == 'string' then
                compiled = compiled .. o
            elseif type(o) == 'table' then
                if no_iterations and no_iterations < 1 then return false end
                local iter
                if no_iterations then
                    iter = no_iterations - 1
                elseif safe_mode then
                    iter = 3
                end
                o = formspeclib.render(o, safe_mode, iter)
                if not o then return false end
                compiled = compiled .. o
            else
                return false
            end
        else
            -- On unknown element
            return false
        end
    end
    if width > 0 and height > 0 then
        -- The below three lines are here to ensure compatibility with Minetest
        --   0.4.X. When the variables are removed from minetest_game they will
        --   simply be ignored by the mod.
        if default and default.gui_bg and default.gui_bg_img and default.gui_slots then
            compiled = default.gui_bg .. default.gui_bg_img .. default.gui_slots .. compiled
        end
        compiled = 'size[' ..
                        tostring(width) .. ',' .. tostring(height) ..
                   ']' .. compiled
    end
    return compiled
end

--
-- formspeclib.register_object(): Create a formspeclib object
--
-- Syntax: formspeclib.register_object(name, function)
--
-- name: The name of the object (set in 'type'). It is recommended to make this
--         'mod:object' unless you are overriding an object.
-- func: The function to generate the object. This function gets sent the
--         formspec chunk to generate, and will return a string or formspeclib
--         formspec, otherwise false to indicate an error.
--
formspeclib.register_object = function(name, func)
    if type(func) ~= 'function' then
        return false
    end
    objects[name] = func
    return true
end

--
-- formspeclib.escape(): Escape and stringify text.
--
-- This may seem useless, but it is actually quite useful.
--
formspeclib.escape = function(text)
    return minetest.formspec_escape(tostring(text))
end
