local lift = {}
lift.__index = lift


setmetatable(lift, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- constructor function
function lift.new(controller,sensor)
  local self = setmetatable({},lift)
  self.controller = peripheral.wrap(controller)
  self.sensor = peripheral.wrap(sensor)


  self.new = function() error("Instances may not create other instances!",2) end
  return self
end


--returns where the lift is
function lift:getPos()
  return self.sensor.getBlockData().Offset
end


function lift:send(distance)
  local distance = distance or 0
  self.controller.setOutput("right",false)
  if distance > self:getPos() then
    repeat
      self.controller.setOutput("back",true)
    until self:getPos() >= distance
    self.controller.setOutput("right",true)
  else
    repeat
      self.controller.setOutput("back",false)
    until self:getPos() <= distance
  self.controller.setOutput("right",true)
  end
  return self:getPos()
end

return lift