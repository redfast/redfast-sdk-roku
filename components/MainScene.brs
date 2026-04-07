sub init()
    m.promoMgr = m.top.GetScene().findNode("promoMgr")
    print m.promoMgr.callFunc("getVersion")

    ctaF = CreateObject("roSGNode", "Font")
    ctaF.uri = "pkg:/fonts/AllProDisplayC-Bold.ttf"
    ctaF.size = 20
    timeoutF = CreateObject("roSGNode", "Font")
    timeoutF.uri = "pkg:/fonts/AllProDisplayC-Regular.ttf"
    timeoutF.size = 20
    m.promoMgr.callFunc("initPromotion", { 
        appId: "6b233605-b981-4d6d-8b45-efa7fc402388", '"2b40fc8a-75fe-436e-afa7-e2879392566c", 
        userId: "123", 
        anonymousUserId: "anon-123-roku", 
        ctaFont: ctaF, 
        timeoutFont: timeoutF })
    m.promoMgr.observeField("result", "onInitialized")
end sub

sub onInitialized()
    m.promoMgr.unobserveField("result")
    m.sceneStack = m.top.findNode("sceneStack")
    scene = createObject("RoSGNode", "RedflixMain")
    m.sceneStack.appendChild(scene)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    return false
end function
