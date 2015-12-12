function init(args)
	isCurrentlySmelting = false
	waitTimer = 0
end


function update(args)
--	world.logInfo("===========================")
--	world.logInfo(world.entityName(entity.id()))
--	world.logInfo(entity.id())
	--list of bars and recipes and furnaces
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
			["furnaces"]= {"stonefurnace", "medievalfurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["platinumore"]= 2 } 
		},
		["ironbar"] = { 
			["furnaces"]= {"stonefurnace", "medievalfurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["ironore"]= 2 } 
		},
		["goldbar"] = { 
			["furnaces"]= {"stonefurnace", "medievalfurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["goldore"]= 2 } 
		},
		["copperbar"] = { 
			["furnaces"]= {"stonefurnace", "medievalfurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["copperore"]= 2 } 
		},
		["silverbar"] = { 
			["furnaces"]= {"stonefurnace", "medievalfurnace", "alloyfurnace", "scififurnace"}, 
			["ingredients"]= { 
				["silverore"]= 2 } 
		}
	}
	
	--if not currently smelting something, find something to smelt
	if not isCurrentlySmelting and waitTimer == 0 then 
		availableOre = findOre()
		if tableLength(availableOre) == 0 then
			world.logInfo("Smith says - There's no ore to smelt!")
		end
		furnaces = findFurnaces()
		if tableLength(furnaces) == 0 then
			world.logInfo("Smith says - There's no furnaces for me to work with!")
		end
	
		--how much of what can be smelted
		smeltableBars = allSmeltables(availableOre, furnaces)
		if tableLength(smeltableBars) == 0 then
			world.logInfo("Smith says - I can't smelt any of this!")
		end
	
		--how much of that can fit in nearby chests
		for barName,barCount in pairs(smeltableBars) do
			smeltableBars[barName] = howManyBarsFit(barName, barCount)
		end
		if tableLength(smeltableBars) == 0 then
			world.logInfo("Smith says - I've got no room to put any bars!")
		end
	
		--pick something to smelt
		toSmelt = smeltThis(smeltableBars)
--		world.logInfo("Going to smelt "..toSmelt['bar'].." : "..toSmelt['count'])
		
		--begin smelting, stop looking for stuff to smelt
		if toSmelt['count'] > 0 then
			isCurrentlySmelting = true
		end
		
		--wait timer - don't do this loop too often
		waitTimer = math.random(40)
	elseif not isCurrentlySmelting then
		waitTimer = waitTimer - 1
	end
	
	--if currentlySmelting, smelt until finished with current queue
	if isCurrentlySmelting then
		--summon the smith and tell him to act like he's smelting
		--getSmith()
		chests = findChests()
		world.logInfo("Smelting "..toSmelt['bar'].." : "..toSmelt['count'])
		newBar = {}
		newBar["name"] = toSmelt['bar']
		newBar["count"] = 1
		consumeOres = bars[newBar["name"]]["ingredients"]
		
		--go through chests
		for _,chest in pairs(chests) do
			--consume ore for each bar
			for ore,count in pairs(consumeOres) do
				if count > 0 then
					world.logInfo("Need "..count.." "..ore)
					takeOre = {["name"] = ore, ["count"] = count}
					oreCheck = world.containerConsume(chest,takeOre)
					if oreCheck then
						world.logInfo("Consuming "..count.." "..ore)
						consumeOres[ore] = 0
					else
						takeOre["count"] = 1
						oreCheck = world.containerConsume(chest,takeOre)
						if oreCheck then
							consumeOres[ore] = count - 1
						end
					end
				end
			end
			
		--spawn a bar in the first available place
			world.logInfo(world.containerItemsCanFit(chest, newBar))
			world.logInfo(newBar["count"])
			if world.containerItemsCanFit(chest, newBar) and newBar["count"] > 0 then
				world.logInfo("Spawning "..newBar["name"].." in "..world.entityName(chest))
				world.containerAddItems(chest, newBar)
				newBar["count"] = 0
				toSmelt['count'] = toSmelt['count'] - 1
			end
		end
		
		--stop smelting if you ran out of ore to smelt
		--leaves an exploit where ore can be removed then put back to get one bar per cycle for free
		for ore,count in pairs(consumeOres) do
			if count > 0 then
				isCurrentlySmelting = false
			end
		end
		
		--if you finish all the bars in the queue, stop smelting
		if toSmelt['count'] <= 0 then
			isCurrentlySmelting = false
		end
		
	end
	
end

--find containers nearby
function findChests()
--	world.logInfo("searching for chests")
	nearObjects = world.objectQuery(entity.position(), 30, {order="nearest"})
	chests = {}
	for _,v in pairs(nearObjects) do
		if world.containerSize(v) ~= nil then
--			world.logInfo(v.." is a container called "..world.entityName(v))
			table.insert(chests, v)
		end
	end
	return chests
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

function canSmeltHowMuch(furnace, barname, recipe, ores)
	hazFurnace = false
	for kk,acceptablefurnace in pairs(recipe["furnaces"]) do
--		world.logInfo(acceptablefurnace)

		if world.entityName(furnace) == acceptablefurnace then
--			world.logInfo(barname.." can be smelted at this furnace")
			hazFurnace = true
			
		end
	end
	
	if hazFurnace == false then
		return 0
	end
	
	smeltable_ores = {}
	min_amt = nil
		
	for oreRequired,oreNumberRequired in pairs(recipe["ingredients"]) do
--		world.logInfo(oreRequired)

		for oreAvailable,oreNumberAvailable in pairs(ores) do
--			world.logInfo(oreAvailable.."=================")

			if oreAvailable == oreRequired then
--				world.logInfo(barname.." has ore")
				howMuch = oreNumberAvailable/oreNumberRequired
				smeltable_ores[oreAvailable] = math.floor(howMuch)
				
				if min_amt == nil then
					min_amt = math.floor(howMuch)
				elseif min_amt > math.floor(howMuch) then
					min_amt = math.floor(howMuch)
				end
				break
				
			end
		end
		
		if smeltable_ores[oreAvailable] ~= nil then
			return 0
		end
	end
	
	return min_amt
	
end

--how much of what can be smelted
function allSmeltables(ores, smelters)
	smeltable = {}
	
	for key,furnace in pairs(smelters) do
--		world.logInfo("=============="..world.entityName(furnace).."=================")

		for barname,recipe in pairs(bars) do
			amt = canSmeltHowMuch(furnace, barname, recipe, ores)
			if amt ~= nil and amt > 0 then
				smeltable[barname] = amt
			end
		end
	end
	return smeltable
end

function howManyBarsFit(barname, count)
--	world.logInfo("searching for Bar chests")
	chests = findChests()
	item = {}
	maxStack = 0
	for _,v in pairs(chests) do
		item["name"] = barname
		item["count"] = count
		maxStack = maxStack + world.containerItemsCanFit(v, item)
		if maxStack >= count then
			maxStack = count
			break
		end
	end
	return maxStack
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

--returns which bar to smelt and how many
function smeltThis(smeltableBars)
	smeltIt = {}
	smeltIt['bar'] = ""
	smeltIt['count'] = 0
	for barName,barCount in pairs(smeltableBars) do
		if barCount >= 10 then
--			world.logInfo("Smelt 10 "..barName)
			smeltIt['bar'] = barName
			smeltIt['count'] = 10
--			world.logInfo(smeltIt['bar'].." : "..smeltIt['count'])
			break
		elseif barCount >= 5 then
--			world.logInfo("Smelt 5 "..barName)
			smeltIt['bar'] = barName
			smeltIt['count'] = 5
--			world.logInfo(smeltIt['bar'].." : "..smeltIt['count'])
		else 
--			world.logInfo("Smelt 1 "..barName)
			smeltIt['bar'] = barName
			smeltIt['count'] = 1
--			world.logInfo(smeltIt['bar'].." : "..smeltIt['count'])
		end
	end
--	world.logInfo(smeltIt['bar'].." : "..smeltIt['count'])
	return smeltIt
end

function tableLength(tab)
	local retVal = 0
	for i,j in pairs(tab) do
		retVal = retVal + 1
	end
	return retVal
end