function OnDriverInit ()
	C4:AddVariable("RANDOM_NUMBER", 1, "NUMBER") -- Number variable to hold the random number generated
end

function GenerateRandomNumber()
	local maxNumber = tonumber(Properties['Max Number']) or 2
	local randomNumber = math.random(1, maxNumber)
	C4:SetVariable("RANDOM_NUMBER", randomNumber)
	C4:FireEvent('RandomNumberGenerated')
	print("Generated Random Number: " .. randomNumber)
end

function ExecuteCommand (strCommand, tParams)
	if strCommand == "GenerateNewNumber" or (strCommand == "LUA_ACTION" and tParams.ACTION == "GenerateNewNumber") then
		GenerateRandomNumber()
	end
end