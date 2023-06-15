local bas = require("bas")
local door = require("doors")
local lift = require("skylift")
local monitor = peripheral.wrap("top")
local hatch = door("redrouter_2","blockReader_2")
local pod = lift("redrouter_3","blockReader_3")

local surfaceOffset = 56
--initial setup stuff
local rednet = rednet
rednet.open("right")
monitor.setTextScale(0.5)
local main = bas.addMonitor()
main:setMonitor(monitor)




local frame = main:addFrame()
frame:setSize(monitor.getSize())
frame:setTheme({
  ButtonBG = colors.black,
  ButtonText = colors.white,
  FrameFG = colors.black
})

local termframe = frame:addFrame()
:setSize("parent.w-3",10)
:setPosition(2,"parent.h/2 + 2")


local term = termframe:addProgram()
:setSize("parent.w","parent.h")
:execute("rednetlisten.lua")



local function parse(message,commands)
  if not message.sProtocol == "Lift" then return false end
  if not type(message.message) == "table" then return false end
  if not commands[message.message[1]] then return false end

  commands[message.message[1]](message.message) 

end

local commands = {}

commands.send = function(message)
  if not type(message[2]) == "number" then return false end
  hatch:open()
  pod:send(message[2])
  hatch:close()
  rednet.broadcast(1,"Lift")
end

commands.raise = function(message)
  hatch:open()
  pod:send(0)
  hatch:close()
  rednet.broadcast(0,"Lift")
end

commands.hatchOpen = function(message,reply)
  if not type(message[2]) == "boolean" then return false end
  if message[2] or message then
  hatch:open()
  else
    hatch:close()
  end
  rednet.broadcast(0,"Lift")

end

commands.hatchState = function(message)
  rednet.broadcast(hatch:getState(),"Lift")
end



local hatchButton = frame:addButton()
:setPosition(22, 2)
:setSize(14)
:setText("Toggle Hatch")
:onClick(
  function(self,event,button,x,y)
    if hatch:getState() then
      self:setBackground(colors.black)
      hatch:close()
    else
      self:setBackground(colors.lightGray)
      hatch:open()
    end
    local time = os.time()
    local ftime = textutils.formatTime(time, false)  
    local str = "["..ftime.." @ID:"..os.computerID().."]".."Manual Hatch Toggle"
    bas.log(str)
  end)
:onEvent(
  function(self)
    if hatch:getState() then
      self:setBackground(colors.lightGray)
    elseif not hatch:getState() then
      self:setBackground(colors.black)
    end
  end
)

  
local liftLabel = frame:addButton()
:setPosition("parent.w/2-3",9)
:setSize(6,3)
:setText("25")
:setHorizontalAlign("center")

--


local slider = frame:addSlider()
:setPosition(2,7)
:setForeground(colors.black)
:setSymbol("\8")
:setSize(55,1)
:setMaxValue(surfaceOffset)
:setIndex(25)
:onChange(
  function(self,event,value)
    liftLabel:setText(tostring(math.ceil(value)))
  end
)
--
liftLabel:onClick(
  function(self,event,button,x,y)
    if hatch:getState() then
      hatch:open()
      pod:send(math.ceil(slider:getIndex()))
      hatch:close()
      local time = os.time()
      local ftime = textutils.formatTime(time, false)  
      local str = "["..ftime.." @ID:"..os.computerID().."]".."Manual Lift Custom Drop."
      bas.log(str)
    end
  end
)
--
local liftButton1 = frame:addButton()
:setPosition(2, 2)
:setSize(14)
:setText("Drop Lift")
:onClick(
  function()
    hatch:open()
    pod:send(surfaceOffset)
    hatch:close()
    local time = os.time()
    local ftime = textutils.formatTime(time, false)  
    local str = "["..ftime.." @ID:"..os.computerID().."]".."Manual Lift Drop."
    bas.log(str)
  end
)

--
local liftButton2 = frame:addButton()
:setPosition(43, 2)
:setSize(14)
:setText("Raise Lift")
:onClick(
  function()
    hatch:open()
    pod:send(0)
    hatch:close()
  end
)

--

frame:onEvent(
  function(self,event,side,channel,replyChannel,message,distance)
    if(event == "modem_message") then
      
      parse(message,commands)

      local time = os.time()
      local ftime = textutils.formatTime(time, false)  
      local str = "["..ftime.." @ID:"..message.nSender.."]"..message.message
      term:injectEvent("message",true,str)
      bas.log(str)
    end
  end
)




--dirty hack, running this in parallel with the frontend makes it so the buttons can update automatically by queueing a dummy event every second to refresh
local function update()
  while true do
    sleep(1)
    os.queueEvent("dummy")
  end
end








bas.autoUpdate()
