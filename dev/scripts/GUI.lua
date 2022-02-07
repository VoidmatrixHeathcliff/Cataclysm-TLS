Input   = require("@Input")
Graphic = require("@Graphic")

local FUNC_EMPTY <const> = function() end

local elementList = {}

local posCursorX, posCursorY = 0, 0

local function CheckCursorInRect(rect)
    return posCursorX >= rect.x
        and posCursorX <= rect.x + rect.w
        and posCursorY >= rect.y
        and posCursorY <= rect.y + rect.h
end

local BaseElement = function()
    local ele = {}

    ele.Transform = function(rect)
        self._rect.x = rect.x or self._rect.x
        self._rect.y = rect.y or self._rect.y
        self._rect.w = rect.w or self._rect.w
        self._rect.h = rect.h or self._rect.h
    end

    ele.GetPosition = function()
        return {x = ele._rect.x, y = ele._rect.y}
    end

    ele.GetSize = function()
        return {w = ele._rect.w, h = ele._rect.h}
    end

    return ele
end

local BaseButton = function(params)
    local ele = BaseElement()
    ele._texture = params.texture
    ele._rect = params.rect or {x = 0, y = 0, w = 135, h = 75}
    ele._on_enter = params.on_enter or FUNC_EMPTY
    ele._on_leave = params.on_leave or FUNC_EMPTY
    ele._on_click = params.on_click or FUNC_EMPTY
    ele._is_hover = false

    ele.OnInput = function(event)
        if event == Input.EVENT_MOUSEMOTION then
            local isHover = CheckCursorInRect(ele._rect)
            if isHover and not ele._is_hover then
                ele._on_enter()
            elseif not isHover and ele._is_hover then
                ele._on_leave()
            end
            ele._is_hover = isHover
        elseif event == Input.EVENT_MOUSEBTNUP and ele._is_hover
            and Input.GetMouseButtonID() == Input.MOUSEBTN_LEFT then
            ele._on_click()
        end
    end

    ele.OnUpdate = function()
        Graphic.RenderTexture(ele._texture, ele._rect)
    end

    ele.SetOnEnter = function(func)
        ele._on_enter = func
    end

    ele.SetOnLeave = function(func)
        ele._on_leave = func
    end

    ele.SetOnClick = function(func)
        ele._on_click = func
    end

    return ele
end

return
{
    Clear = function()
        elementList = {}
    end,

    Dump = function()
        return elementList
    end,

    Load = function(ele_list)
        elementList = ele_list
    end,

    OnInput = function(event)
        if event == Input.EVENT_MOUSEMOTION then
            posCursorX, posCursorY = Input.GetCursorPosition()
        end
        for _, ele in pairs(elementList) do
            ele.OnInput(event)
        end
    end,

    OnUpdate = function()
        for _, ele in pairs(elementList) do
            ele.OnUpdate()
        end
    end,

    ImageButton = function(params)
        local ele = BaseButton(params)

        ele.SetTexture = function(new_texture)
            ele._texture = new_texture
        end

        table.insert(elementList, ele)
        return ele
    end,
}