' Copyright (C) 2023 Redfast Inc - All Rights Reserved
'
' Must not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.rf_settings_bg_image = m.top.findNode("rf_settings_bg_image")
    m.rf_retention_title = m.top.findNode("rf_retention_title")
    m.rf_retention_message = m.top.findNode("rf_retention_message")
    m.rf_retention_confirm_button_text = m.top.findNode("rf_retention_confirm_button_text")
    m.rf_retention_cancel_button_text = m.top.findNode("rf_retention_cancel_button_text")
    m.rf_retention_accept2_button_text = m.top.findNode("rf_retention_accept2_button_text")
    m.currentButton = 0
    m.totalButtons = 1
    m.countDown = m.top.findNode("countDown")
    m.result = PromotionResult()
    m.initialGrabFocus = false
    m.localStorage = CreateLocalStorage()
end sub

function callApi(params)
    action = createObject("RoSGNode", "PromotionApi")
    action.appId = m.appId
    action.userId = m.userId
    action.deviceType = m.deviceType
    if m.anonymous_user_id <> invalid
        action.anonymous_user_id = m.anonymous_user_id
    end if
    action.callFunc("fireEvent", params)
end function

sub showModal(params as Object)
    m.appId = params.appId
    m.userId = params.userId
    m.deviceType = params.deviceType
    m.anonymous_user_id = params.anonymous_user_id
    path = params.path
    m.currentPath = path

    m.rf_settings_bg_image.uri = path.actions.rf_settings_bg_image_roku_os_tv_composite
    m.rf_retention_confirm_button_text.label = path.actions.rf_retention_confirm_button_text
    m.rf_retention_confirm_button_text.textColor = path.actions.rf_retention_confirm_button_text_color
    m.rf_retention_confirm_button_text.textHighlightedColor = path.actions.rf_retention_confirm_button_text_highlight_color
    m.rf_retention_confirm_button_text.bgColor = path.actions.rf_settings_background_color
    m.rf_retention_confirm_button_text.font = m.top.font
    m.rf_retention_confirm_button_text.ObserveField("buttonSelected", "onAccept")
    m.rf_retention_cancel_button_text.label = path.actions.rf_retention_cancel_button_text
    m.rf_retention_cancel_button_text.textColor = path.actions.rf_retention_cancel_button_text_color
    m.rf_retention_cancel_button_text.textHighlightedColor = path.actions.rf_retention_cancel_button_text_highlight_color
    m.rf_retention_cancel_button_text.bgColor = path.actions.rf_settings_background_color
    m.rf_retention_cancel_button_text.font = m.top.font
    m.rf_retention_cancel_button_text.ObserveField("buttonSelected", "onDecline")
    if path.actions.rf_settings_cancel_button_enabled <> invalid and path.actions.rf_settings_cancel_button_enabled = "true"
        m.rf_retention_cancel_button_text.visible = true
        m.totalButtons = m.totalButtons + 1
    end if
    m.rf_retention_accept2_button_text.label = path.actions.rf_retention_confirm_button_2_text
    m.rf_retention_accept2_button_text.textColor = path.actions.rf_retention_confirm_button_2_text_color
    m.rf_retention_accept2_button_text.textHighlightedColor = path.actions.rf_retention_confirm_button_2_highlight_color
    m.rf_retention_accept2_button_text.bgColor = path.actions.rf_settings_accept2_button_background_color
    m.rf_retention_accept2_button_text.font = m.top.font
    if path.actions.rf_settings_confirm_button_2_enabled <> invalid and path.actions.rf_settings_confirm_button_2_enabled = "true"
        m.rf_retention_accept2_button_text.visible = true
        m.totalButtons = m.totalButtons + 1
    end if
    m.rf_retention_accept2_button_text.ObserveField("buttonSelected", "onAccept2")
    m.rf_retention_confirm_button_text.setFocus(true)
    m.rf_settings_close_seconds_text = path.actions.rf_settings_close_seconds_text
    if m.rf_settings_close_seconds_text = invalid or m.rf_settings_close_seconds_text = ""
        m.rf_settings_close_seconds_text = " seconds remaining"
    end if

    m.timerCounter = path.actions.rf_settings_close_seconds.toInt()
    if m.timerCounter > 0
        m.countDown.color = path.actions.rf_settings_timer_font_color
        m.countDown.text = m.timerCounter.toStr() + m.rf_settings_close_seconds_text
        m.timer = createObject("RoSGNode", "Timer")
        m.timer.duration = 1
        m.timer.observeField("fire", "onTimer")
        m.timer.repeat = true
        m.timer.control = "start"
    end if

    callApi({event: "impression", pathId: path.id, actionGroupId: path.action_group_id})
end sub

sub onTimer()
    m.timerCounter -= 1
    m.countDown.text = m.timerCounter.toStr() + m.rf_settings_close_seconds_text
    if m.initialGrabFocus = false
        m.rf_retention_confirm_button_text.setFocus(true)
        m.initialGrabFocus = true
    end if
    if m.timerCounter = 0
        m.timer.unobserveField("fire")
        m.timer.control = "stop"
        m.top.result = {
            value: m.result.timerExpired,
            extra: {
                meta: m.currentPath.actions.rf_metadata
            }
        }
        callApi({event: "dismiss", pathId: m.currentPath.id, actionGroupId: m.currentPath.action_group_id, reason: "timeout"})
        m.localStorage.createNewOverlayKey(m.currentPath.id, m.currentPath.actions.rf_settings_timeout_interval)
    end if
end sub

sub onAccept()
    m.timer.control = "stop"
    m.countDown.visible = false
    m.rf_retention_cancel_button_text.visible = false
    m.rf_retention_confirm_button_text.setFocus(true)
    m.rf_retention_confirm_button_text.label = "Thank you"
    m.rf_retention_confirm_button_text.enabled = false

    m.onetimer = createObject("RoSGNode", "Timer")
    m.onetimer.duration = 2
    m.onetimer.observeField("fire", "onClosing")
    m.onetimer.repeat = false
    m.onetimer.control = "start"
    callApi({event: "goal", pathId: m.currentPath.id, actionGroupId: m.currentPath.action_group_id})
    m.localStorage.createNewOverlayKey(m.currentPath.id, m.currentPath.actions.rf_settings_accept_interval)
end sub

sub onAccept2()
    m.timer.control = "stop"
    callApi({event: "goal", pathId: m.currentPath.id, actionGroupId: m.currentPath.action_group_id, accept_type: "accept2"})
    m.localStorage.createNewOverlayKey(m.currentPath.id, m.currentPath.actions.rf_settings_accept_interval)
    onClosing()
end sub

sub onClosing()
    if m.onetimer <> invalid
        m.onetimer.unobserveField("fire")
        m.onetimer.control = "stop"
    end if
    m.top.result = {
        value: m.result.accepted,
        extra: {
            roku: m.currentPath.actions.rf_settings_roku_product_id,
            deeplink: parseKeyValuePair(m.currentPath.actions.rf_settings_deeplink),
            meta: m.currentPath.actions.rf_metadata
        }
    }
end sub

sub onDecline()
    m.timer.control = "stop"
    m.top.result = {
        value: m.result.declined,
        extra: {
            roku: m.currentPath.actions.rf_settings_roku_product_id,
            meta: m.currentPath.actions.rf_metadata
        }
    }
    callApi({event: "dismiss", pathId: m.currentPath.id, actionGroupId: m.currentPath.action_group_id, reason: "decline"})
    m.localStorage.createNewOverlayKey(m.currentPath.id, m.currentPath.actions.rf_settings_decline_interval)
end sub

function onKeyEvent(key as string, pressed as boolean) as boolean
    if key = "left" and pressed
        if m.currentButton > 0
            m.currentButton = m.currentButton - 1
        end if
    else if key = "right" and pressed
        if m.currentButton + 1 < m.totalButtons
            m.currentButton = m.currentButton + 1
        end if
    else if key = "back" and pressed
        m.top.result = {
            value: m.result.abort,
            extra: {
                meta: m.currentPath.actions.rf_metadata
            }
        }
        m.timer.control = "stop"
        callApi({event: "dismiss", pathId: m.currentPath.id, actionGroupId: m.currentPath.action_group_id, reason: "dismiss"})
        m.localStorage.createNewOverlayKey(m.currentPath.id, m.currentPath.actions.rf_settings_dismiss_interval)
    end if

    if (key = "left" or key = "right") and pressed
        if m.currentButton = 0
            m.rf_retention_confirm_button_text.setFocus(true)
        else if m.currentButton = 1
            m.rf_retention_cancel_button_text.setFocus(true)
        else
            m.rf_retention_accept2_button_text.setFocus(true)
        end if
    end if
    return true
end function