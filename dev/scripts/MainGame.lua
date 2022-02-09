os.execute("CHCP 65001")

SceneRegister = require("SceneRegister")

Window  = require("@Window")
Input   = require("@Input")
Time    = require("@Time")
Graphic = require("@Graphic")

local GAME_VERSION <const> = "Dev 0.0.1"

local WINDOW_TITLE <const> = string.format(
    "Cataclysm : The Last Shelter - %s", 
    GAME_VERSION
)

local WINDOW_RECT <const> = 
{
    x = Window.DEFAULT_POS,
    y = Window.DEFAULT_POS,
    w = 640, h = 360
}

local FPS <const> = 60

local sceneCurrent = nil

local isQuitGame = false

LoadScene = function(scene_name, ...)
    if sceneCurrent then
        sceneCurrent.OnUnload()
    end
    sceneCurrent = SceneRegister[scene_name]
    sceneCurrent.OnInit(...)
end

QuitGame = function()
    isQuitGame = true
end

RegisterPool = {}

RegisterPool.ShowQuitGameConfirm = function(msg, cb_quit)
    if Window.ConfirmBox(
        Window.MSGBOX_INFO, 
        "退出游戏", msg or "确定要退出游戏吗？", 
        "退出游戏", "取消"
    ) then
        if cb_quit then cb_quit() end
        QuitGame()
    end
end

Window.Create(WINDOW_TITLE, WINDOW_RECT)

LoadScene("Menu")

while not isQuitGame do

    local timeStart = Time.GetInitTime()

    while Input.UpdateEvent() do
        sceneCurrent.OnInput(Input.GetEventType())
    end

    Window.Clear()

    sceneCurrent.OnUpdate()

    Window.Update()

    local timeEnd = Time.GetInitTime()

    if (timeEnd - timeStart < 1000 / FPS) then
        Time.Sleep(1000 / FPS - (timeEnd - timeStart))
    end

end

sceneCurrent.OnUnload(isQuitGame)