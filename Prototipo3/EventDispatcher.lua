local EventDispatcher = {}
local listeners = {}

function EventDispatcher.subscribe(event, callback)
    if not listeners[event] then
        listeners[event] = {}
    end
    table.insert(listeners[event], callback)
end

function EventDispatcher.publish(event, ...)
    if listeners[event] then
        for _, callback in ipairs(listeners[event]) do
            callback(...)
        end
    end
end

return EventDispatcher