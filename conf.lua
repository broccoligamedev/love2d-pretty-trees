function love.conf(t)
    t.console = true -- enable the console
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
	if love.load then
		love.load(arg)
	end
	if love.timer then 
		love.timer.step()
	end
	local dt = 0
	local accumulator = 0
	local TICK_RATE = 1 / 30
	while true do
		-- process events
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		-- update dt
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		-- limit dt
		if dt > TICK_RATE * 2 then 
			dt = TICK_RATE * 2
		end
		-- update game
		accumulator = accumulator + dt
		while accumulator >= TICK_RATE do
			accumulator = accumulator - TICK_RATE
			if love.update then 
				love.update()
			end
		end
		-- render game
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then
				local alpha = accumulator / TICK_RATE
				love.draw(alpha)
			end
			love.graphics.present()
		end
		-- sleep
		if love.timer then 
			love.timer.sleep(0.001)
		end
	end
end