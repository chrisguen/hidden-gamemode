-- author: Nikos Kapraras
-- email:  nikos@kapraran.dev

-- TimerClass
local TimersClass = class('TimersClass')

function TimersClass:__init()
  self.lastId = 1
  self.activeTimers = 0
  self.timers = {}
  self.updateEvent = nil

  -- flags
  self.__updating = false
  self.__createdDuringUpdate = false
end

function TimersClass:Update()
  self.__updating = true
  self.__createdDuringUpdate = false

  local now = SharedUtils:GetTimeMS()
  for id, timer in pairs(self.timers) do
    if timer ~= nil then
      timer:Update(now)
    end

    if self.__createdDuringUpdate then
      return self:Update()
    end
  end
  self.__updating = false
end

function TimersClass:Remove(timer)
  if self.timers[timer.id] == nil then
    return
  end

  self.timers[timer.id] = nil

  -- unsubscribe from update event if needed
  self.activeTimers = self.activeTimers - 1
  if self.updateEvent ~= nil and self.activeTimers < 1 then
    self.updateEvent:Unsubscribe()
    self.updateEvent = nil
  end
end

function TimersClass:RemoveAll()
  -- unsubscribe from update event
  if self.updateEvent ~= nil then
    self.updateEvent:Unsubscribe()
    self.updateEvent = nil
  end

  -- destroy all timers
  for id, timer in pairs(self.timers) do
    if timer ~= nil then
      timer:Destroy()
    end
  end

  self.activeTimers = 0
  self.timers = {}
end

function TimersClass:CreateTimer(delay, cycles, userData, callback)
  self.lastId = self.lastId + 1
  local timer = Timer(self, tostring(self.lastId), delay, cycles, userData, callback)
  self.timers[timer.id] = timer
  if self.__updating then
    self.__createdDuringUpdate = true
  end

  -- subscribe to update event if needed
  self.activeTimers = self.activeTimers + 1
  if self.updateEvent == nil then
    self.updateEvent = Events:Subscribe('Engine:Update', self, self.Update)
  end

  return timer
end

-- run once after the specified delay
function TimersClass:Timeout(delay, userData, callback)
  return self:CreateTimer(delay, 1, userData, callback)
end

-- run for a certain amount of times with the specified delay in between calls
function TimersClass:Sequence(delay, cycles, userData, callback)
  return self:CreateTimer(delay, cycles, userData, callback)
end

-- run forever with the specified delay in between calls
function TimersClass:Interval(delay, userData, callback)
  return self:CreateTimer(delay, 0, userData, callback)
end

-- Timer
local Timer = class('Timer')

function Timer:__init(master, id, delay, cycles, userData, callback)
  self.master = master
  self.id = id
  self.delay = delay * 1000
  self.cycles = cycles
  self.userData = userData
  self.callback = callback

  if userData ~= nil and callback == nil then
    self.userData = nil
    self.callback = userData
  end

  self.currentCycle = 0
  self.startedAt = SharedUtils:GetTimeMS()
  self.updatedAt = self.startedAt
end

-- update timer's delta
function Timer:Update(now)
  if self.callback ~= nil and now - self.updatedAt >= self.delay then
    self.updatedAt = now

    -- call the callback
    if self.userData ~= nil then
      self.callback(self.userData, self)
    else
      self.callback(self)
    end

    -- move to next cycle
    if not self:Next() then
      self:Destroy()
    end
  end
end

-- move to the next cycle
function Timer:Next()
  if self.cycles == 0 then
    return true
  end

  -- increment cycle counter
  self.currentCycle = self.currentCycle + 1
  if self.currentCycle >= self.cycles then
    self.currentCycle = self.cycles
    return false
  end

  return true
end

-- destroy the timer
function Timer:Destroy()
  self.master:Remove(self)

  self.callback = nil
  self.userData = nil
end

-- 
function Timer:Elapsed()
  return (SharedUtils:GetTimeMS() - self.startedAt) / 1000
end

-- 
function Timer:Remaining()
  if self.cycles == 0 then
    return 0
  end

  return math.max(0, (self.cycles - self.currentCycle) * self.delay) / 1000
end

-- init Timers singleton
Timers = TimersClass()
