function init()
	--world.logInfo("console activated")
	thedesk = console.sourceEntity()
	display = 0
end

function update()
	console.canvasDrawText( "The Governor's Desk", {position={15, 200}, horizontalAnchor="left", verticalAnchor="top"}, 12, {255, 255, 255}) 
	if display == 0 then
		crafting = {"Smelting", "Smithing", "Grilling", "Cooking", "Farming",}
		craftingStations = {"gov_smelter", "gov_anvil", "gov_grill", "gov_counter", "gov_farm"}
		for i=1,5 do
			console.canvasDrawRect({14, (213 - i*34), 276, (184 - i*34)}, {250, 250, 250})
			console.canvasDrawRect({15, (212 - i*34), 275, (185 - i*34)}, {50, 50, 50})
			console.canvasDrawText( crafting[i], {position={30, (210 - i*34)}, horizontalAnchor="left", verticalAnchor="top"}, 10, {255, 255, 255} )
		end
	else
		console.canvasDrawText( crafting[display].." Crafters Available", {position={20, 187}, horizontalAnchor="left", verticalAnchor="top"}, 10, {250, 250, 250}) 
		drawPage(i)
	end
end

function drawPage(craft)
-- list of this type of crafter
	names = {"Adam", "Betty", "Charlie", "Darla", "Ethan", "Fran"}
	stuff = {"Medieval Furnace", "Stone Furnace", "Alloy Furnace"}
	
	for i=1,5 do
		console.canvasDrawRect({14, (207 - i*34), 276, (174 - i*34)}, {250, 250, 250})
		console.canvasDrawRect({15, (206 - i*34), 275, (175 - i*34)}, {50, 50, 50})
		console.canvasDrawText( names[i], {position={32, (205 - i*34)}, horizontalAnchor="left", verticalAnchor="top"}, 10, {255, 255, 255} )
		console.canvasDrawImage("/interface/title/aquaticmale.png", {12, (185 - i*34)}, 1)
		console.canvasDrawText( "Uses "..table.concat(stuff, ", "), {position={40, (194 - i*34)}, horizontalAnchor="left", verticalAnchor="top"}, 8, {245, 245, 245} )
		console.canvasDrawText( "Currently Smelting: XX Iron Bars", {position={40, (185 - i*34)}, horizontalAnchor="left", verticalAnchor="top"}, 7, {245, 245, 245} )
	end
	
-- when a crafter is selected	
	
end

function canvasClickEvent(position, button, click)
	if display == 0 and click then
		world.logInfo(position[1])
		world.logInfo(position[2])
		for i=1,5 do
			if position[1] >= 15 and position[1] <= 275 then
				if position[2] <= (212 -i*34) and position[2] >= (185 -i*34) then
					world.logInfo("click")
					display = i
				end
			end
		end
	elseif click then
		display = 0
	end
end

drawBox()
	
end

----------Thank you lua-users.org/wiki
function tableLength(tab)
	local retVal = 0
	for i,j in pairs(tab) do
		retVal = retVal + 1
	end
	return retVal
end