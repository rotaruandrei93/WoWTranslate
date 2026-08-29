-- WoWTranslate_Config.lua
-- Configuration UI panel for WoWTranslate 2.0

-- ============================================================================
-- LANGUAGES
-- ============================================================================
local LANGUAGES = {
    { code = "zh", name = "Chinese" },
    { code = "en", name = "English" },
    { code = "ko", name = "Korean" },
    { code = "ja", name = "Japanese" },
    { code = "ru", name = "Russian" },
    { code = "de", name = "German" },
    { code = "fr", name = "French" },
    { code = "es", name = "Spanish" },
    { code = "pt", name = "Portuguese" },
}

local function GetLanguageIndex(code)
    for i = 1, table.getn(LANGUAGES) do
        if LANGUAGES[i].code == code then
            return i
        end
    end
    return 1
end

local function GetLanguageName(code)
    for i = 1, table.getn(LANGUAGES) do
        if LANGUAGES[i].code == code then
            return LANGUAGES[i].name
        end
    end
    return code
end

-- ============================================================================
-- TEMP CONFIG
-- ============================================================================
WoWTranslate_TempConfig = {}

local function LoadTempConfig()
    WoWTranslate_TempConfig = {}
    if not WoWTranslateDB then return end
    for k, v in pairs(WoWTranslateDB) do
        if type(v) == "table" then
            WoWTranslate_TempConfig[k] = {}
            for k2, v2 in pairs(v) do
                WoWTranslate_TempConfig[k][k2] = v2
            end
        else
            WoWTranslate_TempConfig[k] = v
        end
    end
end

local function SaveTempConfig()
    if not WoWTranslate_TempConfig then return end
    for k, v in pairs(WoWTranslate_TempConfig) do
        if type(v) == "table" then
            if not WoWTranslateDB[k] then
                WoWTranslateDB[k] = {}
            end
            for k2, v2 in pairs(v) do
                WoWTranslateDB[k][k2] = v2
            end
        else
            WoWTranslateDB[k] = v
        end
    end
end

-- ============================================================================
-- CREATE MAIN FRAME
-- ============================================================================
local configFrame = CreateFrame("Frame", "WoWTranslateConfigFrame", UIParent)
configFrame:Hide()
configFrame:SetWidth(440)
configFrame:SetHeight(780) -- placeholder; recalculated to fit content at the bottom of the LAYOUT section below
configFrame:SetPoint("CENTER", 0, 0)
configFrame:SetMovable(true)
configFrame:EnableMouse(true)
configFrame:SetClampedToScreen(true)
configFrame:SetFrameStrata("DIALOG")

configFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
configFrame:SetBackdropColor(0, 0, 0, 1)

configFrame:SetScript("OnMouseDown", function()
    this:StartMoving()
end)

configFrame:SetScript("OnMouseUp", function()
    this:StopMovingOrSizing()
end)

local title = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", configFrame, "TOP", 0, -20)
title:SetText("WoWTranslate 2.0 Configuration")

local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function()
    configFrame:Hide()
end)

tinsert(UISpecialFrames, "WoWTranslateConfigFrame")

configFrame.elements = {}

-- ============================================================================
-- UI HELPERS
-- ============================================================================
local function CreateHeader(text, yPos)
    local header = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 25, yPos)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0)
    return header
end

local function CreateCheckbox(label, xPos, yPos, configKey, subKey)
    local wrapper = CreateFrame("Frame", nil, configFrame)
    wrapper:SetPoint("TOPLEFT", configFrame, "TOPLEFT", xPos, yPos)
    wrapper:SetWidth(200)
    wrapper:SetHeight(24)
    wrapper.configKey = configKey
    wrapper.subKey = subKey

    local cb = CreateFrame("CheckButton", nil, wrapper, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 0, 0)

    local text = wrapper:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)

    cb:SetScript("OnClick", function()
        local parent = this:GetParent()
        local key = parent.configKey
        local sub = parent.subKey
        local enabled = (this:GetChecked() and true) or false

        if key == "outgoingEnabled" then
            WoWTranslate_SetOutgoingEnabled(enabled)
            WoWTranslate_TempConfig.outgoingEnabled = enabled
        elseif key == "enabled" then
            WoWTranslate_SetIncomingEnabled(enabled)
            WoWTranslate_TempConfig.enabled = enabled
        elseif key == "outgoingChannels" and sub then
            WoWTranslate_SetChannelEnabled(sub, enabled)
            if not WoWTranslate_TempConfig.outgoingChannels then
                WoWTranslate_TempConfig.outgoingChannels = {}
            end
            WoWTranslate_TempConfig.outgoingChannels[sub] = enabled
        elseif key == "incomingChannels" and sub then
            WoWTranslate_SetIncomingChannelEnabled(sub, enabled)
            if not WoWTranslate_TempConfig.incomingChannels then
                WoWTranslate_TempConfig.incomingChannels = {}
            end
            WoWTranslate_TempConfig.incomingChannels[sub] = enabled
        else
            if sub then
                if not WoWTranslate_TempConfig[key] then
                    WoWTranslate_TempConfig[key] = {}
                end
                WoWTranslate_TempConfig[key][sub] = enabled
                if not WoWTranslateDB[key] then
                    WoWTranslateDB[key] = {}
                end
                WoWTranslateDB[key][sub] = enabled
            else
                WoWTranslate_TempConfig[key] = enabled
                WoWTranslateDB[key] = enabled
            end
        end
    end)

    cb.wrapper = wrapper
    return cb
end

local function CreateLangSelector(label, xPos, yPos, configKey, totalWidth)
    -- Single-row layout (label, arrows, display all inline) so every
    -- selector in the panel looks and behaves the same way.
    totalWidth = totalWidth or 170
    local frame = CreateFrame("Frame", nil, configFrame)
    frame:SetPoint("TOPLEFT", configFrame, "TOPLEFT", xPos, yPos)
    frame:SetWidth(totalWidth)
    frame:SetHeight(26)

    local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lbl:SetPoint("LEFT", 0, 0)
    lbl:SetWidth(42)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(label)

    local leftBtn = CreateFrame("Button", nil, frame)
    leftBtn:SetPoint("LEFT", lbl, "RIGHT", 2, 0)
    leftBtn:SetWidth(20)
    leftBtn:SetHeight(20)
    leftBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    leftBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    leftBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    local display = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    display:SetPoint("LEFT", leftBtn, "RIGHT", 4, 0)
    display:SetWidth(totalWidth - 42 - 20 - 20 - 12)
    display:SetJustifyH("CENTER")
    display:SetText("Language")

    local rightBtn = CreateFrame("Button", nil, frame)
    rightBtn:SetPoint("LEFT", display, "RIGHT", 4, 0)
    rightBtn:SetWidth(20)
    rightBtn:SetHeight(20)
    rightBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    rightBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    rightBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    frame.display = display
    frame.configKey = configKey

    leftBtn:SetScript("OnClick", function()
        local parent = this:GetParent()
        local code = WoWTranslate_TempConfig[parent.configKey] or "zh"
        local idx = GetLanguageIndex(code) - 1
        if idx < 1 then idx = table.getn(LANGUAGES) end
        WoWTranslate_TempConfig[parent.configKey] = LANGUAGES[idx].code
        parent.display:SetText(LANGUAGES[idx].name)
    end)

    rightBtn:SetScript("OnClick", function()
        local parent = this:GetParent()
        local code = WoWTranslate_TempConfig[parent.configKey] or "zh"
        local idx = GetLanguageIndex(code) + 1
        if idx > table.getn(LANGUAGES) then idx = 1 end
        WoWTranslate_TempConfig[parent.configKey] = LANGUAGES[idx].code
        parent.display:SetText(LANGUAGES[idx].name)
    end)

    return frame
end

-- ============================================================================
-- LAYOUT
-- ============================================================================
-- Built from a single running cursor (instead of hand-picked pixel offsets)
-- so spacing stays consistent and the frame height below is always exactly
-- as tall as the content actually is.
local y = -46

-- No Provider/Azure section here: this build ships a WoWTranslate.ini next
-- to the DLL, pre-configured with the Azure key, so translation works with
-- zero in-game setup (see the "defaults" comment in WoWTranslate.lua).
-- Advanced users who want a different provider still have /wt provider,
-- /wt googlekey, /wt azurekey, etc.

CreateHeader("Incoming Translation (Chat -> You)", y)
y = y - 26
configFrame.elements.inEnabled = CreateCheckbox("Enable Incoming", 25, y, "enabled", nil)
configFrame.elements.afkDisable = CreateCheckbox("Disable while AFK", 220, y, "disableWhileAfk", nil)
y = y - 26
configFrame.elements.translateSystem = CreateCheckbox("Translate system/emotes", 25, y, "translateSystemMessages", nil)
y = y - 30
configFrame.elements.inFrom = CreateLangSelector("From:", 25, y, "incomingFromLang", 175)
configFrame.elements.inTo = CreateLangSelector("To:", 210, y, "incomingToLang", 175)

y = y - 28
local inChLabel = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
inChLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 25, y)
inChLabel:SetText("Incoming Channels:")
y = y - 26
configFrame.elements.inChSay = CreateCheckbox("Say", 25, y, "incomingChannels", "SAY")
configFrame.elements.inChYell = CreateCheckbox("Yell", 140, y, "incomingChannels", "YELL")
configFrame.elements.inChWhisper = CreateCheckbox("Whisper", 255, y, "incomingChannels", "WHISPER")
y = y - 26
configFrame.elements.inChParty = CreateCheckbox("Party", 25, y, "incomingChannels", "PARTY")
configFrame.elements.inChGuild = CreateCheckbox("Guild", 140, y, "incomingChannels", "GUILD")
configFrame.elements.inChRaid = CreateCheckbox("Raid", 255, y, "incomingChannels", "RAID")
y = y - 26
configFrame.elements.inChBG = CreateCheckbox("Battleground", 25, y, "incomingChannels", "BATTLEGROUND")
configFrame.elements.inChChannel = CreateCheckbox("World/Local", 165, y, "incomingChannels", "CHANNEL")

y = y - 34
CreateHeader("Outgoing Translation (You -> Chat)", y)
y = y - 26
configFrame.elements.outEnabled = CreateCheckbox("Enable Outgoing", 25, y, "outgoingEnabled", nil)
y = y - 30
configFrame.elements.outFrom = CreateLangSelector("From:", 25, y, "outgoingFromLang", 175)
configFrame.elements.outTo = CreateLangSelector("To:", 210, y, "outgoingToLang", 175)

y = y - 28
local chLabel = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
chLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 25, y)
chLabel:SetText("Outgoing Channels:")
y = y - 26
configFrame.elements.chWhisper = CreateCheckbox("Whisper", 25, y, "outgoingChannels", "WHISPER")
configFrame.elements.chParty = CreateCheckbox("Party", 140, y, "outgoingChannels", "PARTY")
configFrame.elements.chSay = CreateCheckbox("Say", 255, y, "outgoingChannels", "SAY")
y = y - 26
configFrame.elements.chGuild = CreateCheckbox("Guild", 25, y, "outgoingChannels", "GUILD")
configFrame.elements.chRaid = CreateCheckbox("Raid", 140, y, "outgoingChannels", "RAID")
configFrame.elements.chYell = CreateCheckbox("Yell", 255, y, "outgoingChannels", "YELL")
y = y - 26
configFrame.elements.chBG = CreateCheckbox("Battleground", 25, y, "outgoingChannels", "BATTLEGROUND")
configFrame.elements.chChannel = CreateCheckbox("World/Local", 165, y, "outgoingChannels", "CHANNEL")

-- Reserve room for the bottom Clear Cache / Save buttons. The checkbox
-- template itself renders taller (~32px) than the 24px row spacing used
-- between checkbox rows, so the last row needs extra clearance here or it
-- visually overlaps the buttons below it — that's what was happening.
y = y - 34 - 54
configFrame:SetHeight(math.abs(y))

local clearBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
clearBtn:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 25, 20)
clearBtn:SetWidth(120)
clearBtn:SetHeight(26)
clearBtn:SetText("Clear Cache")
clearBtn:SetScript("OnClick", function()
    if WoWTranslate_CacheClear then
        WoWTranslate_CacheClear()
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[WoWTranslate] Cache cleared|r")
    end
end)

local saveBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
saveBtn:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -25, 20)
saveBtn:SetWidth(80)
saveBtn:SetHeight(26)
saveBtn:SetText("Save")
saveBtn:SetScript("OnClick", function()
    SaveTempConfig()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[WoWTranslate] Settings saved|r")
    configFrame:Hide()
end)

local function RefreshUI()
    local e = configFrame.elements
    local cfg = WoWTranslate_TempConfig

    if e.inEnabled then e.inEnabled:SetChecked(cfg.enabled) end
    if e.afkDisable then e.afkDisable:SetChecked(cfg.disableWhileAfk) end
    if e.translateSystem then e.translateSystem:SetChecked(cfg.translateSystemMessages) end
    if e.outEnabled then e.outEnabled:SetChecked(cfg.outgoingEnabled) end

    if e.inFrom and e.inFrom.display then
        e.inFrom.display:SetText(GetLanguageName(cfg.incomingFromLang or "zh"))
    end
    if e.inTo and e.inTo.display then
        e.inTo.display:SetText(GetLanguageName(cfg.incomingToLang or "en"))
    end
    if e.outFrom and e.outFrom.display then
        e.outFrom.display:SetText(GetLanguageName(cfg.outgoingFromLang or "en"))
    end
    if e.outTo and e.outTo.display then
        e.outTo.display:SetText(GetLanguageName(cfg.outgoingToLang or "zh"))
    end

    local inCh = cfg.incomingChannels or {}
    if e.inChSay then e.inChSay:SetChecked(inCh.SAY) end
    if e.inChYell then e.inChYell:SetChecked(inCh.YELL) end
    if e.inChWhisper then e.inChWhisper:SetChecked(inCh.WHISPER) end
    if e.inChParty then e.inChParty:SetChecked(inCh.PARTY) end
    if e.inChGuild then e.inChGuild:SetChecked(inCh.GUILD) end
    if e.inChRaid then e.inChRaid:SetChecked(inCh.RAID) end
    if e.inChBG then e.inChBG:SetChecked(inCh.BATTLEGROUND) end
    if e.inChChannel then e.inChChannel:SetChecked(inCh.CHANNEL) end

    local ch = cfg.outgoingChannels or {}
    if e.chWhisper then e.chWhisper:SetChecked(ch.WHISPER) end
    if e.chParty then e.chParty:SetChecked(ch.PARTY) end
    if e.chSay then e.chSay:SetChecked(ch.SAY) end
    if e.chGuild then e.chGuild:SetChecked(ch.GUILD) end
    if e.chRaid then e.chRaid:SetChecked(ch.RAID) end
    if e.chYell then e.chYell:SetChecked(ch.YELL) end
    if e.chBG then e.chBG:SetChecked(ch.BATTLEGROUND) end
    if e.chChannel then e.chChannel:SetChecked(ch.CHANNEL) end
end

-- Lets other files (e.g. the minimap button) refresh this panel's
-- checkboxes/selectors live, without forcing it open, if it's already
-- visible.
function WoWTranslate_RefreshConfigUI()
    if configFrame:IsVisible() then
        RefreshUI()
    end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================
function WoWTranslate_ShowConfig()
    LoadTempConfig()
    RefreshUI()
    configFrame:Show()
end

function WoWTranslate_HideConfig()
    configFrame:Hide()
end

function WoWTranslate_ToggleConfig()
    if configFrame:IsVisible() then
        configFrame:Hide()
    else
        WoWTranslate_ShowConfig()
    end
end
