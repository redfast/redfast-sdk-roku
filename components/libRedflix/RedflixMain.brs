sub init()
    m.promoMgr = m.top.GetScene().findNode("promoMgr")
    m.promoMgr.observeField("result", "onModalDismissed")

    m.viewRoot = m.top.findNode("root")

    m.contentTask = createObject("RoSGNode", "RedflixApi")
    m.contentTask.observeField("state", "onContentComplete")
    m.contentTask.callFunc("getMovies", {})

    m.menuHome = m.top.findNode("menu-home")
    m.menuHome.label = "Home"
    m.menuHome.textColor = "#808080"
    m.menuHome.textHighlightedColor = "#ffffff"
    m.menuHome.ObserveField("buttonSelected", "showHome")

    m.menuLatest = m.top.findNode("menu-latest")
    m.menuLatest.label = "Latest"
    m.menuLatest.textColor = "#808080"
    m.menuLatest.textHighlightedColor = "#ffffff"
    m.menuLatest.ObserveField("buttonSelected", "showLatest")

    m.menuGenres = m.top.findNode("menu-genres")
    m.menuGenres.label = "Genres"
    m.menuGenres.textColor = "#808080"
    m.menuGenres.textHighlightedColor = "#ffffff"
    m.menuGenres.ObserveField("buttonSelected", "showGenres")

    m.home = m.top.findNode("home")
    m.modal = m.top.findNode("modal")
    m.detail = m.top.findNode("detail")
    m.promo = m.top.findNode("promo")
    m.promolist = m.top.findNode("promolist")
end sub

sub onContentComplete()
    if m.contentTask.state = "stop"
        m.contentTask.unobserveField("state")
        if m.contentTask.content <> invalid
            m.currentMenu = 0
            m.menuHome.forceHighlighted = true

            root = createObject("RoSGNode", "ContentNode")

            inlineRow = root.createChild("ContentNode")
            inline = inlineRow.createChild("ContentNode")
            values = m.promoMgr.callFunc("getInlines", {type: "redflix-featured"})
            inline.HDPOSTERURL = values[0].actions.rf_settings_bg_image_roku_os_tv_composite
            inline.Title = values[0].actions.rf_settings_roku_product_id
            inline.Description = values[0].actions.rf_settings_roku_product_operation

            bannerRow = root.createChild("ContentNode")
            banner = bannerRow.createChild("ContentNode")
            banner.HDPOSTERURL = "pkg:/images/highlightd.png"
            
            movies = m.contentTask.content
            total = movies.getChildCount()
            hilightRow = root.createChild("ContentNode")
            for i = 0 to total / 2 step 1
                movie = movies.getChild(i)
                movieNode = hilightRow.createChild("ContentNode")
                movieNode.title = movie.title
                movieNode.ContentType = movie.ContentType
                movieNode.description = movie.description
                movieNode.Directors = movie.Directors
                movieNode.ShortDescriptionLine2 = movie.ShortDescriptionLine2
                movieNode.HDPOSTERURL = movie.HDPOSTERURL
            end for
            
            splashRow = root.createChild("ContentNode")
            splash = splashRow.createChild("ContentNode")
            splash.HDPOSTERURL = "pkg:/images/splash.png"
            
            newReleaseBannerRow = root.createChild("ContentNode")
            nrBanner = newReleaseBannerRow.createChild("ContentNode")
            nrBanner.HDPOSTERURL = "pkg:/images/new-release.png"
            
            newReleaseRow = root.createChild("ContentNode")
            for i = total / 2 to total - 1 step 1
                movie = movies.getChild(i)
                movieNode = newReleaseRow.createChild("ContentNode")
                movieNode.title = movie.title
                movieNode.ContentType = movie.ContentType
                movieNode.description = movie.description
                movieNode.Directors = movie.Directors
                movieNode.ShortDescriptionLine2 = movie.ShortDescriptionLine2
                movieNode.HDPOSTERURL = movie.SDPOSTERURL
            end for
            
            m.home.itemComponentName = "RowListItem"
            m.home.showRowLabel = [true]
            m.home.showRowCounter = [false]
            m.home.numRows = root.getChildCount()
            m.home.itemSize = [1880, 0]
            m.home.rowHeights = [420, 290, 410, 520, 270, 340]
            m.home.rowItemSpacing = [15, 0]
            m.home.rowItemSize = [[1880, 440], [1880, 270], [270, 390], [1880, 500], [1880, 250], [480, 320]]
            m.home.rowFocusAnimationStyle = "floatingFocus"
            m.home.vertFocusAnimationStyle = "fixedFocus"
            m.home.content = root
            m.home.observeField("itemSelected", "onHomeRowSelected")
            m.home.setFocus(true)

            m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "home" })
            m.promoMgr.callFunc("customTrack", {customFieldId: "home"})
        end if
    end if
end sub

sub showHome()
end sub

sub showLatest()
end sub

sub showGenres()
end sub

sub onHomeRowSelected()
    item = m.home.rowItemSelected
    if item[0] = 0
        contentNode = m.home.content.getChild(item[0]).getChild(item[1])
        m.promoMgr.observeField("iapResult", "purchaseStep3")
        m.promoMgr.callFunc("purchaseIap", {sku: contentNode.title, qty: 1})
    end if

    if item[0] = 2 or item[0] = 5
        m.home.visible = false
        m.modal.visible = true
        contentNode = m.home.content.getChild(item[0]).getChild(item[1])
        ' print contentNode

        root = createObject("RoSGNode", "ContentNode")
        metaRow = root.createChild("ContentNode")
        metaNode = metaRow.createChild("ContentNode")
        metaNode.title = contentNode.title
        metaNode.description = contentNode.description
        metaNode.HDPOSTERURL = contentNode.HDPOSTERURL
        metaNode.Directors = contentNode.Directors
        metaNode.ShortDescriptionLine2 = contentNode.ShortDescriptionLine2
        metaNode.ContentType = "movie"

        discription1Row = root.createChild("ContentNode")
        description1 = discription1Row.createChild("ContentNode")
        description1.HDPOSTERURL = "pkg:/images/description1.png"

        discription2Row = root.createChild("ContentNode")
        description2 = discription2Row.createChild("ContentNode")
        description2.HDPOSTERURL = "pkg:/images/description2.png"

        discription3Row = root.createChild("ContentNode")
        description3 = discription3Row.createChild("ContentNode")
        description3.HDPOSTERURL = "pkg:/images/description3.png"

        discription4Row = root.createChild("ContentNode")
        description4 = discription4Row.createChild("ContentNode")
        description4.HDPOSTERURL = "pkg:/images/description4.png"

        discription5Row = root.createChild("ContentNode")
        description5 = discription5Row.createChild("ContentNode")
        description5.HDPOSTERURL = "pkg:/images/description5.png"

        m.detail.itemComponentName = "RowDetailItem"
        m.detail.showRowLabel = [false]
        m.detail.showRowCounter = [false]
        m.detail.numRows = root.getChildCount()
        m.detail.itemSize = [1880, 0]
        m.detail.rowHeights = [660, 290, 360, 660, 470, 660]
        m.detail.rowItemSpacing = [15, 0]
        m.detail.rowItemSize = [[1880, 640], [1880, 270], [1880, 340], [1880, 640], [1880, 450], [1880, 640]]
        m.detail.rowFocusAnimationStyle = "floatingFocus"
        m.detail.vertFocusAnimationStyle = "fixedFocus"
        m.detail.content = root
        m.detail.observeField("itemSelected", "onDetailRowSelected")
        m.detail.setFocus(true)
    end if
end sub

sub onDetailRowSelected()
    ' m.promo.visible = true
    
    ' root = createObject("RoSGNode", "ContentNode")
    ' promoRow = root.createChild("ContentNode")
    ' for i = 0 to 2 step 1
    '     promoNode = promoRow.createChild("ContentNode")
    '     promoNode.HDPOSTERURL = "pkg:/images/promo" + i.toStr() + ".png"
    ' end for

    ' m.promolist.showRowLabel = [false]
    ' m.promolist.showRowCounter = [false]
    ' m.promolist.numRows = root.getChildCount()
    ' m.promolist.itemSize = [1000, 0]
    ' m.promolist.rowHeights = [560]
    ' m.promolist.rowItemSpacing = [15, 0]
    ' m.promolist.rowItemSize = [[300, 560]]
    ' m.promolist.rowFocusAnimationStyle = "floatingFocus"
    ' m.promolist.vertFocusAnimationStyle = "fixedFocus"
    ' m.promolist.content = root
    ' m.promolist.setFocus(true)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "detail" })
end sub

function onKeyEvent(key as string, pressed as boolean) as boolean
    if pressed
        if m.promo.visible = false
            if key = "left" or key = "right" or key = "up"
                if key = "left"
                    if m.currentMenu > 0
                        m.currentMenu = m.currentMenu - 1
                    else
                        return true
                    end if
                else if key = "right"
                    if m.currentMenu < 2
                        m.currentMenu = m.currentMenu + 1
                    else
                        return true
                    end if
                end if
                
                m.menuHome.forceHighlighted = false
                m.menuLatest.forceHighlighted = false
                m.menuGenres.forceHighlighted = false
                if m.currentMenu = 0
                    m.menuHome.setFocus(true)
                    m.menuHome.forceHighlighted = true
                else if m.currentMenu = 1
                    m.menuLatest.setFocus(true)
                    m.menuLatest.forceHighlighted = true
                else if m.currentMenu = 2
                    m.menuGenres.setFocus(true)
                    m.menuGenres.forceHighlighted = true
                end if
                return true
            else if key = "down"
                if m.modal.visible
                    m.detail.setFocus(true)
                else
                    m.home.setFocus(true)
                end if
                return true
            end if
        end if

        if key = "back"
            if m.promo.visible
                m.promo.visible = false
                m.detail.setFocus(true)
                return true
            end if
            if m.modal.visible
                m.modal.visible = false
                m.home.visible = true
                m.home.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onModalDismissed()
    print "modal result = " + m.promoMgr.result.value.toStr()
    print m.promoMgr.result
    if m.promoMgr.result.extra <> invalid and m.promoMgr.result.extra.roku <> invalid and m.promoMgr.result.extra.roku <> ""
        m.promoMgr.observeField("iapResult", "purchaseStep3")
        m.promoMgr.callFunc("purchaseIap", {sku: m.promoMgr.result.extra.roku, qty: 1})
    else
        if m.modal.visible
            m.detail.setFocus(true)
        else
            m.home.setFocus(true)
        end if
    end if
end sub

sub purchaseStep3()
    m.promoMgr.unobserveField("iapResult")
    print m.promoMgr.iapResult
    m.home.setFocus(true)
end sub