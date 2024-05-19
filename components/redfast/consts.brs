' Copyright (C) 2023 Redfast Inc - All Rights Reserved
'
' Must not be copied and/or distributed without the express
' permission of Redfast Inc

function PromotionResult() as Object
    m = {}
    m.timerExpired = -1
    m.declined = -2
    m.abort = -3
    m.accepted = 0
    m.notApplicable = -4
    m.disabled = -5
    m.holdout = -6
    m.launchingPromotion = 1
    return m
end function

function PathType() as Object
    m = {}
    m.modal = 2
    m.modal2 = 10
    m.inline = 5
    m.video = 6
    m.invisible = 1
    m.unknown = 0
    return m
end function

function ZoneType() as Object
    m = {}
    m.billboard = "billboard"
    m.featured = "featured"
    m.rokuHorizontal = "roku-horizontal"
    return m
end function

function DeviceType() as Object
    m = {}
    m.ios = "ios"
    m.android_os = "android_os"
    m.roku_os = "roku_os"
    m.unknown = "unknown"
    return m
end function

function ErrorMessage() as Object
    m = {}
    m.invalid_action = "no action data available"
    return m
end function

function getKeyValuePair(components as string) as object
    keyValue = components
    remain = ""
    index = Instr(1, components, "&")
    if index <> 0
        keyValue = Left(components, index - 1)
        remain = Right(components, Len(components) - index)
    end if
    index = Instr(1, keyValue, "=")
    if index = 0
        return invalid
    end if
    return {key: Left(keyValue, index - 1), value: Right(keyValue, Len(keyValue) - index), remain: remain}
end function

function parseKeyValuePair(components as string) as object
    result = {}
    continue = true
    while continue
        if components <> "" or components <> invalid
            keyValue = getKeyValuePair(components)
            if keyValue = invalid
                continue = false
            else
                result.AddReplace(keyValue.key, keyValue.value)
                components = keyValue.remain
            end if
        else
            continue = false
        end if
    end while
    return result
end function

function pxToInteger(pxString as String) as Integer
    left = pxString.Left(pxString.Len() - 2)
    return left.toInt()
end function