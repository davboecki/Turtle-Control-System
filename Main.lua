key = "TurtleControlSystem"

PING_MAX = 10

rednet.open("back")

Display = nil
DisplayPing = 0
Console = nil
ConsolePing = 0

ID = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Ping = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
NextPing = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
PingTime = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
nPos = 0

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

--Console Init
sLine = ""
nHistoryPos = nil
nPos = 0
_tHistory = {}

w, h = term.getSize()
sx, sy = term.getCursorPos()

function print( ... )
	term.setCursorBlink( false )
	term.setCursorPos(1, sy)
	write(string.rep(" ",w))
	term.setCursorPos(1, sy)
	local nLinesPrinted = 0
	for n,v in ipairs( { ... } ) do
		nLinesPrinted = nLinesPrinted + write( tostring( v ) )
	end
	nLinesPrinted = nLinesPrinted + write( "\n" )
	sx, sy = term.getCursorPos()
	ConsoleText()
	return nLinesPrinted
end

function ConsoleText()
	term.setCursorBlink( false )
	term.setCursorPos( sx, sy )
	term.write( string.rep(" ", w - sx + 1) )
	term.setCursorPos( sx, sy )
	term.write( sLine )
	term.setCursorPos( sx + nPos, sy )
	term.setCursorBlink( true )
end

function Command(input)
if(input == "exit") then
	run = false
elseif(input == "reboot") then
	os.reboot()
elseif(input == "shutdown") then
	os.shutdown()
elseif(input == "info") then
	print("DisplayPing:"..DisplayPing)
	print("ConsolePing:"..ConsolePing)
	print("sx:"..sx)
	print("sy:"..sy)
elseif(input == "clear") then
	term.clear()
	term.setCursorPos(1,1)
else
	print("Unknown command")
end
end

term.setCursorBlink( true )
--Console End

os.startTimer(1)

run = true
while(run) do
	--print("Running")
	event,param1,param2 = os.pullEvent()
	--if(event ~= "timer") then
	--	print(event)
	--	print(param1)
	--	print(param2)
	--end
	if(event == "rednet_message") then
		if(param2 == key.."connectDisplay" and (Display ~= nil or DisplayPing > 6)) then
			Display = param1
			print("Display Connected")
			rednet.send(param1,"connectMain")
		end
		if(param2 == key.."connectConsole" and (Console ~= nil or ConsolePing > 6)) then
			Console = param1
			print("Console Connected")
			rednet.send(param1,"connectMain")
		end
		if(param2 == "ping") then
			if(param1 == Display) then
				DisplayPing = 0
				rednet.send(Display,"pong")
			end
			if(param1 == Console) then
				ConsolePing = 0
				rednet.send(Console,"pong")
			end
			i = 0
			done = 0
			while(i<33 and done == 0) do
				if(param1 == ID[i]) then
					rednet.send(param1,"pong")
				end
				i = i + 1
			end
		end
		if(Display ~= nil and Console ~= nil) then
			if(param2 == key.."connectTurtle") then
				i=0
				done = 0
				while(i<33) do
					if(ID[i] ~= 0 and ID[i] == param1) then
						print("Connecting known Turtle")
						rednet.send(param1, "ping")
						rednet.send(param1,"connectMain")
						done = 1
					end
					i=i+1
				end
				i = 0
				while(i<33 and done == 0) do
					if(ID[i] == 0) then
						print("Connecting new Turtle")
						ID[i] = param1
						rednet.send(Display,"NewTurtle,"..i..","..param1)
						rednet.send(param1, "ping")
						rednet.send(param1,"connectMain")
						done = 1
					end
					i=i+1
				end
			end
			if(param2 == "TurtleDisconnect") then
				i = 0
				done = 0
				while(i<33 and done == 0) do
					if(param1 == ID[i]) then
						ID[i] = 0
						rednet.send(Display,"TurtleDisconect,"..param1)
						done = 1
					end
					i=i+1
				end
			end
			if(param2 == "pong") then
				i = 0
				done = 0
				while(i<33 and done == 0) do
					if(param1 == ID[i]) then
						Ping[i] = 0
						dtime = os.clock() - PingTime[i]
						if(dtime == 0) then
							dtime = 1
						end
						rednet.send(Display,"pingtime,"..i..","..dtime)
						done = 1
					end
					i=i+1
				end
			end
			array = split(param2, ",")
			p1, p2, p3 = array[1], array[2], array[3]
			if(p1 == "Display") then
				i = 0
				done = 0
				while(i<33 and done == 0) do
					if(param1 == ID[i]) then
						rednet.send(Display,p2..","..i..","..p3)
						done = 1
					end
					i=i+1
				end
			end
		end
	end
	-- Console
	if(event == "char") then
		sLine = string.sub( sLine, 1, nPos ) .. param1 .. string.sub( sLine, nPos + 1 )
		nPos = nPos + 1
		ConsoleText()
	end
	if event == "key" then
	    if param1 == 28 then
			-- Enter
			print(sLine)
			nPos = 0
			Command(sLine)
			table.insert(_tHistory, sLine)
			sLine = ""
			ConsoleText()
			
		elseif param1 == 203 then
			-- Left
			if nPos > 0 then
				nPos = nPos - 1
				ConsoleText()
			end
			
		elseif param1 == 205 then
			-- Right				
			if nPos < string.len(sLine) then
				nPos = nPos + 1
				ConsoleText()
			end
		
		elseif param1 == 200 or param1 == 208 then
            -- Up or down
			if _tHistory then
				if param1 == 200 then
					-- Up
					if nHistoryPos == nil then
						if #_tHistory > 0 then
							nHistoryPos = #_tHistory
						end
					elseif nHistoryPos > 1 then
						nHistoryPos = nHistoryPos - 1
					end
				else
					-- Down
					if nHistoryPos == #_tHistory then
						nHistoryPos = nil
					elseif nHistoryPos ~= nil then
						nHistoryPos = nHistoryPos + 1
					end						
				end
				
				if nHistoryPos then
                   	if(sLine ~= "") then
						table.insert(_tHistory, sLine)
					end
					sLine = _tHistory[nHistoryPos]
                   	nPos = string.len( sLine ) 
                else
					sLine = ""
					nPos = 0
				end
				ConsoleText()
            end
		elseif param1 == 14 then
			-- Backspace
			if nPos > 0 then
				sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
				nPos = nPos - 1					
				ConsoleText()
			end
		end
	end
	-- Console end
	if(event == "timer") then
		os.startTimer(1)
		DisplayPing = DisplayPing + 1
		if(DisplayPing > 6 and Display ~= nil) then
			Display = nil
			print("Lost Display connection")
		end
		ConsolePing = ConsolePing + 1
		if(ConsolePing > 6 and Console ~= nil) then
			Console = nil
			print("Lost Console connection")
		end
		i = 1
		while(i<33) do
			if(ID[i] ~= 0) then
				Ping[i] = Ping[i] + 1
				NextPing[i] = NextPing[i] + 1
				if(Ping[i] > PING_MAX and Ping[i] < (PING_MAX + 2)) then
					rednet.send(Display,"TurtleTimeout,"..i)
				end
				if(NextPing[i] > 5) then
					rednet.send(ID[i],"ping")
					PingTime[i] = os.clock()
					NextPing[i] = 0
				end
			end
			i=i+1
		end
	end
end
