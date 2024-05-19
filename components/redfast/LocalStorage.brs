function CreateLocalStorage() as Object
    m = {}
    m.sec = CreateObject("roRegistrySection", "Redfast")
    m.createNewOverlayKey = createNewOverlayKey
    m.deleteOverylayKey = deleteOverylayKey
    m.isOverlayEnabled = isOverlayEnabled
    m.reset = reset
    m.hasHoldOutPresented = hasHoldOutPresented
    m.createHoldOutKey = createHoldOutKey
    return m
end function

sub createNewOverlayKey(overlayPathId as String, disabledInterval as String)
    date = CreateObject("roDateTime")
    value = date.AsSeconds().ToStr() + ","
    if disabledInterval = "INF"
        value += "-1"
    else if disabledInterval = "VISIT"
        value += "-2"
    else
        value += Str(Val(disabledInterval, 10) * 60) 'minutes to seconds
    end if
    print "Rf: promos " + overlayPathId + " is disabled for " + value.toStr() + " seconds"
    m.sec.Write(overlayPathId, value)
    m.sec.Flush()
end sub

sub deleteOverylayKey(overlayPathId as String)
    print "Rf: promos " + overlayPathId + " is deleted"
    m.sec.Delete(overlayPathId)
    m.sec.Flush()
end sub

function isOverlayEnabled(overlayPathId as String) as Boolean
    if m.sec.Exists(overlayPathId)
        value = m.sec.Read(overlayPathId)
        components = value.Split(",")
        if components.Count() = 2
            start = Val(components[0], 10)
            interval = Val(components[1], 10)
            date = CreateObject("roDateTime")
            now = date.AsSeconds()
            if interval = -1 or interval = -2 or (start + interval > now)
                print "Rf: promos " + overlayPathId + " is blocked due to " +  value + " and now " + now.toStr()
                return false
            end if
        end if
        m.deleteOverylayKey(overlayPathId)
    end if
    return true
end function

sub reset(visitOnly as boolean)
    keys = m.sec.GetKeyList()
    keyCount = keys.count()
    visitCount = 0
    for ii = 0 to keys.count() - 1 step 1
        key = keys[ii]
        if visitOnly
            value = m.sec.Read(key)
            components = value.Split(",")
            if components.Count() = 2
                interval = Val(components[1], 10)
                if interval = -2
                    m.sec.Delete(key)
                    visitCount += 1
                end if
            end if
        else
            m.sec.Delete(key)
        end if
    end for
    m.sec.Flush()
    if visitOnly
        print "Rf: reset VISIT promos, total " + visitCount.toStr()
    else
        print "Rf: reset all promos, total " + keyCount.toStr()
    end if
end sub

sub createHoldOutKey(holdoutPathId as String)
    print "Rf: holdout key created for " + holdoutPathId
    m.sec.Write(holdoutPathId + "_holdout", "true")
    m.sec.Flush()
end sub

function hasHoldOutPresented(holdoutPathId as String) as boolean
    if m.sec.Exists(holdoutPathId + "_holdout")
        print "Rf: holdout disabled for " + holdoutPathId
        return true
    end if
    return false
end function