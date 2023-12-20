
--Start of Global Scope---------------------------------------------------------

-- Check if Monitor API is available
assert(Monitor, 'Monitor not available. Check device capabilities')

-- Create a periodic timer for cyclic retrieval of monitor data
-- luacheck: globals gTmr
gTmr = Timer.create()
Timer.setExpirationTime(gTmr, 1000)
Timer.setPeriodic(gTmr, true)

-- Create the monitors
local cpu = Monitor.CPU.create()
local mem = Monitor.Memory.create()
local net = Monitor.Network.create('ALL')
local _APPNAME = Engine.getCurrentAppName()
local app = Monitor.App.create(_APPNAME)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---Declaration of the 'main' function as an entry point for the event loop
local function main()
  -- Starting timer
  Timer.start(gTmr)
end
--The following registration is part of the global scope which runs once after startup

Script.register('Engine.OnStarted', main)

---Retrieve cpu information
local function printCPUMonitor()
  local overall,
    cores = cpu:getLoad()

  print('CPU Monitor:')
  print(string.format('\tOverall [Percent]: %.1f', overall))
  for index, val in pairs(cores) do
    print(string.format('\tCore %d: %.1f', index, val))
  end
end

---Retrieve memory information
local function printMemoryMonitor()
  local used,
    cap,
    percent = mem:getUsage()

  print('Memory Monitor:')
  print('\tUsed [Bytes]: ' .. used)
  print('\tCapacity [Bytes]: ' .. cap)
  print('\tUsed [Percent]: ' .. percent)
end

---Retrieve App information
local function printAppMonitor()
  local status,
    additional = app:getStatusInfo()
  local use = app:getMemoryUsage()
  local dataUse,
    dataCap,
    percent = app:getPrivateDataUsage()

  print(string.format('App Monitor %s:', _APPNAME))
  print('\tApp Status: ' .. status)
  print('\tAdditional Status Info: ' .. additional)
  print('\tMemory Used [Bytes]: ' .. use)
  print('\tPrivat Data Usage [Bytes]: ' .. dataUse)
  print('\tApp Data Capacity [Bytes]: ' .. dataCap)
  print('\tApp Data Usage [Percent]: ' .. percent)
end

---Retrieve Network information
local function printNetworkMonitor()
  local sent,
    rec = net:getLoad()

  print('Network Monitor:')
  print('\tSent: ' .. sent)
  print('\tReceived: ' .. rec)
end

local function printMonitors()
  printCPUMonitor()
  printMemoryMonitor()
  printAppMonitor()
  printNetworkMonitor()
end
--Registration of the 'printMonitors' function to the timer 'OnExpired' event
Timer.register(gTmr, 'OnExpired', printMonitors)

--End of Function and Event Scope-----------------------------------------------
