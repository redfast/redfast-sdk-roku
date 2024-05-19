sub init()
end sub

sub onKeyDetection(params as object)
    if params.key = "options"
        m.screen = params.screen
        m.promoMgr = m.screen.GetScene().findNode("promoMgr")
    
        dialog = createObject("roSGNode", "KeyboardDialog")
        dialog.title = "Enter a new user id"
        dialog.text = m.promoMgr.callFunc("getUserId", {})
        dialog.buttons=["Set new user", "Reset the user", "CANCEL"]
        dialog.observeField("buttonSelected", "onKeyboardDialog")
        m.screen.GetScene().dialog = dialog
    end if
end sub

sub onKeyboardDialog()
    dialog = m.screen.GetScene().dialog
    if dialog.buttonSelected = 0
        m.promoMgr.callFunc("setUserId", {userId: dialog.text})
        m.top.needRefresh = true
    else if dialog.buttonSelected = 1
        m.promoMgr.callFunc("resetGoal", {})
        m.top.needRefresh = true
    end if
    dialog.close = true
end sub