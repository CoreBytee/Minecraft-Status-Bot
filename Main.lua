_G.Client = require("discordia").Client()
local Timer = require("timer")
local Json = require("json")

local Config = require("Config")

local Icon = "https://api.mcsrvstat.us/icon/" .. Config.Ip

local Clock = require("discordia").Clock()
Clock:start()

local Colors = {
    Online = 0x57F287,
    Offline = 0xED4245
}

function Get()
    coroutine.wrap(
        function()
            local Message = require("GetMessage")()
        
            local Worked = pcall(function()
                local Response, RawData = require("coro-http").request("GET", "https://api.mcsrvstat.us/2/" .. Config.Ip)
                local Data = Json.decode(RawData)

                p(Data)

                if Data.online then
                    local MessageData = {embed = {
                        title = "Online",
                        description = "The server is online :tada:,\nHop on via " .. Config.Ip,
                        thumbnail = {url = Icon},
                        color = Colors.Online,

                        fields = {
                            {
                                name = "Player count",
                                value = Data.players.online .. "/" .. Data.players.max,
                                inline = true
                            },

                            {
                                name = "Player list",
                                value = "None",
                                inline = true
                            },

                            {
                                name = "Message of the day!",
                                value = table.concat(Data.motd.clean, "\n")
                            },

                            {
                                name = "Mod count",
                                value = #Data.mods.names
                            }
                        },

                        footer = {text = "Last updated"},
                        timestamp = require("discordia").Date():toISO()
                    }}

                    

                    if Data.players.list then
                        MessageData.embed.fields[2].value = table.concat(Data.players.list, "\n")
                    end

                    Message:update(MessageData)
                else
                    local MessageData = {embed = {
                        title = "Online",
                        description = "The server is offline :sob:,\nCheck back later",
                        thumbnail = {url = Icon},
                        color = Colors.Offline,

                        footer = {text = "Last updated"},
                        timestamp = require("discordia").Date():toISO()
                    }}

                    Message:update(MessageData)
                end

            end)

            if not Worked then
                print("Error")
                Message:update({embed = {
                    title = "Error",
                    description = "An error occurred, Come back in 5 minutes",
                    thumbnail = {url = Icon},
                    color = Colors.Offline,

                    footer = {text = "Last updated"},
                    timestamp = require("discordia").Date():toISO()
                }})
            end
            
        end
    )()
end

Client:once("ready", function()
    Get()

    ---Timer.setInterval(
    ---    1000 * 60 * 5,
    ---    Get
    ---)

    Clock:on("min", function(TimeData)
        if TimeData.min % 5 ~= 0 then return end
        Get()
    end)

end)

Client:run("Bot " .. require("./Token.lua"))
Client:setGame("Minecraft")

