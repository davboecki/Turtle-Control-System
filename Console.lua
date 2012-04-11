key = "TurtleControlSystem"

rednet.open("back")

Main = nil
Ping = 0

ID = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

os.startTimer(1)
run = true
conectiontimer = 0

write("Conntecting.")

rednet.broadcast(key.."connectConsole")

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
	end
	if(event == "rednet_message") then
		if(Main == nil and param2 == "connectMain") then
			Main = param1
			conectiontimer = nil
			print("")
			print("Connected")
		end
		if(Main ~= nil) then
			if(param1 == Main) then
				if(param2 == "pong") then
					Ping = 0
				end
			end
		end
	end
	if(Main ~= nil) then
		if((Ping % 2) == 0) then
			rednet.send(Main,"ping")
			if(Ping > 6) then
				conectiontimer = 0
				Main = nil
				print("Lost Connection to Main")
				write("Conntecting.")
				rednet.broadcast(key.."connectConsole")
			end
		end
		Ping = Ping + 1
	end
	if(event == "timer") then
		os.startTimer(1)
		if(conectiontimer ~= nil) then
			write(".")
			conectiontimer = conectiontimer + 1
			if(conectiontimer > 10) then
				print("")
				print("Timed Out")
				run = false
			end
			if(run) then
				rednet.broadcast(key.."connectConsole")
			end
		end
	end
end