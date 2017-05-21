i2c.setup(0, 3, 4, i2c.SLOW)
lcd = dofile("lcd1602x.lua")()
tmr.delay(500)
lcd:put(lcd:locate(0,0),"WiFi Init.")

wifi.setmode(wifi.STATION)
wifi.sta.config("SSID", "Password")
wifi.sta.autoconnect(1)
M = {}

tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
        lcd:put(".")
    else
        lcd:clear()
        lcd:put(lcd:locate(0,0),"IP Address:")
        ip = wifi.sta.getip()
        lcd:put(lcd:locate(1,0),ip)
        tmr.stop(0)
        tmr.delay(1000)
    end
 
end)

tmr.alarm(2, 20000, 1, function()
    local t = M[2]
    if t ~= nil then
        --lcd:clear()
        tm = rtctime.epoch2cal(rtctime.get())
        lcd:put(lcd:locate(0,0),string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
        --lcd:put(lcd:locate(1,0),string.format("%sC %s%s %s", t['temp'], t['hum'], "%", t['bar']))
    end
end)
tmr.stop(2)


function getJson()
    http.get("http://[WEBSERWER]/sender.php", nil, function(code, data)
        if (code < 0) then
        print("HTTP request failed")
        else
     
        M[1] = code
        M[2] = cjson.decode(data)
      
        end
    end)
end


tmr.alarm(1,1000,1,function()
    if wifi.sta.getip() ~= nil then
       getJson()
       tmr.delay(100)
        
        if  M[2] ~= nil then
            --print(M[2])
            datagram = M[2]

            if datagram ~= nil then
                rtctime.set(datagram['timestamp'])
                lcd:clear()
                tm = rtctime.epoch2cal(rtctime.get())
                lcd:put(lcd:locate(0,0),string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
                lcd:put(lcd:locate(1,0),string.format("%sC %s%s %s", datagram['temp'], datagram['hum'], "%", datagram['bar']))
            end
            
            timerstate,option = tmr.state(2)
            if not timerstate then
                tmr.stop(1)
                tmr.interval(1, 900000)
                tmr.start(2)
                tmr.start(1)
            end
        end      
    end
end)



