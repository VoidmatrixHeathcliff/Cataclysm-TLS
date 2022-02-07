GUI = require("GUI")

Media   = require("@Media")
Graphic = require("@Graphic")
Window  = require("@Window")
Input   = require("@Input")

local COLOR_SPLASH <const> = {r = 0, g = 0, b = 0, a = 85}

local musicBack, soundBtn

local textureBack, textureTitle
local textureBtnNewGameIdle, textureBtnNewGameHover
local textureBtnLoadGameIdle, textureBtnLoadGameHover
local textureBtnSettingIdle, textureBtnSettingHover
local textureBtnQuitIdle, textureBtnQuitHover

local btnNewGame, btnLoadGame, btnSetting, btnQuit

local rectWindow = {x = 0, y = 0, w = 0, h = 0}
local rectTitle = {x = 25, y = 25, w = 0, h = 0}

local isSplashScreen = false

return
{
    OnInit = function()
        musicBack = Media.MusicFile("resources/menu_bgm.mp3")
        Media.PlayMusic(musicBack, -1)

        soundBtn = Media.SoundFile("resources/menu_btn_sound.wav")

        textureBack = Graphic.CreateTexture(Graphic.ImageFile("resources/menu_back.jpg"))
        
        textureTitle = Graphic.CreateTexture(Graphic.ImageFile("resources/menu_title.png"))
        rectTitle.w, rectTitle.h = textureTitle:Size()

        textureBtnNewGameIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_NewGame_idle.png"))
        textureBtnNewGameHover = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_NewGame_hover.png"))
        textureBtnLoadGameIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_LoadGame_idle.png"))
        textureBtnLoadGameHover = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_LoadGame_hover.png"))
        textureBtnSettingIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Setting_idle.png"))
        textureBtnSettingHover = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Setting_hover.png"))
        textureBtnQuitIdle = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Quit_idle.png"))
        textureBtnQuitHover = Graphic.CreateTexture(Graphic.ImageFile("resources/btn_Quit_hover.png"))

        rectWindow.w, rectWindow.h = Window.GetDrawableSize()

        btnNewGame = GUI.ImageButton({
            texture = textureBtnNewGameIdle,
            rect = {x = 100, y = 260, w = 125, h = 28},
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                LoadScene("ModuleSelector")
            end,
            on_enter = function()
                soundBtn:Play(0)
                Window.SetCursorStyle(Window.CURSOR_HAND)
                btnNewGame.SetTexture(textureBtnNewGameHover)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                btnNewGame.SetTexture(textureBtnNewGameIdle)
            end
        })

        btnLoadGame = GUI.ImageButton({
            texture = textureBtnLoadGameIdle,
            rect = {x = 250, y = 260, w = 125, h = 28},
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
            end,
            on_enter = function()
                soundBtn:Play(0)
                Window.SetCursorStyle(Window.CURSOR_HAND)
                btnLoadGame.SetTexture(textureBtnLoadGameHover)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                btnLoadGame.SetTexture(textureBtnLoadGameIdle)
            end
        })

        btnSetting = GUI.ImageButton({
            texture = textureBtnSettingIdle,
            rect = {x = 400, y = 260, w = 60, h = 28},
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
            end,
            on_enter = function()
                soundBtn:Play(0)
                Window.SetCursorStyle(Window.CURSOR_HAND)
                btnSetting.SetTexture(textureBtnSettingHover)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                btnSetting.SetTexture(textureBtnSettingIdle)
            end
        })

        btnQuit = GUI.ImageButton({
            texture = textureBtnQuitIdle,
            rect = {x = 490, y = 260, w = 60, h = 28},
            on_click = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                QuitGame()
            end,
            on_enter = function()
                soundBtn:Play(0)
                Window.SetCursorStyle(Window.CURSOR_HAND)
                btnQuit.SetTexture(textureBtnQuitHover)
            end,
            on_leave = function()
                Window.SetCursorStyle(Window.CURSOR_ARROW)
                btnQuit.SetTexture(textureBtnQuitIdle)
            end
        })

    end,

    OnInput = function(event)
        GUI.OnInput(event)

        if event == Input.EVENT_QUIT then
            QuitGame()
        end
    end,

    OnUpdate = function()
        Graphic.RenderTexture(textureBack, rectWindow)

        if math.random(0, 100) % 25 == 0 then
            isSplashScreen = not isSplashScreen 
        end
        if isSplashScreen then
            Graphic.SetDrawColor(COLOR_SPLASH)
            Graphic.DrawRectangle(rectWindow, true)
        end

        Graphic.RenderTexture(textureTitle, rectTitle)

        GUI.OnUpdate()
    end,

    OnUnload = function()
        Media.StopMusic()
        
        musicBack, soundBtn = nil, nil

        textureBack, textureTitle = nil, nil
        textureBtnNewGameIdle, textureBtnNewGameHover = nil, nil
        textureBtnLoadGameIdle, textureBtnLoadGameHover = nil, nil
        textureBtnSettingIdle, textureBtnSettingHover = nil, nil
        textureBtnQuitIdle, textureBtnQuitHover = nil, nil

        btnNewGame, btnLoadGame, btnSetting, btnQuit = nil, nil, nil, nil

        GUI.Clear()
    end
}