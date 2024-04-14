--[[
MIT LICENSE
Copyright © 2024 John Riggles

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- stop complaining about unknow Aseprite API methods
---@diagnostic disable: undefined-global
-- ignore dialogs which are defined with local names for readablity, but may be unused
---@diagnostic disable: unused-local

local preferences = {}

local function main(visibleOnly)
  -- check for active sprite
  if not app.sprite then
    return app.alert("There is no active sprite.")
  end

  app.transaction( -- set up a transaction to make this action undoable
    function()
        local sprite = app.sprite
        local currentLayer = app.layer
        local count = 0

        for i, layer in ipairs(sprite.layers) do
          if visibleOnly == false or layer.isVisible then
            app.layer = layer -- set active layer
            app.command:DuplicateLayer { target = layer } -- duplicate active layer
            app.layer.stackIndex = #sprite.layers -- move the newest layer to the top of the stack
            count = count + 1
          end
        end
        -- merge the copied layers into a single layer
        -- the number of merges will always be 1 less than the total number of original layers
        for i = 1, count - 1 do
          app.command.MergeDownLayer()
        end
        app.layer.name = "Flattened"
    end
  )
  app.refresh()
end

-- Aseprite plugin API stuff...
---@diagnostic disable-next-line: lowercase-global
function init(plugin) -- initialize extension
  preferences = plugin.preferences -- update preferences global with plugin.preferences values

  -- add "Flatten to New Layer" command to Layer menu and popup menu
  plugin:newCommand {
    id = "flattenToNewLayer",
    title = "Flatten to New Layer",
    group = "layer_merge",
    onclick = function() main(false) end -- run main function
  }
  plugin:newCommand {
    id = "flattenToNewLayer",
    title = "Flatten to New Layer",
    group = "layer_popup_merge",
    onclick = function() main(false) end, -- run main function
  }
  -- add "Flatten Visible to New Layer" command to Layer menu and popup menu
  plugin:newCommand {
    id = "flattenVisibleToNewLayer",
    title = "Flatten Visible to New Layer",
    group = "layer_merge",
    onclick = function () main(true) end -- run main function
  }
  plugin:newCommand {
    id = "flattenVisibleToNewLayer",
    title = "Flatten Visible to New Layer",
    group = "layer_popup_merge",
    onclick = function () main(true) end, -- run main function
  }
end

---@diagnostic disable-next-line: lowercase-global
function exit(plugin)
  plugin.preferences = preferences -- save preferences
  return nil
end
