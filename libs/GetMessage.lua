local FS = require("fs")

return function()
    local Data = require("../Config.lua")

    local Server = Client:getGuild(Data.Server)
    print("Server is " .. tostring(Server))

    local Channel = Server:getChannel(Data.Channel)
    print("Channel is " .. tostring(Channel))

    local Message = Channel:getMessage(Data.Message)
    print("Message " .. tostring(Message))

    if not Message then
        Message = Channel:send("Loading")
        Data.Message = Message.id

        local StringData = "return " .. require("TableToString")(Data)

        FS.writeFileSync("./Config.lua", StringData)
    end

    return Message
end 