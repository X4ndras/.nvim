--[[ 
    Welcome to Code: Color
]]--

-- Importing modules
local json = require("json")

-- Defining a table (equivalent to a struct or class)
local Person = {
    name = "",
    age = 0,
    flying_force = 0.0
}

-- Constructor function
function Person:new(name, age, flying_force)
    local p = {}
    setmetatable(p, self)
    self.__index = self
    p.name = name
    p.age = age
    p.flying_force = flying_force
    return p
end

-- Method to display details
function Person:speak()
    print("Hello, my name is " .. self.name)
    json = {}
    print(json)
end

-- Creating an instance
local alice = Person:new("Alice", 30, 9999.99)
alice:speak()

-- Control structures
if alice.age > 18 then
    print("Alice is an adult")
else
    print("Alice is not an adult")
end

-- Iterating through a table
local colors = {"red", "green", "blue"}
for i, color in ipairs(colors) do
    print("Color: " .. color .. i)
end

-- Using coroutines
local co = coroutine.create(function()
    print("Running coroutine")
end)
coroutine.resume(co)

-- Error handling
local status, err = pcall(function()
    error("Something went wrong!")
end)
if not status then
    print("Error: " .. err)
end
