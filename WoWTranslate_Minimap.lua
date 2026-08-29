-- WoWTranslate_Minimap.lua
-- Minimap button for WoWTranslate (Atlas pattern)
-- Left-click toggles OUTGOING translation on/off, right-click opens the
-- config panel, drag to reposition around the minimap edge.

local MINIMAP_BUTTON_RADIUS = 80
local DEFAULT_POSITION = 225  -- degrees, bottom-left area
local isDragging = false

-- ============================================================================
-- UPDATE POSITION (polar -> cartesian)
-- ============================================================================
local function UpdatePosition()
    if not WoWTranslateMinimapButton then return end
    local angle = DEFAULT_POSITION
    if WoWTranslateDB and WoWTranslateDB.minimapPos then
        angle = tonumber(WoWTranslateDB.minimapPos) or DEFAULT_POSITION
    end
    local rads = math.rad(angle)
    local x = 53 - (MINIMAP_BUTTON_RADIUS * math.cos(rads))
    local y = (MINIMAP_BUTTON_RADIUS * math.sin(rads)) - 55
    WoWTranslateMinimapButton:ClearAllPoints()
    WoWTranslateMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", x, y)
end

-- ============================================================================
-- CREATE BUTTON (single Button on Minimap, Atlas pattern)
-- ============================================================================
local button = CreateFrame("Button", "WoWTranslateMinimapButton", Minimap)
button:SetWidth(33)
button:SetHeight(33)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:EnableMouse(true)
button:SetMovable(true)
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")

-- Icon texture (scroll/note — fits "translation" theme)
local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("CENTER", button, "CENTER", 0, 0)

-- Border texture (standard minimap button border)
local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetWidth(52)
border:SetHeight(52)
border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

-- Highlight texture
local highlight = button:CreateTexture(nil, "HIGHLIGHT")
highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
highlight:SetWidth(24)
highlight:SetHeight(24)
highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
highlight:SetBlendMode("ADD")

-- ============================================================================
-- DRAG LOGIC
-- ============================================================================
button:SetScript("OnDragStart", function()
    isDragging = true
    this:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local scale = Minimap:GetScale()
        local cx, cy = GetCursorPosition()
        local uiScale = UIParent:GetScale()
        cx = cx / (scale * uiScale)
        cy = cy / (scale * uiScale)
        mx = mx / uiScale
        my = my / uiScale
        local angle = math.deg(math.atan2(cy - my, cx - mx))
        if not WoWTranslateDB then WoWTranslateDB = {} end
        WoWTranslateDB.minimapPos = angle
        UpdatePosition()
    end)
end)

button:SetScript("OnDragStop", function()
    isDragging = false
    this:SetScript("OnUpdate", nil)
end)

-- ============================================================================
-- ICON STATE (reflects whether OUTGOING translation is on or off)
-- ============================================================================
local function IsOutgoingOn()
    return WoWTranslateDB and WoWTranslateDB.outgoingEnabled and true or false
end

-- Called whenever outgoingEnabled changes, from wherever it changes:
-- this button, the settings checkbox, or /wt outgoing on|off.
function WoWTranslate_Minimap_UpdateState()
    if not icon then return end
    if IsOutgoingOn() then
        icon:SetVertexColor(1, 1, 1, 1)
    else
        icon:SetVertexColor(0.4, 0.4, 0.4, 0.7)
    end
end

-- ============================================================================
-- CLICK HANDLER
-- ============================================================================
button:SetScript("OnClick", function()
    if isDragging then return end

    if arg1 == "RightButton" then
        if WoWTranslate_ToggleConfig then
            WoWTranslate_ToggleConfig()
        end
        return
    end

    -- Left-click: flip OUTGOING translation only. This is the one people
    -- toggle constantly (e.g. to talk plainly with other English speakers),
    -- so it doesn't touch incoming translation or open the settings panel.
    if WoWTranslate_SetOutgoingEnabled then
        local newState = not IsOutgoingOn()
        -- This one call updates the DB, the send-message hook, and this
        -- button's own icon (see WoWTranslate_SetOutgoingEnabled).
        WoWTranslate_SetOutgoingEnabled(newState)

        if newState then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[WoWTranslate] Outgoing translation ON|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[WoWTranslate] Outgoing translation OFF|r")
        end

        -- Keep the settings panel's checkbox in sync if it's open.
        if WoWTranslate_RefreshConfigUI then
            WoWTranslate_RefreshConfigUI()
        end
    end
end)

-- ============================================================================
-- TOOLTIP
-- ============================================================================
button:SetScript("OnEnter", function()
    if isDragging then return end
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:AddLine("WoWTranslate")
    if IsOutgoingOn() then
        GameTooltip:AddLine("Outgoing translation: |cFF00FF00ON|r", 1, 1, 1)
    else
        GameTooltip:AddLine("Outgoing translation: |cFFFF0000OFF|r", 1, 1, 1)
    end
    GameTooltip:AddLine("Left-click: toggle outgoing translation", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Right-click: open settings", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ============================================================================
-- INITIALIZATION (called from WoWTranslate.lua after settings are loaded)
-- ============================================================================
function WoWTranslate_MinimapButton_Init()
    if not WoWTranslateDB then WoWTranslateDB = {} end
    if WoWTranslateDB.minimapPos == nil then
        WoWTranslateDB.minimapPos = DEFAULT_POSITION
    end
    UpdatePosition()
    WoWTranslate_Minimap_UpdateState()
end
