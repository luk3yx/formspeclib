--
-- formspeclib - Better and easier formspecs for Minetest
-- Version 0.1
--
-- © 2017 by luk3yx
--

local path = minetest.get_modpath('formspeclib')
dofile(path .. '/core.lua')     -- formspeclib core
dofile(path .. '/objects.lua')  -- Default formspeclib objects
dofile(path .. '/extras.lua')   -- Easy to use pre-baked formspec chunks
