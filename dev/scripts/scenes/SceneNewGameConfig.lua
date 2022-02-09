GUI = require("GUI")

Input = require("@Input")

return
{
    OnInit = function(module_info)

    end,

    OnInput = function(event)
        GUI.OnInput(event)

        if event == Input.EVENT_QUIT then
            RegisterPool.ShowQuitGameConfirm()
        end
    end,

    OnUpdate = function()

    end,

    OnUnload = function()

    end,
}