GUI = require("GUI")

Input   = require("@Input")
Window  = require("@Window")
OS      = require("@OS")
JSON    = require("@JSON")

local RECT_COVER <const> = {x = 240, y = 16, w = 380, h = 150}

local COLOR_FRAME <const> = {r = 200, g = 200, b = 200, a = 255}

local textureBack

local idxCurrentModule = 1

local rectWindow = {x = 0, y = 0, w = 0, h = 0}

local font = Graphic.FontFile("resources/Cubic_11_1.000_R.ttf", 15)

local moduleInfoList = {}

return
{
    OnInit = function()
        textureBack = Graphic.CreateTexture(Graphic.ImageFile("resources/config_back.jpg"))

        rectWindow.w, rectWindow.h = Window.GetDrawableSize()

        local moduleNameList = OS.ListDirectory("modules")
        for _, name in ipairs(moduleNameList) do
            local fileJSON = io.open(string.format("modules/%s/meta.json", name), "r")
            table.insert(moduleInfoList, {
                textureCover = Graphic.CreateTexture(
                    Graphic.ImageFile(string.format("modules/%s/cover.jpg", name))
                ),
                metaInfo = JSON.Load(fileJSON:read("*a"))
            })
            fileJSON:close()
        end

        GUI.ListBox({
            rect = {x = 20, y = 16, w = 200, h = 0},
            font_text_item = font,
            font_page_num = font,
            num_item_per_page = 14,
            height_item = 22,
            text_list = moduleNameList,
            on_click = function(idx)
                idxCurrentModule = idx
            end
        })
    end,

    OnInput = function(event)
        GUI.OnInput(event)

        if event == Input.EVENT_QUIT then
            if Window.ConfirmBox(
                Window.MSGBOX_INFO, 
                "退出游戏", "确定要退出游戏吗？", 
                "返回标题页", "退出游戏"
            ) then
                LoadScene("Menu")
            else
                QuitGame()
            end
        end
    end,

    OnUpdate = function()
        Graphic.RenderTexture(textureBack, rectWindow)

        Graphic.RenderTexture(moduleInfoList[idxCurrentModule].textureCover, RECT_COVER)

        Graphic.SetDrawColor(COLOR_FRAME)
        Graphic.DrawRectangle(RECT_COVER)

        GUI.OnUpdate()
    end,

    OnUnload = function()
        GUI.Clear()

        textureBack = nil

        idxCurrentModule = 1
    end
}