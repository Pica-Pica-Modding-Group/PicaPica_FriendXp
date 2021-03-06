local function ReadableNumber(num, places)
  local ret
  local placeValue = ("%%.%df"):format(places or 0)
  if not num then
      return 0
  elseif num >= 1000000000000 then
      ret = placeValue:format(num / 1000000000000) .. "T" -- trillion
  elseif num >= 1000000000 then
      ret = placeValue:format(num / 1000000000) .. "B" -- billion
  elseif num >= 1000000 then
      ret = placeValue:format(num / 1000000) .. "M" -- million
  elseif num >= 1000 then
      ret = placeValue:format(num / 1000) .. "K" -- thousand
  else
      ret = num -- hundreds
  end
  return ret
end

local MSG_PREFIX = "PPFXP";

-- Compatibility: Lua-5.0
function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

local success = C_ChatInfo.RegisterAddonMessagePrefix(MSG_PREFIX)

local width = 32;
local height = 32;
local html = "";
local fontSize = 11;

local x = 0;
local y = 0;

local frame = CreateFrame('SimpleHTML');

frame:SetFont('Fonts\\FRIZQT__.TTF', fontSize);

frame:SetPoint("CENTER", 0, 0);
frame:EnableMouse(true);
frame:SetMovable(true);
frame:SetWidth(width);
frame:SetHeight(fontSize*4);

frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
frame:SetBackdropColor(0,0,0,1);

frame:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)
frame:SetScript("OnMouseUp", function(self, button)
  if button == "LeftButton" and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)
frame:SetScript("OnHide", function(self)
  if ( self.isMoving ) then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)



function HelloWorld()	
	UpdateText("Pica Pica Friend XP - No Group Members", 0, 0, "")
end

function sendCurrXp()
	local XP = UnitXP("player")
	local XPMax = UnitXPMax("player")
  
	local XPTrunc = ReadableNumber(XP, 2)
	local XPMaxTrunc = ReadableNumber(XPMax, 2)
	-- Misc = (XPMax - XP) ..", "..floor( (XP / XPMax)*100 ).."%"
	local Misc = floor( (XP / XPMax)*100 ).."%"
	-- msg = "Your friend XP is currently at "..floor( (XP / XPMax)*100 ).."%."
	--print("[ME] "..msg)
	--SendChatMessage(msg ,"PARTY" ,"COMMON" )
	C_ChatInfo.SendAddonMessage(MSG_PREFIX, XPTrunc..";"..XPMaxTrunc..";"..Misc, "PARTY")
	-- DEFAULT_CHAT_FRAME:AddMessage("Your XP is currently at "..floor( (XP / XPMax)*100 ).."%.",1,0,0)
end

function handlerFunc(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_XP_UPDATE" or event == "GROUP_ROSTER_UPDATE" or event == "PARTY_MEMBER_ENABLE" then
		sendCurrXp();
		return
	end
	
	if event == "CHAT_MSG_ADDON" then
		prefix = arg1
		msg = arg2
		sender = Split(arg4, "-")
		local playerName = UnitName("player");
		
		if prefix == MSG_PREFIX and sender[1] ~= playerName then
			local params = Split(msg, ";")
			UpdateText(sender[1], params[1], params[2], params[3])
		end
	end
end

frame:RegisterEvent("PLAYER_XP_UPDATE");
frame:RegisterEvent("PARTY_MEMBER_ENABLE");
frame:RegisterEvent("GROUP_ROSTER_UPDATE");

frame:RegisterEvent("CHAT_MSG_ADDON")

frame:SetScript("OnEvent", handlerFunc)


function UpdateText(name, xp, maxXp, misc)
    html =
		"<html>"..
		  "<body>" ..
		  
			"<p  valign='middle' align='middle' top='12'>" ..
			"<br/>" ..
			  name ..
			  "<br/>" ..
			  "Curr XP: "..xp .. "&#47;"..maxXp .. " ("..misc..")"..
			"</p>"..
		 "</body>"..
	   "</html>";
	frame:SetWidth((string.len("Curr XP: "..xp.."/"..maxXp .. " ("..misc..")") * fontSize) * 0.9);
	--frame:SetWidth((string.len(name) * fontSize) * 0.9);
	frame:SetText(html);
end
