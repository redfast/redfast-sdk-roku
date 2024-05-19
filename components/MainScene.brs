sub init()
    ' font = CreateObject("roSGNode", "Font")
    ' font.uri = "pkg:/fonts/Groovy.ttf"
    ' font.size = 30
    m.promoMgr = m.top.GetScene().findNode("promoMgr")
    ' m.promoMgr.font = font
    m.promoMgr.callFunc("initPromotion", {appId: "8d5ca228-c2dc-4034-8ea8-d6cda34e2794", userId: "123-roku"})
    m.promoMgr.observeField("result", "onInitialized")
end sub

sub onInitialized()
    m.promoMgr.unobserveField("result")
    m.sceneStack = m.top.findNode("sceneStack")
    'scene = createObject("RoSGNode", "TemplateMain")
    'scene = createObject("RoSGNode", "RedfitMain")
    scene = createObject("RoSGNode", "RedflixMain")
    m.sceneStack.appendChild(scene)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function
