-- Crash
-- 
-- A simple random drum machine
--
-- enc1 - busyness: 
-- number of events per beat
--
-- enc2 - everything:
-- Chance of an event triggering a 'fill'
--
-- enc3 - nothing:
-- Chance of not playing a sample on an event
--
-- key3 - stop/start

engine.name = 'Ack'
local UI = require "ui"

local crash_id = -1

-- number of events per beat
local busyness = 2
local clock_sync

-- chance of skipping a beat 0 = never skip, 10 = skip every beat
local nothing = 1

-- chance of a fill at any given beat
local everything = 1
local fill_chance

local sample_path = _path.dust.."audio/common/606"
local samples_loaded = 0

local dial_everything
local dial_nothing
local dial_busyness

function init()
  load_samples()
  
  params:add_number("busyness", "busyness", 1, 4, busyness)
  params:set_action("busyness", function(value) busyness = value end)
  dial_busyness = UI.Dial.new(53, 0, 22, busyness, 1, 4, 0.01, 0, {}, "", "busyness")
  clock_sync = busyness
  
  params:add_number("everything", "everything", 0, 10, everything)
  params:set_action("everything", function(value) everything = value end)
  dial_everything = UI.Dial.new(20, 30, 22, everything, 0, 10, 0.01, 0, {}, "", "everything")
  fill_chance = everything
  
  params:add_number("nothing", "nothing", 0, 10, nothing)
  params:set_action("nothing", function(value) nothing = value end)
  dial_nothing = UI.Dial.new(86, 30, 22, nothing, 0, 10, 0.01, 0, {}, "", "nothing")
  
  start_stop()
  redraw()
end

-- load the first 8 files in sample_path
function load_samples()
  local i = 0
  local f = io.popen('ls ' .. sample_path .. '/*.wav')
  
  for name in f:lines() do
    engine.loadSample(i, name)

    if i < 7 then
      i = i + 1
    else
      break  
    end
  end
  samples_loaded = i
end

function start_stop()
  if crash_id > -1 then
    clock.cancel(crash_id)
    crash_id = -1
  elseif samples_loaded > 0 then
    crash_id = clock.run(crash)
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    start_stop()
  end
end

function enc(n, d)
  if n == 1 then
    params:delta("busyness", d)
  elseif n == 2 then
    params:delta("everything", d)
  elseif n == 3 then
    params:delta("nothing", d)    
  end
  redraw()
end

function redraw()
  screen.clear()
  
  dial_everything:set_value(params:get("everything"))
  dial_everything:redraw()
  
  dial_nothing:set_value(params:get("nothing"))
  dial_nothing:redraw()
  
  dial_busyness:set_value(params:get("busyness"))
  dial_busyness:redraw()  
  
  if samples_loaded < 1 then
    screen.level(1)
    screen.rect(14, 20, 100, 36)
    screen.fill()

    screen.level(15)
    screen.move(26, 40)
    screen.text("No Samples Found")
  end
  
  screen.update()
end

function crash()
  while true do
    clock.sync(1 / clock_sync)

    if math.random(10) > nothing then
      -- pick a sample and play it
      local play_sample = math.random(samples_loaded) - 1
      engine.trig(play_sample)
      
      -- decide if next loop is a fill
      if math.random(10) <= fill_chance then
        clock_sync = busyness * 2
        fill_chance = fill_chance * 2
      else
        clock_sync = busyness
        fill_chance = everything
      end
      
    end
    redraw()
  end
end
