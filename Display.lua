key = "TurtleControlSystem"

rednet.open("back")

Main = nil
Ping = 0

ID = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

os.startTimer(1)
run = true
if(peripheral.getType("right") ~= "monitor") then
	print("No monitor connected to the right")
	run = false
end
local monitor = peripheral.wrap("right")
x,y = monitor.getSize()
if(x ~= 77 or y ~= 38) then
	print("Monitor is to small")
	run = false
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

function Number(iid)
	id = tonumber(iid)
	if(id == 0) then return "  [N/A] "
    elseif(id < 10) then return "   ["..id.."]  "
    elseif(id < 100) then return "  ["..id.."]  "
    elseif(id < 1000) then return "  ["..id.."] "
    elseif(id < 10000) then return " ["..id.."] "
    else return tostring(id) end
end

function MidInv(String)
	id = string.len(String)
	if(id == 0 or String == "0" or String == "0/0") then return "   empty   "
    elseif(id == 1) then return "     "..String.."     "
    elseif(id == 2) then return "    "..String.."     "
    elseif(id == 3) then return "    "..String.."    "
    elseif(id == 4) then return "   "..String.."    "
    elseif(id == 5) then return "   "..String.."   "
    elseif(id == 6) then return "  "..String.."   "
    elseif(id == 7) then return "  "..String.."  "
    elseif(id == 8) then return " "..String.."  "
    elseif(id == 9) then return " "..String.." "
    else return String end
end

function NumberPing(iid)
	id = math.floor(tonumber(iid))
	if(id == 0 and iid ~= "0") then
		id = 1
	end
	if(id == 0) then return " N/A  "
    elseif(id < 10) then return "  "..id.."   "
    elseif(id < 100) then return "  "..id.."  "
    elseif(id < 1000) then return " "..id.."  "
    elseif(id < 10000) then return " "..id.." "
	elseif(id > 999999) then return "Overfl";
    else return tostring(id) end
end

function displaymonitor(monitor)
	--Clear Display
	monitor.clear()
	--Init Monitor
	monitor.setCursorPos(28,1)
	monitor.write("Turtle Control System")
	monitor.setCursorPos(1,2)
	monitor.write("-----------------------------------------------------------------------------")
	monitor.setCursorPos(1,3)
	monitor.write("|---ID---|--Connection--|-Progress-|--Task--|-Ping-|---Status---|-Inventory-|")
	monitor.setCursorPos(1,4)
	monitor.write("|---------------------------------------------------------------------------|")
	i = 5
	while(i < 38) do
	monitor.setCursorPos(1,i)
		n = i - 4
		monitor.write("|"..Number(ID[n]).."|              |          |        |      |            |           |")
		i = i + 1
	end
	monitor.setCursorPos(1,38)
	monitor.write("-----------------------------------------------------------------------------")
end

monitor.clear()
monitor.setCursorBlink(false)
monitor.setCursorPos(1,1)
monitor.write("Welcome")
monitor.setCursorPos(1,2)
monitor.write("Connecting")

conectiontimer = 0
rednet.broadcast(key.."connectDisplay")

write("Conntecting.")

while(run) do
	--print("Running: "..number)
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
	end
	if(event == "rednet_message") then
		if(Main == nil and param2 == "connectMain") then
			Main = param1
			Ping = 0
			conectiontimer = nil
			print("")
			print("Connected")
			displaymonitor(monitor)
		end
		if(Main ~= nil) then
			if(param1 == Main) then
				if(param2 == "pong") then
					Ping = 0
				else
					array = split(param2, ",")
					p1, p2, p3 = array[1], array[2], array[3]
					--     |---ID---|--Connection--|-Progress-|--Task--|-Ping-|---Status---|-Inventory-|
					if(p1 == "NewTurtle") then
						ID[p2] = p3
						monitor.setCursorPos(1,tonumber(p2)+4)
						monitor.write("|"..Number(ID[p2]).."|  Connected   |    0%    | clear  | N/A  |   sleep    |     0     |")
					end
					if(p1 == "TurtleDisconect") then
						ID[p2] = 0
						monitor.setCursorPos(1,tonumber(p2)+4)
						monitor.write("|"..Number(ID[p2]).."|              |          |        |      |            |           |")
					end
					if(p1 == "TurtleTimeout") then
						monitor.setCursorPos(11,tonumber(p2)+4)
						monitor.write("  Timed Out   ")
						monitor.setCursorPos(46,tonumber(p2)+4)
						monitor.write(NumberPing(0))
					end
					if(p1 == "pingtime") then
						monitor.setCursorPos(46,tonumber(p2)+4)
						monitor.write(NumberPing(p3))
					end
					if(p1 == "inventory") then
						monitor.setCursorPos(66,tonumber(p2)+4)
						monitor.write(MidInv(p3))
					end
				end
			end
		end
	end
	if(event == "timer") then
		os.startTimer(1)
		x,y = monitor.getSize()
		if(x ~= 77 or y ~= 38) then
			print("Monitor is to small")
			monitor.setCursorPos(1,1)
			i = 1
			while(i<(y+1)) do
				j = 1
				while(j<x) do
					monitor.write("ERROR ")
					j = j + 1
				end
				monitor.setCursorPos(1,i)
				i = i + 1
			end
			monitor.setCursorPos(1,i-1)
			monitor.write("Please restart the programm")
			run = false
		end
		if(Main ~= nil) then
			if((Ping % 2) == 0) then
				rednet.send(Main,"ping")
				if(Ping > 6) then
					conectiontimer = 0
					Main = nil
					monitor.clear()
					monitor.setCursorPos(30,18)
					monitor.write("Lost Connection")
					monitor.setCursorPos(30,19)
					monitor.write("Connecting")
					print("Lost Connection to Main")
					write("Conntecting.")
					rednet.broadcast(key.."connectDisplay")
				end
			end
			Ping = Ping + 1
		end
		if(conectiontimer ~= nil) then
			write(".")
			conectiontimer = conectiontimer + 1
			if(conectiontimer > 10) then
				print("")
				print("Timed Out")
				monitor.clear()
				run = false
			end
			if(run) then
				rednet.broadcast(key.."connectConsole")
			end
		end
	end
end
