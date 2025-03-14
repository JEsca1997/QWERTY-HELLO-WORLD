sub Main()
    print "Starting Main.brs"
    print "============================= ENTER ========================================= MAIN ========================================= ENTER ===================="
   
    top = CreateObject("roSGScreen")
    m.screen = top

    m.port = CreateObject("roMessagePort")

    m.screen.setMessagePort(m.port)
    m.scene = m.screen.CreateScene("Bright_Browser")

    m.screen.show()

    ' Main event loop
    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then
                exit while
            else if msg.isKeyEvent()
                if msg.getPhase() = "keyDown"
                    key = msg.getKey()
                end if
            end if
        end if
    end while
    print "============================= ENTER ========================================= MAIN ========================================= ENTER ===================="
end sub
