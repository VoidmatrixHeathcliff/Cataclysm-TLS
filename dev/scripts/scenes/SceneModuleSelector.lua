GUI = require("GUI")

Input   = require("@Input")
Window  = require("@Window")
OS      = require("@OS")
JSON    = require("@JSON")

local RECT_COVER <const> = {x = 240, y = 20, w = 380, h = 95}

local COLOR_FRAME <const> = {r = 200, g = 200, b = 200, a = 255}

local fontText

local textureBack
local textureBtnRefreshIdle, textureBtnRefreshDown
local textureBtnBackToMenuIdle, textureBtnBackToMenuDown
local textureBtnNextStepIdle, textureBtnNextStepDown

local listBox, textBox

local btnRefresh, btnBackToMenu, btnNextStep

local idxCurrentModule = 1

local moduleInfoList

return
{
    OnInit = function()
        fontText = Graphic.FontFile("resources/Cubic_11_1.000_R.ttf", 14)

        textureBack = Graphic.CreateTexture(Graphic.ImageFile("resources/config_back.jpg"))

        textureBtnRefreshIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Refresh_idle.png"))
        textureBtnRefreshDown = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Refresh_down.png"))
        textureBtnBackToMenuIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_BackToMenu_idle.png"))
        textureBtnBackToMenuDown = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_BackToMenu_down.png"))
        textureBtnNextStepIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_NextStep_idle.png"))
        textureBtnNextStepDown = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_NextStep_down.png"))

        local moduleNameList

        local function RefreshModuleInfoList()
            moduleInfoList = {}
            moduleNameList = OS.ListDirectory("modules")
            for _, name in ipairs(moduleNameList) do
                local fileJSON = io.open(string.format("modules/%s/meta.json", name), "r")
                table.insert(moduleInfoList, {
                    textureCover = Graphic.CreateTexture(
                        Graphic.ImageFile(string.format("modules/%s/cover.jpg", name))),
                    metaInfo = JSON.Load(fileJSON:read("*a"))
                })
                fileJSON:close()
            end
            idxCurrentModule = 1
            GUI.Remove(listBox)
            listBox = GUI.ListBox({
                rect = {x = 20, y = 20, w = 200, h = 0},
                font_text_item = fontText,
                font_page_num = fontText,
                num_item_per_page = 14,
                height_item = 22,
                text_list = moduleNameList,
                on_click = function(idx)
                    idxCurrentModule = idx
                    GUI.Remove(textBox)
                    local textDescription = string.format(
                        "模组：%s\n作者：%s\n版本：%s\n \n%s\n \n特别感谢：\n",
                        moduleInfoList[idx].metaInfo.name,
                        moduleInfoList[idx].metaInfo.author,
                        moduleInfoList[idx].metaInfo.version,
                        moduleInfoList[idx].metaInfo.description
                    )
                    for _, text in ipairs(moduleInfoList[idx].metaInfo["special-thanks"]) do
                        textDescription = textDescription .. string.format("%s\n", text)
                    end
                    textBox = GUI.TextBox({
                        rect = {x = 240, y = 122, w = 360, h = 0},
                        font = fontText,
                        text = textDescription,
                        num_line_per_page = 9,
                        height_line = 20,
                    })
                end
            })
        end

        RefreshModuleInfoList()

        btnRefresh = GUI.ImageButton({
            texture = textureBtnRefreshIdle,
            rect = {x = 290, y = 320, w = 28, h = 28},
            has_frame = true,
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                RefreshModuleInfoList()
            end,
            on_enter = function()
                Window.SetCursorStyle(Window.CURSOR_HAND)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
            end,
            on_down = function()
                RegisterPool.SOUND_MENUBTN:Play(0)
                btnRefresh.SetTexture(textureBtnRefreshDown)
            end,
            on_up = function()
                btnRefresh.SetTexture(textureBtnRefreshIdle)
            end,
        })

        btnBackToMenu = GUI.ImageButton({
            texture = textureBtnBackToMenuIdle,
            rect = {x = 360, y = 320, w = 95, h = 28},
            has_frame = true,
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                LoadScene("Menu")
            end,
            on_enter = function()
                Window.SetCursorStyle(Window.CURSOR_HAND)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
            end,
            on_down = function()
                RegisterPool.SOUND_MENUBTN:Play(0)
                btnBackToMenu.SetTexture(textureBtnBackToMenuDown)
            end,
            on_up = function()
                btnBackToMenu.SetTexture(textureBtnBackToMenuIdle)
            end,
        })

        btnNextStep = GUI.ImageButton({
            texture = textureBtnNextStepIdle,
            rect = {x = 500, y = 320, w = 62, h = 28},
            has_frame = true,
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                LoadScene("NewGameConfig", moduleInfoList[idxCurrentModule])
            end,
            on_enter = function()
                Window.SetCursorStyle(Window.CURSOR_HAND)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
            end,
            on_down = function()
                RegisterPool.SOUND_MENUBTN:Play(0)
                btnNextStep.SetTexture(textureBtnNextStepDown)
            end,
            on_up = function()
                btnNextStep.SetTexture(textureBtnNextStepIdle)
            end,
        })
    end,

    OnInput = function(event)
        GUI.OnInput(event)

        if event == Input.EVENT_QUIT then
            RegisterPool.ShowQuitGameConfirm()
        end
    end,

    OnUpdate = function()
        Graphic.RenderTexture(textureBack, RegisterPool.RECT_WINDOW)

        Graphic.RenderTexture(moduleInfoList[idxCurrentModule].textureCover, RECT_COVER)

        Graphic.SetDrawColor(COLOR_FRAME)
        Graphic.DrawRectangle(RECT_COVER)

        GUI.OnUpdate()
    end,

    OnUnload = function()
        fontText = nil

        textureBack = nil
        textureBtnRefreshIdle, textureBtnRefreshDown = nil, nil
        textureBtnBackToMenuIdle, textureBtnBackToMenuDown = nil, nil
        textureBtnNextStepIdle, textureBtnNextStepDown = nil, nil

        listBox, textBox = nil, nil

        btnRefresh, btnBackToMenu, btnNextStep = nil, nil, nil

        idxCurrentModule = 1

        GUI.Clear()
    end
}