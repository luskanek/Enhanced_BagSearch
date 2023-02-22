local _G = getfenv(0)

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
		if this:GetText() and this:GetText() ~= "Search" then
			for bag = 0, 4 do
				local bagSize = GetContainerNumSlots(bag)
				for slot = 1, bagSize do
					local item = _G["ContainerFrame" .. (bag + 1) .. "Item" .. ((bagSize - slot) + 1)]
					local _, count, _, _, _ = GetContainerItemInfo(bag, slot)
					if count then
						item:SetAlpha(0.3)

						local texture = _G[item:GetName() .. "IconTexture"]
						texture:SetDesaturated(1)

						local link = GetContainerItemLink(bag, slot)
						local name = string.sub(link, string.find(link, "%[") + 1, string.find(link, "%]") - 1)
						if strfind(strlower(name), strlower(string.gsub(this:GetText(), "([^%w])", "%%%1"))) then
							item:SetAlpha(1)
							texture:SetDesaturated(0)
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