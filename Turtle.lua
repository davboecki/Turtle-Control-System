key = "TurtleControlSystem"

rednet.open("right")

Main = nil
isturtle = true
if(turtle) then
	run = true
else
	run = false
	isturtle = false
end
conectiontimer = 0
os.startTimer(0.1)
timedtask = 0

task = nil
taskX = nil
taskZ = nil
posX = 0
posY = 0
posZ = 0
dirrection = "Forward"

if(isturtle) then
	write("Conntecting.")
end

function posInfo()
	print(posX)
	print(posY)
	print(posZ)
	print(dirrection)
end

function movetostart()
	max =  math.max(math.abs(posX), math.abs(posY), math.abs(posZ))
	while(max ~= 0) do
	max =  math.max(math.abs(posX), math.abs(posY), math.abs(posZ))
		if(max == math.abs(posZ)) then
			if(posZ < 0) then
				TurnTo("Forward")
				while(posZ<0) do
					if(turtle.detect()) then
						turtle.dig()
					end
					forward()
				end
			elseif(posZ > 0) then
				TurnTo("Back")
				while(posZ>0) do
					if(turtle.detect()) then
						turtle.dig()
					end
					forward()
				end
			end
		elseif(max == math.abs(posY)) then
			if(posY<0) then
				while(posY<0) do
					if(turtle.detectUp()) then
						turtle.digUp()
					end
					up()
				end
			elseif(posY>0) then
				while(posY>0) do
					if(turtle.detectDown()) then
						turtle.digDown()
					end
					down()
				end
			end
		elseif(max == math.abs(posX)) then
			if(posX > 0) then
				TurnTo("Left")
				while(posX>0) do
					if(turtle.detect()) then
						turtle.dig()
					end
					forward()
				end
			elseif(posX < 0) then
				TurnTo("Right")
				while(posX<0) do
					if(turtle.detect()) then
						turtle.dig()
					end
					forward()
				end
			end
		end
	end
	TurnTo("Forward")
end

function TurnTo(dir)
	timeout = 0
	while(dirrection ~= dir and timeout < 50) do
		Right()
		timeout = timeout + 1
	end
end

function forward()
	if(turtle.detect()) then
		return
	end
	if(turtle.forward()) then
		if(dirrection == "Forward") then
			posZ = posZ + 1
		elseif(dirrection == "Left") then
			posX = posX - 1
		elseif(dirrection == "Right") then
			posX = posX + 1
		elseif(dirrection == "Back") then
			posZ = posZ - 1
		end
	end
end

function up()
	if(turtle.up()) then
		posY = posY + 1
	end
end

function down()
	if(turtle.down()) then
		posY = posY - 1
	end
end

function back()
	if(turtle.back()) then
		if(dirrection == "Forward") then
			posZ = posZ - 1
		elseif(dirrection == "Left") then
			posX = posX + 1
		elseif(dirrection == "Right") then
			posX = posX - 1
		elseif(dirrection == "Back") then
			posZ = posZ + 1
		end
	end
end

function Left()
	if(turtle.turnLeft()) then
		if(dirrection == "Forward") then
			dirrection = "Left"
		elseif(dirrection == "Left") then
			dirrection = "Back"
		elseif(dirrection == "Right") then
			dirrection = "Forward"
		elseif(dirrection == "Back") then
			dirrection = "Right"
		end
	end
end

function Right()
	if(turtle.turnRight()) then
		if(dirrection == "Forward") then
			dirrection = "Right"
		elseif(dirrection == "Left") then
			dirrection = "Forward"
		elseif(dirrection == "Right") then
			dirrection = "Back"
		elseif(dirrection == "Back") then
			dirrection = "Left"
		end
	end
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function isBreakableFront()
	i = 1
	while(i<10) do
		if(turtle.getItemCount(i) == 0) then
			return true
		end
	end
	while(i<10) do
		turtle.select(i)
		if(turtle.compare() and turtle.getItemSpace(i) ~= 0) then
			return true
		end
	end
	return false
end

function isBreakableTop()
	i = 1
	while(i<10) do
		if(turtle.getItemCount(i) == 0) then
			return true
		end
	end
	while(i<10) do
		turtle.select(i)
		if(turtle.compareUp() and turtle.getItemSpace(i) ~= 0) then
			return true
		end
	end
	return false
end

if(isturtle) then
	rednet.broadcast(key.."connectTurtle")
end

while(run) do 
	event,param1,param2 = os.pullEvent()
	--if(event ~= "timer") then
	--	print(event)
	--	print(param1)
	--	print(param2)
	--end
	if(event == "char") then 
		if(param1 == "s") then
			run = false
		end
		if(param1 == "h") then
			os.shutdown()
		end
		if(param1 == "p") then
			rednet.send(Main,"pong")
			print("pong")
		end
		if(param1 == "i") then
			posInfo()
		end
	end
	if(event == "key") then
		if(param1 == 200) then
			forward()
		end
		if(param1 == 203) then
			Left()
		end
		if(param1 == 205) then
			Right()
		end
		if(param1 == 208) then
			back()
		end
		if(param1 == 57) then
			turtle.dig()
		end
		if(param1 == 201) then
			up()
		end
		if(param1 == 209) then
			down()
		end
		if(param1 == 33) then -- f
			m = 0
			while(m<20) do
				forward()
				m = m + 1
			end
		end
		if(param1 == 19) then -- r
			movetostart()
		end
	end
	if(event == "rednet_message") then
		if(Main == nil and param2 == "connectMain") then
			Main = param1
			conectiontimer = nil
			print("")
			print("Connected")
		end
		if(Main ~= nil and Main == param1) then
			if(param2 == "ping") then
				rednet.send(Main,"pong")
			end
			array = split(param2, ",")
			p1, p2, p3 = array[1], array[2], array[3]
			if(p1 == "task") then
				if(task ~= nil) then
					StartX, StartY, StartZ = gps.locate(2, false)
					if(StartX ~= nil) then
						task = "mine"
						taskX = tonumber(p2)
						taskZ = tonumber(p3)
						dirrection = "Forward"
					else
						print("ERROR: Could not locate!")
					end
				end
			end
		end
	end
	if(event == "timer") then
		timedtask = timedtask + 1
		if((timedtask % 10) == 1) then
			i = 1
			count = 0
			slots = 0
			while(i < 10) do
				count = count + turtle.getItemCount(i)
				if(turtle.getItemCount(i) ~= 0) then
					slots = slots + 1
				end
				i = tonumber(i + 1)
			end
			rednet.send(Main,"Display,inventory,"..slots.."/"..count)
		end
		
		if(task ~= nil) then
			if(StartX ~= nil) then
				difX = nowX - StartX
				difY = nowY - StartY
				difZ = nowZ - StartZ
				if(task == "mine") then
					if(difX ~= taskX) then
						if(difZ == taskZ and dirrection == "Forward") then
							dirrection = "Backward"
						elseif(difZ == taskZ and dirrection == "Backward") then
							dirrection = "Forward"
						else
							if(isBreakableFront() and isBreakableTop()) then
								turtle.dig()
								turtle.digUp()
								turtle.forward()
							else
								ClearX = difX
								ClearZ = difZ
								task = "clear"
							end
						end
					else
						task = "endclear"
					end
				elseif(task == "clears" or task == "endclear" or task == "clearY" or task == "endclearY") then
					if(difX == 0 and (task == "clears" or task == "endclear")) then
						turtle.turnRight()
					elseif(difY == 0 and task == "clearY" or task == "endclearY") then
						--TODO
						--InventarLeeren
						if(task == "endclearY") then
							task = nil
						elseif(task == "clearY") then
							task = "mine"
						end
					else
						turtle.forward()
					end
					if(turtle.detect()) then
						turtle.dig()
					end
				else
				
				end
			else
				print("ERROR: Could not locate!")
			end
		end
		
		if(timedtask > 99) then
			timedtask = 0
		end
		if(conectiontimer ~= nil) then
			if((conectiontimer % 10) == 0) then
				write(".")
			end
			conectiontimer = conectiontimer + 1
			if(conectiontimer > 100) then
				print("")
				print("Timed Out")
				run = false
			end
			if(run) then
				rednet.broadcast(key.."connectConsole")
			end
		end
		os.startTimer(0.1)
	end
end

if(isturtle == false) then
	print("Run this on a turtle")
end