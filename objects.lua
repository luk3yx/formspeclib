--
-- formspeclib default objects
--
-- These are unprefixed, however if you create a mod that registers objects,
--   it is recommended to prefix them with your mod name to prevent conflicts.
--

--
-- Raw formspec data
--
-- Parameters: data
--
-- Example 'bgcolor[#fff;true;]':
-- {
--   type = 'formspeclib:raw_formspec',
--   data = 'bgcolor[#fff;true;]',
-- }
--
-- Using this is not recommended, and it is disabled in safe mode as it can be
--   used to crash MT clients, effectively kicking an unsuspecting victim.
--
formspeclib.register_object('formspeclib:raw_formspec', function(obj, safe_mode)
    if safe_mode or type(obj.data) ~= 'string' then
        return false
    else
        return obj.data
    end
end)

--
-- A label
--
-- Parameters: x, y, align(?), text
--
-- Example 'label[1,1;Hello world!]':
-- {
--   type = 'text',
--   x = 1,
--   y = 1,
--   align = 'left',
--   text = 'Hello world!'
-- }
--
-- align can be one of 'left', 'centre'/'center', or 'vertical'. If align is
--   set to 'centre'/'center', you can also set width and height.
--
formspeclib.register_object('text', function(obj, safe_mode)
    if not obj.text or not obj.x or not obj.y then return false end
    if not obj.align then obj.align = 'left' end
    local x    = formspeclib.escape(obj.x)
    local y    = formspeclib.escape(obj.y)
    local text = formspeclib.escape(obj.text)
    if obj.align == 'left' then
        return 'label[' .. x  .. ',' .. y .. ';' .. text .. ']'
    elseif obj.align == 'centre' or obj.align == 'center' then
        -- This magical hack lets you centre/center text in formspecs.
        -- Make sure your formspec ignores 'formspeclib:ignore'.
        local width  = formspeclib.escape(obj.width  or 8)
        local height = formspeclib.escape(obj.height or 0.5)
        return 'image_button[' .. x .. ',' .. y .. ';' .. width .. ',' ..
          height .. ';' ..
            formspeclib.escape('default_dirt.png^[colorize:#343434') ..
            ';formspeclib:ignore;' .. text .. ']'
    elseif obj.align == 'vertical' then
        return 'vertlabel[' .. x  .. ',' .. y .. ';' .. text .. ']'
    else
        return false
    end
end)

--
-- An image
--
-- Parameters: x, y, width(?), height(?), image 
--
-- Example 'image[1,1;1,1;default_dirt.png]':
-- {
--   type = 'image',
--   x = 1,
--   y = 1,
--   width = 1,
--   height = 1,
--   image = 'default_dirt.png'
-- }
formspeclib.register_object('image', function(obj, safe_mode)
    if not obj.image or not obj.x or not obj.y then return false end
    local x      = formspeclib.escape(obj.x)
    local y      = formspeclib.escape(obj.y)
    local width  = formspeclib.escape(obj.width  or obj.height or 1)
    local height = formspeclib.escape(obj.height or obj.width  or 1)
    local image  = formspeclib.escape(obj.image)
    return 'image[' .. x  .. ',' .. y .. ';' .. width .. ',' .. height .. ';' ..
        image .. ']'
end)

--
-- A button
--
-- Parameters: x, y, width, height(?), name, text, quit(?), image(?)
--
-- Example 'image_button_exit[1,1;3,1;button_cancel.png;cancel;Cancel]':
-- {
--   type = 'button',
--   x = 1,
--   y = 1,
--   width = 3,
--   height = 1,
--   name = 'cancel',
--   text = 'Cancel',
--   quit = true,
--   image = 'button_cancel.png',
-- }
--
formspeclib.register_object('button', function(obj, safe_mode)
    if not obj.text or not obj.x or not obj.y or not obj.width or not obj.name then
        return false
    end
    local x    = formspeclib.escape(obj.x)
    local y    = formspeclib.escape(obj.y)
    local w    = formspeclib.escape(obj.width)
    local h    = formspeclib.escape(obj.height or 2)
    local name = formspeclib.escape(obj.name)
    local text = formspeclib.escape(obj.text)
    local t    = 'button'
    local img  = ''
    if obj.quit then
        t = t .. '_exit'
    end
    if obj.image then
        t = 'image_' .. t
        img = ';' .. formspeclib.escape(obj.image)
        if not obj.quit and not string.find(img, '.') then
            t = 'item_' .. t
        end
    end
    return t .. '[' .. x .. ',' .. y .. ';' .. w .. ',' .. h .. img .. ';' ..
        name .. ';' .. text .. ']'
end)

--
-- A text box
--
-- Parameters: x, y, width, height(?), name, label(?), default(?), password(?)
--
-- Example 'textarea[1,1;2,3;message;Yay]':
-- {
--   type = 'textbox',
--   x = 1,
--   y = 1,
--   width = 2,
--   height = 3,
--   default = 'Yay',
--   name = 'message',
-- }
formspeclib.register_object('textbox', function(obj, safe_mode)
    if not obj.x or not obj.y or not obj.width or not obj.name then
        return false
    end
    local x    = formspeclib.escape(obj.x)
    local y    = formspeclib.escape(obj.y)
    local w    = formspeclib.escape(obj.width)
    local name = formspeclib.escape(obj.name)
    local l    = formspeclib.escape(obj.label   or '')
    local def  = formspeclib.escape(obj.default or '')
    local t    = 'field'
    local img  = ''
    def = ';' .. def
    local h
    if obj.height then
        h = formspeclib.escape(obj.height)
        t = 'textarea'
    else
        h = 2
    end
    if obj.password then
      if obj.default or obj.height then
        return false
      else
        t = 'pwd' .. t
        def = ''
      end
    end
    if not obj.close_on_enter and obj.close_on_enter ~= nil then
        if t == 'field' then
            def = def .. ']field_close_on_enter[' .. name .. ';false'
        end
    end
    return t .. '[' .. x .. ',' .. y .. ';' .. w .. ',' .. h .. ';' .. name ..
        ';' .. l .. def .. ']'
end)

--
-- A combo box
--
-- Parameters: x, y, width, height(?), name, items, label(?), default(?)
--
formspeclib.register_object('combobox', function(obj, safe_mode)
    if not obj.x or not obj.y or not obj.width or not obj.name or not obj.items then
        return false
    end
    local x    = formspeclib.escape(obj.x)
    local y    = formspeclib.escape(obj.y)
    local w    = formspeclib.escape(obj.width)
    local name = formspeclib.escape(obj.name)
    local l    = formspeclib.escape(obj.label   or '')
    local def  = formspeclib.escape(obj.default or '')
    local img  = ''
    def = ';' .. def
    local h
    local t
    local i
    local items
    for i = 1, #obj.items do
        if i ~= 1 then i = i .. ';' end
        items = items .. obj.items[i]
    end
    if obj.height then
        h = formspeclib.escape(obj.height)
        t = 'textlist'
    else
        h = 2
        t = 'dropdown'
    end
    return t .. '[' .. x .. ',' .. y .. ';' .. w .. ',' .. h .. ';' .. name ..
        ';' .. l .. def .. ']'
end)

--
-- An inventory list
--
-- Parameters: location(?), name(?), x, y, width, height, start_at(?), shift_click(?)
--
formspeclib.register_object('inventory', function(obj, safe_mode)
    if not obj.x or not obj.y or not obj.width or not obj.height then
        return false
    end
    local x         = formspeclib.escape(obj.x)
    local y         = formspeclib.escape(obj.y)
    local w         = formspeclib.escape(obj.width)
    local h         = formspeclib.escape(obj.height)
    local location  = formspeclib.escape(obj.location or 'current_player')
    local name      = formspeclib.escape(obj.name     or 'main')
    local start     = formspeclib.escape(obj.start_at or '')
    if safe_mode and location ~= 'current_player' and location ~= 'context' then
        -- You are not allowed to use other locations in safe mode.
        return false
    end
    local extra = ''
    if obj.shift_click then
        extra = 'listring[' .. location .. ';' .. name .. ']'
    end
    return 'list[' .. location .. ';' .. name .. ';' .. x .. ',' .. y .. ';' ..
        w .. ',' .. h .. ';' .. start .. ']' .. extra
end)

--
-- A semitransparent box
--
-- Parameters: x, y, width, height, colour/color 
--
-- Example 'box[1,1;1,1;black]':
-- {
--   type = 'image',
--   x = 1,
--   y = 1,
--   width = 1,
--   height = 1,
--   colour = 'black'
-- }
formspeclib.register_object('box', function(obj, safe_mode)
    if (not obj.colour and not obj.color) or not obj.x or not obj.y then
        return false
    end
    local x      = formspeclib.escape(obj.x)
    local y      = formspeclib.escape(obj.y)
    local width  = formspeclib.escape(obj.width  or obj.height or 4)
    local height = formspeclib.escape(obj.height or obj.width  or 4)
    local colour = formspeclib.escape(obj.colour or obj.color)
    return 'box[' .. x  .. ',' .. y .. ';' .. width .. ',' .. height .. ';' ..
        colour .. ']'
end)

--
-- A container
--
-- Parameters: x, y, children
--
-- Each element inside the container is offset by the x and y
--
formspeclib.register_object('container', function(obj, safe_mode)
    local t = {
        {
            type = 'formspeclib:container_start',
            x = formspeclib.escape(obj.x or 0),
            y = formspeclib.escape(obj.y or 0),
        },
        (table.unpack or unpack)(obj)
    }
    table.insert(t, {type = 'formspeclib:container_end'})
    return t
end)

formspeclib.register_object('formspeclib:container_start', function(obj, safe_mode)
    if not obj.x or not obj.y then
        return false
    end
    local x         = formspeclib.escape(obj.x)
    local y         = formspeclib.escape(obj.y)
    
    obj.x = nil
    obj.y = nil
    
    return 'container[' .. x .. ',' .. y .. ']'
end)

formspeclib.register_object('formspeclib:container_end', function(obj, safe_mode)
    return 'container_end[]'
end)
