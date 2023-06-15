local doors = {}
doors.__index = doors

setmetatable(doors, {
  __call = function(cls, ...)
    return cls.new(...)
  end
})

-- constructor function
function doors.new(controller, sensor)
  local self = setmetatable({}, doors)
  self.controller = peripheral.wrap(controller)
  self.sensor = peripheral.wrap(sensor)
  self.openAngle = 45

  self.new = function()
    error("Instances may not create other instances!", 2)
  end
  return self
end

-- opens the hatch door and only returns after the door opens
function doors:open()
  self.controller.setOutput("right", false)
  self.controller.setOutput("left", false)
  if self:getState() then
    return
  end
  repeat
    self.controller.setOutput("right", true)
  until self.sensor.getBlockData().Angle > self.openAngle
  self.controller.setOutput("right", false)
end

-- shuts the hatch door and only returns after the door shuts
function doors:close()
  self.controller.setOutput("right", false)
  self.controller.setOutput("left", false)
  if not self:getState() then
    return
  end
  repeat
    self.controller.setOutput("left", true)
  until self.sensor.getBlockData().Angle < 5
  self.controller.setOutput("left", false)
end

-- opens the hatch door and only returns after the door opens
function doors:quickOpen()
  self.controller.setOutput("right", false)
  self.controller.setOutput("left", false)
  if self:getState() then
    return
  end
  self.controller.setOutput("right", true)
  sleep(0.5)
  self.controller.setOutput("right", false)
end

-- shuts the hatch door and only returns after the door shuts
function doors:quickClose()
  self.controller.setOutput("right", false)
  self.controller.setOutput("left", false)
  if not self:getState() then
    return
  end
  self.controller.setOutput("left", true)
  sleep(0.5)
  self.controller.setOutput("left", false)
end

-- gets the door state
function doors:getState()
  if self.sensor.getBlockData().Angle > self.openAngle then
    return true
  elseif self.sensor.getBlockData().Angle < 5 then
    return false
  end
end

return doors
