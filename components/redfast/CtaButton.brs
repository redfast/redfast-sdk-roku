' Copyright (C) 2023 Redfast Inc - All Rights Reserved
'
' Must not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.buttonLabel = m.top.findNode("buttonLabel")
    m.top.observeField("focusedChild", "focusChanged")
    m.top.observeField("renderTracking", "renderStatus")
    m.top.enableRenderTracking = true
    m.top.focusable = true
    m.top.color = m.top.bgColor
end sub

sub renderStatus()
    if m.top.renderTracking = "full"
        m.top.unobserveField("renderTracking")
        m.buttonLabel.width = m.top.width
        m.buttonLabel.height = m.top.height
    end if
end sub

sub labelChanged()
    m.buttonLabel.text = m.top.label
end sub

sub textColorChanged()
    m.buttonLabel.color = m.top.textColor
end sub

sub bgColorChanged()
    m.top.color = m.top.bgColor
end sub

sub focusChanged()
    if m.top.hasFocus() or m.top.forceHighlighted
        m.buttonLabel.color = m.top.textHighlightedColor
    else
        m.buttonLabel.color = m.top.textColor
    end if
end sub

sub fontChanged()
    m.buttonLabel.font = m.top.font
end sub

function onKeyEvent(key as string, pressed as boolean) as boolean
    if key = "OK" and pressed and m.top.enabled
        m.top.buttonSelected = true
        return true
    end if
    return false
end function