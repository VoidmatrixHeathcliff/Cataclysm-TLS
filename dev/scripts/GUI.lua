Input   = require("@Input")
Graphic = require("@Graphic")

local FUNC_EMPTY <const> = function() end

local COLOR_BLACK       <const> = {r = 55, g = 55, b = 55, a = 255}
local COLOR_GRAY        <const> = {r = 100, g = 100, b = 100, a = 255}
local COLOR_WHITE       <const> = {r = 200, g = 200, b = 200, a = 255}

local COLOR_GRAYBLUE    <const> = {r = 108, g = 132, b = 141, a = 255}

local COLOR_TRANSWHITE  <const> = {r = 255, g = 255, b = 255, a = 100}

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

    ele.GetPosition = function()
        return ele._rect.x, ele._rect.y
    end

    ele.GetSize = function()
        return ele._rect.w, ele._rect.h
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

    ele.Transform = function(rect)
        self._rect.x = rect.x or self._rect.x
        self._rect.y = rect.y or self._rect.y
        self._rect.w = rect.w or self._rect.w
        self._rect.h = rect.h or self._rect.h
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
    Remove = function(ele)
        for i = #elementList, 1, -1 do
            if elementList[i] == ele then
                table.remove(elementList, i)
                break
            end
        end
    end,

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

        ele.OnUpdate = function()
            Graphic.RenderTexture(ele._texture, ele._rect)
        end

        ele.SetTexture = function(new_texture)
            ele._texture = new_texture
        end

        table.insert(elementList, ele)
        return ele
    end,

    ListBox = function(params)
        local ele = BaseElement()

        ele._rect = params.rect or {x = 0, y = 0, w = 250, h = 0}
        ele._rect_valid = {x = ele._rect.x + 5, y = ele._rect.y, w = ele._rect.w - 10, h = ele._rect.h}
        ele._font_text_item = params.font_text_item
        ele._font_page_num = params.font_page_num
        ele._num_item_per_page = params.num_item_per_page or 10
        ele._height_item = params.height_item or 40
        ele._text_list = params.text_list or {"无内容"}
        ele._on_click = params.on_click or FUNC_EMPTY

        ele._idx_page, ele._idx_item = 1, 1
        ele._rect.h = ele._num_item_per_page * ele._height_item
        ele._rect_valid.h = ele._rect.h
        ele._is_down_btn_prev, ele._is_down_btn_next = false, false
        ele._rect_btn_prev = {
            x = ele._rect.x,
            y = ele._rect.y + ele._rect.h,
            w = 40,
            h = 20
        }
        ele._rect_btn_next = {
            x = ele._rect.x + ele._rect.w - ele._rect_btn_prev.w, 
            y = ele._rect_btn_prev.y, 
            w = ele._rect_btn_prev.w, 
            h = ele._rect_btn_prev.h
        }
        ele._rect_zone_page_num = {
            x = ele._rect.x + ele._rect_btn_prev.w, 
            y = ele._rect_btn_prev.y,
            w = ele._rect.w - 2 * ele._rect_btn_prev.w,
            h = ele._rect_btn_prev.h
        }
        ele._points_btn_prev = {
            {
                x = ele._rect_btn_prev.x + ele._rect_btn_prev.w * 0.3, 
                y = ele._rect_btn_prev.y + ele._rect_btn_prev.h * 0.5
            },
            {
                x = ele._rect_btn_prev.x + ele._rect_btn_prev.w * 0.7,
                y = ele._rect_btn_prev.y + ele._rect_btn_prev.h * 0.2
            },
            {
                x = ele._rect_btn_prev.x + ele._rect_btn_prev.w * 0.7,
                y = ele._rect_btn_prev.y + ele._rect_btn_prev.h * 0.8
            }
        }
        ele._points_btn_next = {
            {
                x = ele._rect_btn_next.x + ele._rect_btn_next.w * 0.7, 
                y = ele._rect_btn_next.y + ele._rect_btn_next.h * 0.5
            },
            {
                x = ele._rect_btn_next.x + ele._rect_btn_next.w * 0.3,
                y = ele._rect_btn_next.y + ele._rect_btn_next.h * 0.2
            },
            {
                x = ele._rect_btn_next.x + ele._rect_btn_next.w * 0.3,
                y = ele._rect_btn_next.y + ele._rect_btn_next.h * 0.8
            }
        }
        ele._total_page_num = math.ceil(#ele._text_list / ele._num_item_per_page)
        ele._texture_list_text_item = {}
        for _, text in ipairs(ele._text_list) do
            table.insert(
                ele._texture_list_text_item, 
                Graphic.CreateTexture(
                    Graphic.TextImageQuality(
                        ele._font_text_item,
                        text,
                        COLOR_WHITE
                    )
                )
            )
        end
        ele._texture_list_page_num = {}
        for i = 1, ele._total_page_num do
            table.insert(
                ele._texture_list_page_num, 
                Graphic.CreateTexture(
                    Graphic.TextImageQuality(
                        ele._font_page_num, 
                        string.format("%d/%d", i, ele._total_page_num), 
                        COLOR_WHITE
                    )
                )
            )
        end
        ele._is_enable_btn_prev = false
        ele._is_enable_btn_next = not (ele._idx_page == ele._total_page_num)

        ele.OnInput = function(event)
            if event == Input.EVENT_MOUSEBTNDOWN then
                if Input.GetMouseButtonID() == Input.MOUSEBTN_LEFT then
                    if CheckCursorInRect(ele._rect_valid) then
                        local idxPageItem = math.ceil((posCursorY - ele._rect_valid.y) / ele._height_item)
                        local idxListItem = (ele._idx_page - 1) * ele._num_item_per_page + idxPageItem
                        if idxListItem <= #ele._text_list then
                            ele._on_click(idxListItem)
                            ele._idx_item = idxPageItem
                        end
                    else
                        if ele._is_enable_btn_prev and CheckCursorInRect(ele._rect_btn_prev) then
                            ele._is_down_btn_prev = true
                        elseif ele._is_enable_btn_next and CheckCursorInRect(ele._rect_btn_next) then
                            ele._is_down_btn_next = true
                        end
                    end
                end
            elseif event == Input.EVENT_MOUSEBTNUP then
                if ele._is_down_btn_prev then
                    ele._is_down_btn_prev = false
                    if ele._is_enable_btn_prev then
                        ele._idx_page = ele._idx_page - 1
                        ele._is_enable_btn_prev = not (ele._idx_page == 1)
                        ele._is_enable_btn_next = not (ele._idx_page == ele._total_page_num)
                        ele._idx_item = 1
                        ele._on_click((ele._idx_page - 1) * ele._num_item_per_page + 1)                       
                    end
                elseif ele._is_down_btn_next then
                    ele._is_down_btn_next = false
                    if ele._is_enable_btn_next then
                        ele._idx_page = ele._idx_page + 1
                        ele._is_enable_btn_prev = not (ele._idx_page == 1)
                        ele._is_enable_btn_next = not (ele._idx_page == ele._total_page_num)
                        ele._idx_item = 1
                        ele._on_click((ele._idx_page - 1) * ele._num_item_per_page + 1)
                    end
                end
            end
        end

        ele.OnUpdate = function()
            Graphic.SetDrawColor(COLOR_BLACK)
            Graphic.DrawRectangle(ele._rect, true)

            Graphic.SetDrawColor(COLOR_GRAYBLUE)
            Graphic.DrawRectangle(
                {
                    x = ele._rect.x,
                    y = ele._rect_valid.y + (ele._idx_item - 1) * ele._height_item, 
                    w = ele._rect.w, 
                    h = ele._height_item
                },
                true
            )

            for i = 1, ele._num_item_per_page do
                local idxItem = (ele._idx_page - 1) * ele._num_item_per_page + i
                if idxItem > #ele._text_list then break end
                local width, height = ele._texture_list_text_item[idxItem]:Size()
                local rectDst = {
                    x = ele._rect_valid.x, y = ele._rect_valid.y + (i - 1) * ele._height_item,
                    w = math.min(width, ele._rect_valid.w), h = ele._height_item
                }
                local rectSrc = {x = 0, y = 0, w = ele._rect_valid.w, h = height}
                if ele._height_item > height then
                    rectDst.y = rectDst.y + (ele._height_item - height) / 2
                    rectDst.h = height
                end
                Graphic.RenderTexture(ele._texture_list_text_item[idxItem], rectDst, rectSrc)
            end

            Graphic.SetDrawColor(COLOR_WHITE)
            Graphic.DrawRectangle(ele._rect)

            if ele._is_down_btn_prev then
                Graphic.SetDrawColor(COLOR_GRAY)
                Graphic.DrawRectangle(ele._rect_btn_prev, true)
                Graphic.SetDrawColor(COLOR_WHITE)
                Graphic.DrawTriangle(ele._points_btn_prev[1], 
                    ele._points_btn_prev[2], ele._points_btn_prev[3], true)
            else
                Graphic.SetDrawColor(COLOR_WHITE)
                Graphic.DrawRectangle(ele._rect_btn_prev, true)
                Graphic.SetDrawColor(COLOR_BLACK)
                Graphic.DrawTriangle(ele._points_btn_prev[1],
                    ele._points_btn_prev[2], ele._points_btn_prev[3], true)
            end
            if not ele._is_enable_btn_prev then
                Graphic.SetDrawColor(COLOR_TRANSWHITE)
                Graphic.DrawRectangle(ele._rect_btn_prev, true)
            end

            if ele._is_down_btn_next then
                Graphic.SetDrawColor(COLOR_GRAY)
                Graphic.DrawRectangle(ele._rect_btn_next, true)
                Graphic.SetDrawColor(COLOR_WHITE)
                Graphic.DrawTriangle(ele._points_btn_next[1], 
                    ele._points_btn_next[2], ele._points_btn_next[3], true)
            else
                Graphic.SetDrawColor(COLOR_WHITE)
                Graphic.DrawRectangle(ele._rect_btn_next, true)
                Graphic.SetDrawColor(COLOR_BLACK)
                Graphic.DrawTriangle(ele._points_btn_next[1], 
                    ele._points_btn_next[2], ele._points_btn_next[3], true)
            end
            if not ele._is_enable_btn_next then
                Graphic.SetDrawColor(COLOR_TRANSWHITE)
                Graphic.DrawRectangle(ele._rect_btn_next, true)
            end
            
            Graphic.SetDrawColor(COLOR_GRAY)
            Graphic.DrawRectangle(ele._rect_zone_page_num, true)

            local width, height = ele._texture_list_page_num[ele._idx_page]:Size()
            Graphic.RenderTexture(ele._texture_list_page_num[ele._idx_page], {
                x = ele._rect_zone_page_num.x + (ele._rect_zone_page_num.w - width) / 2,
                y = ele._rect_zone_page_num.y + (ele._rect_zone_page_num.h - height) / 2,
                w = width, h = height
            })
        end
    
        ele._on_click(1)

        table.insert(elementList, ele)
        return ele
    end,

    TextBox = function(params)
        local ele = BaseElement()

        ele._rect = params.rect or {x = 0, y = 0, w = 250, h = 0}
        ele._rect_valid = {x = ele._rect.x + 5, y = ele._rect.y, w = ele._rect.w - 10, h = ele._rect.h}
        ele._font = params.font
        ele._num_line_per_page = params.num_line_per_page or 10
        ele._height_line = params.height_line or 40
        ele._text = params.text or ""

        ele.OnInput = FUNC_EMPTY

        ele.OnUpdate = function()

        end
    end
}