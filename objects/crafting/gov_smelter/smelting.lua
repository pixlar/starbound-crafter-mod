function init(args)
end


function update(args)
	--summon the smith and tell him to act like he's smelting
	--getSmith()
	bars = {
		["imperviumcompound"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["goldbar"]= 1, 
				["refinedviolum"]= 1 } 
		},
		["ceruliumcompound"] = { 
		["furnaces"]= {"scififurnace"}, 
		["ingredients"]= { 
			["goldbar"]= 1, 
			["refinedrubium"]= 1 } 
		},
		["feroziumcompound"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["goldbar"]= 1, 
				["refinedaegisalt"]= 1 } 
		},
		["refinedaegisalt"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["aegisaltore"]= 2 } 
		},
		["refinedrubium"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["rubiumore"]= 2 } 
		},
		["refinedviolium"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["violiumore"]= 2 } 
		},
		["durasteelbar"] = { 
			["furnaces"]= {"scififurnace"}, 
			["ingredients"]= { 
				["silverbar"]= 1, 
				["titaniumbar"]= 1 } 
		},
		["titaniumbar"] = { 
			["furnaces"]= {"alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["titaniumore"]= 2 } 
		},
		["plutoniumrod"] = { 
			["furnaces"]= {"alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["plutoniumore"]= 2 } 
		},
		["steelbar"] = { 
			["furnaces"]= {"alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["copperbar"]= 1, 
				["ironbar"]= 1 } 
		},
		["platinumbar"] = { 
			["furnaces"]= {"stonefurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["platinumore"]= 2 } 
		},
		["ironbar"] = { 
			["furnaces"]= {"stonefurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["ironore"]= 2 } 
		},
		["goldbar"] = { 
			["furnaces"]= {"stonefurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["goldore"]= 2 } 
		},
		["copperbar"] = { 
			["furnaces"]= {"stonefurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["copperore"]= 2 } 
		},
		["silverbar"] = { 
			["furnaces"]= {"stonefurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["silverore"]= 2 } 
		}
	}
	availableOre = findOre()
	furnaces = findFurnaces()
	--how much of what can be smelted
	smeltableBars = canSmelt(availableOre, furnaces)
	barDeposits = findChests()
--	canFit(smeltableBars, barDeposits)
	tryThatThing()

end

function findFurnaces()
--	world.logInfo("searching for furnaces")
	--get nearby objects
	nearObjects = world.objectQuery(entity.position(), 30, {order="nearest"})
	--world.logInfo(type(nearObjects))
	--check name against valid furnace names
	smelters = {}
	for i,v in pairs(nearObjects) do
		if string.find(world.entityName(v), "furnace") then
			--world.logInfo(v.." is a "..world.entityName(v))
			table.insert(smelters, v)
		end
	end
	return smelters
end

--how much of what can be smelted
function allSmeltables(ores, smelters)
	smeltable = {}

	
	for key,furnace in pairs(smelters) do
--		world.logInfo("=============="..world.entityName(furnace).."=================")

		for barname,recipe in pairs(bars) do
		
			for kk,acceptablefurnace in pairs(recipe["furnaces"]) do
--				world.logInfo(acceptablefurnace)

				if world.entityName(furnace) == acceptablefurnace then
--					world.logInfo(barname.." can be smelted at this furnace")

					for oreRequired,oreNumberRequired in pairs(recipe["ingredients"]) do
--						world.logInfo(oreRequired)

						for oreAvailable,oreNumberAvailable in pairs(ores) do
--							world.logInfo(oreAvailable.."=================")

							if oreAvailable == oreRequired then
--								world.logInfo(barname.." has ore")
								howMuch = oreNumberAvailable/oreNumberRequired
								smeltable[barname] = math.floor(howMuch)
							end
						end
					end
				end
			end
		end
	end
	return smeltable
end

-- returns how much can fit in the available chests
function canFit(items, chests)
	itemsThatFit = {}
	for itemName,itemAmount in pairs(items) do
		world.logInfo(itemName..", "..itemAmount)
		itemsThatFit[itemName] = 0
		for key, chestID in pairs(chests) do
			world.logInfo(chestID)
			testitem = {}
			testitem.count = itemAmount
			testitem.name = itemName
			testitem.parameters = {}
			world.logInfo(world.containerAvailable(chestID, testitem))
--			if itemsThatFit[itemName] ~= nil then
--				itemsThatFit[itemName] = itemsThatFit[itemName]+ world.containerAvailable(chestID, testitem)
--			else
--				itemsThatFit[itemName] = world.containerAvailable(chestID, testitem)
--			end
--			if itemsThatFit[itemName] >= itemAmount then
--				itemsThatFit[itemName] = itemAmount
--				break
--			end
		end
	end
--	for k,v in pairs(itemsThatFit) do
--		world.logInfo(k.." :"..v)
--	end 
	--return itemsThatFit
end

--find containers nearby
function findChests()
--	world.logInfo("searching for chests")
	nearObjects = world.objectQuery(entity.position(), 30, {order="nearest"})
	--check name against valid furnace names
	chests = {}
	for i,v in pairs(nearObjects) do
		if world.containerSize(v) ~= nil then
			--world.logInfo(v.." is a container called "..world.entityName(v))
			table.insert(chests, v)
		end
	end
	return chests
end

--returns table with amounts of ore nearby
function findOre()
	chests = findChests()
	ore = {}
	for i,v in pairs(chests) do
		contents = world.containerItems(v)
		for j,k in pairs(contents) do
			if k ~= nil and string.find(k["name"], "ore") then
				if ore[k["name"]] ~= nil then
					ore[k["name"]] = ore[k["name"]] + k["count"]
				else
					ore[k["name"]] = k["count"]
				end
--				world.logInfo(k["name"].." count is "..ore[k["name"]])
			end
		end
	end
	return ore
end

function tryThatThing()
	chests = findChests()
	stuff = world.containerItems(chests[1])
	world.containerAvailable(chests[2], stuff[1])
end