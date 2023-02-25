local _G = getfenv(0)

-- array of available item rarities
local ITEM_RARITY = {
	"POOR GREY GRAY JUNK",
	"COMMON WHITE",
	"UNCOMMON GREEN",
	"RARE BLUE",
	"EPIC PURPLE",
	"LEGENDARY ORANGE"
}

-- helper function to get the key of a table value
local function GetIndex(table, item)
	for key, value in pairs(table) do
		local subs = { }
		string.gsub(value, "(%w+)",
			function(match) 
				tinsert(subs, match)
			end
		)
		for _, substring in pairs(subs) do
			if substring == item then
				return key
			end
		end
    end

    return nil
end

-- create search input box
CreateFrame("EditBox", "BackpackSearchBox", ContainerFrame1, "InputBoxTemplate")
BackpackSearchBox:ClearAllPoints()
BackpackSearchBox:SetPoint("TOPLEFT", ContainerFrame1, "TOPLEFT", 50, 83)
BackpackSearchBox:SetPoint("BOTTOMRIGHT", ContainerFrame1, "BOTTOMRIGHT", -10, 80)
BackpackSearchBox:SetAutoFocus(false)
BackpackSearchBox:SetText("Search")
BackpackSearchBox:SetTextColor(0.5, 0.5, 0.5, 1)
BackpackSearchBox:SetTextInsets(15, 20, 0, 0)
BackpackSearchBox:SetHitRectInsets(15, 20, 0, 0)

-- create a fancy search icon
local icon = CreateFrame('Frame', nil, BackpackSearchBox)
icon:ClearAllPoints()
icon:SetPoint('LEFT', BackpackSearchBox, 1, -2)
icon:SetHeight(14)
icon:SetWidth(14)
icon:SetBackdrop({
	bgFile = "Interface\\AddOns\\Enhanced_BagSearch\\assets\\Search",
})
icon:SetBackdropColor(1, 1, 1, 0.6)

-- create a button to clear the text
CreateFrame('Button', "BackpackSearchBoxClearButton", BackpackSearchBox)
BackpackSearchBoxClearButton:ClearAllPoints()
BackpackSearchBoxClearButton:SetPoint('RIGHT', BackpackSearchBox, -3, 0)
BackpackSearchBoxClearButton:SetHeight(14)
BackpackSearchBoxClearButton:SetWidth(14)
BackpackSearchBoxClearButton:SetBackdrop({
	bgFile = "Interface\\AddOns\\Enhanced_BagSearch\\assets\\Clear",
})
BackpackSearchBoxClearButton:SetBackdropColor(1, 1, 1, 0.6)

BackpackSearchBox:SetScript("OnTextChanged", 
	function()
		local mode = 0

		local query = this:GetText()
		if query and query ~= "Search" then
			-- quality
			if string.find(string.lower(query), "/r") then
				query = string.sub(query, 4)
				mode = 1

			elseif string.find(string.lower(query), "/t") then
				query = string.sub(query, 4)
				mode = 2
			end

			for bag = 0, 4 do
				local bagSize = GetContainerNumSlots(bag)
				for slot = 1, bagSize do
					local item = _G["ContainerFrame" .. (bag + 1) .. "Item" .. ((bagSize - slot) + 1)]
					local _, count, _, _, _ = GetContainerItemInfo(bag, slot)
					if count then
						local link = GetContainerItemLink(bag, slot)
						local _, _, id, _, _, _ = string.find(link, 'item:(%d+):(%d*):(%d*):(%d*)')
						local _, _, rarity, _, type, _, _, _ = GetItemInfo(tonumber(id))

						local texture = _G[item:GetName() .. "IconTexture"]
						texture:SetDesaturated(1)
						item:SetAlpha(0.3)

						if mode == 0 then
							local name = string.sub(link, string.find(link, "%[") + 1, string.find(link, "%]") - 1)
							if string.find(string.lower(name), string.lower(string.gsub(query, "([^%w])", "%%%1"))) then
								item:SetAlpha(1)
								texture:SetDesaturated(0)
							end
						
						elseif mode == 1 then
							local index = GetIndex(ITEM_RARITY, string.upper(query))
							if index then
								if rarity == index - 1 then
									item:SetAlpha(1)
									texture:SetDesaturated(0)
								end
							end

						elseif mode == 2 then
							if string.upper(type) == string.upper(query) then
								item:SetAlpha(1)
								texture:SetDesaturated(0)
							end
						end
					end
				end
			end
		end
	end
)

BackpackSearchBox:SetScript("OnEditFocusGained",
	function()
		this:SetTextColor(1.0, 1.0, 1.0, 1)

		if this:GetText() == "Search" then 
			this:SetText("")
		end	
	end
)

BackpackSearchBox:SetScript("OnEditFocusLost",
	function()
		this:SetTextColor(0.5, 0.5, 0.5, 1)

		if not string.find(this:GetText(), "%w") then 
			BackpackSearchBox:SetText("Search")
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					local item = _G["ContainerFrame" .. (bag + 1) .. "Item" .. slot]
					item:SetAlpha(1)

					local texture = _G[item:GetName() .. "IconTexture"]
					texture:SetDesaturated(0)
				end
			end
		end
	end
)

BackpackSearchBoxClearButton:SetScript("OnClick", 
	function()
		BackpackSearchBox:SetText("")
		BackpackSearchBox:ClearFocus()
	end
)

BackpackSearchBoxClearButton:SetScript("OnEnter", 
	function()
		this:SetBackdropColor(1, 1, 1, 1)
	end
)

BackpackSearchBoxClearButton:SetScript("OnLeave", 
	function()
		this:SetBackdropColor(1, 1, 1, 0.6)
	end
)