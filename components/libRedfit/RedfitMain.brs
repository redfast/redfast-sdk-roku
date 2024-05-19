sub init()
    m.screenIndex = 0
    m.featured = m.top.findNode("featured")
    m.classes = m.top.findNode("classes")
    m.featuredClasses = m.top.findNode("featuredClasses")
    m.classGrid = m.top.findNode("classGrid")
    m.instructor = m.top.findNode("instructor")
    m.products = m.top.findNode("products")
    m.productGrid = m.top.findNode("productGrid")
    m.profile = m.top.findNode("profile")
    m.actions = m.top.findNode("actions")
    m.viewRoot = m.top.findNode("root")
    m.debugView = m.top.findNode("debugView")

    m.featuredTask = createObject("RoSGNode", "RedfitApi")
    m.featuredTask.observeField("state", "onFeaturedCompleted")
    m.featuredTask.callFunc("getContent", {subset: ["Featured Lessons", "Trainers", "Classes"], screen: 0})

    m.classesTask = createObject("RoSGNode", "RedfitApi")
    m.classesTask.observeField("state", "onClassesCompleted")
    m.classesTask.callFunc("getContent", {subset: ["Featured Lessons", "Classes"], screen: 1})

    m.trainerTask = createObject("RoSGNode", "RedfitApi")
    m.trainerTask.observeField("state", "onTrainerCompleted")
    m.trainerTask.callFunc("getContent", {subset: ["Trainers"], screen: 2})

    m.prodTask = createObject("RoSGNode", "RedfitApi")
    m.prodTask.observeField("state", "onProductCompleted")
    m.prodTask.callFunc("getContent", {subset: ["Products"], screen: 3})

    m.actions.observeField("itemSelected", "onProfileChange")

    m.promoMgr = m.top.GetScene().findNode("promoMgr")
    m.promoMgr.observeField("result", "onModalDismissed")
end sub

sub onModalDismissed()
    print "modal result = "
    print m.promoMgr.result
    if m.currentMenu = 0
        m.featured.setFocus(true)
    else if m.currentMenu = 1
        m.classGrid.setFocus(true)
    else if m.currentMenu = 2
        m.instructor.setFocus(true)
    else if m.currentMenu = 3
        m.productGrid.setFocus(true)
    else if m.currentMenu = 4
        m.actions.setFocus(true)
    end if
end sub

sub onFeaturedCompleted()
    if m.featuredTask.state = "stop"
        m.featuredTask.unobserveField("state")
        if m.featuredTask.content <> invalid
            contentNode = m.featuredTask.content

            ' 0. initial menus
            m.currentMenu = 0
            font  = CreateObject("roSGNode", "Font")
            font.uri = "pkg:/fonts/MaterialIcons-Regular.ttf"
            font.size = 64
            m.menu_featured = m.top.findNode("menu_featured")
            m.menu_featured.label = Chr(59546)
            m.menu_featured.font = font
            m.menu_featured.textColor = "#808080"
            m.menu_featured.textHighlightedColor = "#ff0000"
            m.menu_featured.ObserveField("buttonSelected", "showFeatured")
            m.menu_featured.setFocus(true)
            m.menu_featured.forceHighlighted = true

            m.menu_class = m.top.findNode("menu_class")
            m.menu_class.label = Chr(57401)
            m.menu_class.font = font
            m.menu_class.textColor = "#808080"
            m.menu_class.textHighlightedColor = "#ff0000"
            m.menu_class.ObserveField("buttonSelected", "showClasses")

            m.menu_instructor = m.top.findNode("menu_instructor")
            m.menu_instructor.label = Chr(60227)
            m.menu_instructor.font = font
            m.menu_instructor.textColor = "#808080"
            m.menu_instructor.textHighlightedColor = "#ff0000"
            m.menu_instructor.ObserveField("buttonSelected", "showTrainer")

            m.menu_shop = m.top.findNode("menu_shop")
            m.menu_shop.label = Chr(59640)
            m.menu_shop.font = font
            m.menu_shop.textColor = "#808080"
            m.menu_shop.textHighlightedColor = "#ff0000"
            m.menu_shop.ObserveField("buttonSelected", "showProduct")

            m.menu_profile = m.top.findNode("menu_profile")
            m.menu_profile.label = Chr(58390)
            m.menu_profile.font = font
            m.menu_profile.textColor = "#808080"
            m.menu_profile.textHighlightedColor = "#ff0000"
            m.menu_profile.ObserveField("buttonSelected", "showProfile")

            '1. insert billboard and hardcoded items
            banner = createObject("RoSGNode", "ContentNode")
            item = banner.createChild("ContentNode")
            item.HDPOSTERURL = "pkg:/images/hero-unit.png"
            item.ContentType = ""
            contentNode.insertChild(banner, 0)

            zoneTypes = ZoneType()
            billboard = createObject("RoSGNode", "ContentNode")
            values = m.promoMgr.callFunc("getInlines", {type: zoneTypes.rokuHorizontal})
            for ii = 0 To values.count() - 1
                item = billboard.createChild("ContentNode")
                value = values[ii]
                item.HDPOSTERURL = value.actions.rf_settings_bg_image_roku_os_tv_composite
                item.ContentType = ""
                item.Title = value.actions.rf_settings_roku_product_id
                item.Description = value.actions.rf_settings_roku_product_operation
                item.id = value.id
            end for
            billboard.title = "Inlines"
            contentNode.insertChild(billboard, 2)

            'hardcoded ad
            inlineAd = createObject("RoSGNode", "ContentNode")
            inlineAd.title = ""
            inlineAd.HDPOSTERURL = "pkg:/images/placement.jpg"
            inlineAd.ContentType = "series"
            trainerRow = contentNode.getChild(3)
            trainerRow.insertChild(inlineAd, 0)

            '2. load the featured screen
            m.featured.itemComponentName = "RowListItem"
            m.featured.showRowLabel = [true]
            m.featured.showRowCounter = [false]
            m.featured.numRows = contentNode.getChildCount()
            m.featured.itemSize = [1800, 0]
            m.featured.rowHeights = [550, 320, 390, 440, 320]
            m.featured.itemSpacing = [0, 20]
            m.featured.rowItemSpacing = [15, 0]
            m.featured.rowItemSize = [[1800, 500], [320, 270], [1800, 340], [240, 390], [320, 270]]
            m.featured.rowFocusAnimationStyle = "floatingFocus"
            m.featured.vertFocusAnimationStyle = "fixedFocusWrap"
            m.featured.content = contentNode
            m.featured.observeField("itemSelected", "onFeaturedClassSelected")
            m.featured.setFocus(true)

            m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Home" })
        end if
    end if
end sub

sub onClassesCompleted()
    if m.classesTask.state = "stop"
        m.classesTask.unobserveField("state")
        if m.classesTask.content <> invalid
            contentNode = m.classesTask.content

            featuredClassRow = createObject("RoSGNode", "ContentNode")
            featuredClassRow.appendChild(contentNode.getChild(0))
            m.featuredClasses.itemComponentName = "ClassFeaturedItem"
            m.featuredClasses.showRowLabel = [false]
            m.featuredClasses.showRowCounter = [false]
            m.featuredClasses.numRows = 1
            m.featuredClasses.itemSize = [1800, 0]
            m.featuredClasses.rowHeights = [550]
            m.featuredClasses.rowItemSpacing = [15, 0]
            m.featuredClasses.rowItemSize = [[1800, 500]]
            m.featuredClasses.rowFocusAnimationStyle = "floatingFocus"
            m.featuredClasses.content = featuredClassRow   
            
            classRow = createObject("RoSGNode", "ContentNode")
            classes = contentNode.getChild(0)
            row = invalid
            while classes.getChildCount() > 0
                if row  = invalid
                    row = classRow.createChild("ContentNode")
                    row.appendChild(classes.getChild(0))
                else
                    row.appendChild(classes.getChild(0))
                    row = invalid
                end if
            end while
            m.classGrid.itemComponentName = "ClassItem"
            m.classGrid.showRowLabel = [false]
            m.classGrid.showRowCounter = [false]
            m.classGrid.numRows = classRow.getChildCount()
            m.classGrid.itemSize = [1800, 430]
            m.classGrid.rowItemSpacing = [20, 0]
            m.classGrid.rowItemSize = [[800, 410]]
            m.classGrid.rowFocusAnimationStyle = "floatingFocus"
            m.classGrid.vertFocusAnimationStyle = "fixedFocus"
            m.classGrid.content = classRow
        end if
    end if
end sub

sub onTrainerCompleted()
    if m.trainerTask.state = "stop"
        m.trainerTask.unobserveField("state")
        if m.trainerTask.content <> invalid
            contentNode = m.trainerTask.content

            rowHeight = [300]
            trainerRow = createObject("RoSGNode", "ContentNode")
            ' hardcoded ads
            adsRow = trainerRow.createChild("ContentNode")
            ads = adsRow.createChild("ContentNode")
            ads.HDPOSTERURL = "pkg:/images/ads.png"
            rowItemCount = 0
            row = invalid
            firstRow = true
            trainers = contentNode.getChild(0)
            while trainers.getChildCount() > 0
                if rowItemCount = 0
                    row = trainerRow.createChild("ContentNode")
                    row.title = "REDFIT INSTRUCTORS"
                    row.appendChild(trainers.getChild(0))
                    rowItemCount = rowItemCount + 1
                    if firstRow
                        rowHeight.Push(580)
                    else
                        rowHeight.Push(540)
                    end if
                    firstRow = false
                else
                    row.appendChild(trainers.getChild(0))
                    rowItemCount = rowItemCount + 1
                    if rowItemCount = 4
                        rowItemCount = 0
                    end if
                end if
            end while

            m.instructor.itemComponentName = "RowListItem"
            m.instructor.showRowLabel = [false, true, false]
            m.instructor.showRowCounter = [false]
            m.instructor.numRows = trainerRow.getChildCount()
            m.instructor.itemSize = [1800, 0]
            m.instructor.rowHeights = rowHeight
            m.instructor.itemSpacing = [0, 20]
            m.instructor.rowItemSpacing = [15, 0]
            m.instructor.rowItemSize = [[1800, 300], [320, 540]]
            m.instructor.rowFocusAnimationStyle = "floatingFocus"
            m.instructor.vertFocusAnimationStyle = "fixedFocusWrap"
            m.instructor.content = trainerRow
        end if
    end if
end sub

sub onProductCompleted()
    if m.prodTask.state = "stop"
        m.prodTask.unobserveField("state")
        if m.prodTask.content <> invalid
            contentNode = m.prodTask.content
            products = contentNode.getChild(0)

            m.productGrid.numRows = (products.getChildCount() + 2) / 3
            m.productGrid.content = products
        end if
    end if
end sub

sub onProfileChange()
    if m.actions.itemSelected = 0
        dialog = createObject("roSGNode", "KeyboardDialog")
        dialog.title = "Enter a new user id"
        dialog.buttons=["OK", "CANCEL"]
        dialog.observeField("buttonSelected", "onKeyboardDialog")
        m.top.GetScene().dialog = dialog
    else if m.actions.itemSelected = 1
        m.promoMgr.callFunc("resetGoal", {})
        dialog = createObject("roSGNode", "Dialog")
        dialog.title = "Success"
        dialog.message = "User data has been reset"
        dialog.optionsDialog = true
        m.top.GetScene().dialog = dialog
    else if m.actions.itemSelected = 2
        m.promoMgr.callFunc("enablePromotion", {enabled: false})
        dialog = createObject("roSGNode", "Dialog")
        dialog.title = "Success"
        dialog.message = "SDK has been disabled"
        dialog.optionsDialog = true
        m.top.GetScene().dialog = dialog
    else if m.actions.itemSelected = 3
        m.promoMgr.callFunc("enablePromotion", {enabled: true})
        dialog = createObject("roSGNode", "Dialog")
        dialog.title = "Success"
        dialog.message = "SDK has been enabled"
        dialog.optionsDialog = true
        m.top.GetScene().dialog = dialog
    end if
end sub

sub onKeyboardDialog()
    dialog = m.top.GetScene().dialog
    if dialog.buttonSelected = 0
        m.promoMgr.callFunc("setUserId", {userId: dialog.text})
    end if
    dialog.close = true
end sub

sub showOverlay()
    m.promoMgr.callFunc("onButtonClicked", {root: m.viewRoot, id: "accessibility-123"})
end sub

sub showScreen(index as integer)
    m.screenIndex = index
    m.featured.visible = (m.screenIndex = 0)
    m.classes.visible = (m.screenIndex = 1)
    m.instructor.visible = (m.screenIndex = 2)
    m.products.visible = (m.screenIndex = 3)
    m.profile.visible = (m.screenIndex = 4)
end sub

sub showFeatured()
    showScreen(0)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Home" })
    m.promoMgr.callFunc("customTrack", {customFieldId: "Home"})
    m.featured.setFocus(true) 
end sub

sub showClasses()
    showScreen(1)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Classes" })
    m.promoMgr.callFunc("customTrack", {customFieldId: "Classes"})
    m.featuredClasses.setFocus(true) 
end sub

sub showTrainer()
    showScreen(2)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Trainers" })
    m.promoMgr.callFunc("customTrack", {customFieldId: "Trainers"})
    m.instructor.setFocus(true) 
end sub

sub showProduct()
    showScreen(3)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Shop" })
    m.promoMgr.callFunc("customTrack", {customFieldId: "Shop"})
    m.productGrid.setFocus(true)
end sub

sub showProfile()
    showScreen(4)
    m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "Profile" })
    m.promoMgr.callFunc("customTrack", {customFieldId: "Profile"})
    m.actions.setFocus(true)
end sub

sub onFeaturedClassSelected()
    if m.featured.itemSelected = 2 'if click in the inline billboard
        row = m.featured.content.getChild(m.featured.rowItemSelected[0])
        node = row.getChild(m.featured.rowItemSelected[1])
        if node.title <> "" and node.title <> invalid
            m.promoMgr.callFunc("onInlineClicked", {pathId: node.id, actionGroupId: node.action_groupd_id})
            startShoppingIap()
        end if
    end if
end sub

function onKeyEvent(key as string, pressed as boolean) as boolean
    if pressed
        m.debugView.callFunc("onKeyDetection", {key: key, screen: m.top})
        if m.screenIndex = 0
            if key = "right"
                m.featured.setFocus(true)
                return true
            else
                return menuKeyEvent(key, pressed)
            end if
        else if m.screenIndex = 1
            if m.featuredClasses.hasFocus()
                if key = "down"
                    m.classGrid.setFocus(true)
                    return true
                else if key = "left"
                    return  menuKeyEvent(key, pressed)
                end if
            else if m.classGrid.hasFocus()
                if key = "up"
                    m.featuredClasses.setFocus(true)
                    return true
                else if key = "left"
                    return  menuKeyEvent(key, pressed)
                end if
            else
                return menuKeyEvent(key, pressed)
            end if
        else if m.screenIndex = 2
            if key = "right"
                m.instructor.setFocus(true)
                return true
            else
                return menuKeyEvent(key, pressed)
            end if
        else if m.screenIndex = 3
            if key = "right"
                m.productGrid.setFocus(true)
                return true
            else
                return menuKeyEvent(key, pressed)
            end if
        else if m.screenIndex = 4
            if key = "right"
                m.actions.setFocus(true)
                return true
            else
                return menuKeyEvent(key, pressed)
            end if
        end if
    end if
    return false
end function

function menuKeyEvent(key as string, pressed as boolean) as boolean
    if pressed
        m.menu_featured.forceHighlighted = false
        m.menu_class.forceHighlighted = false
        m.menu_instructor.forceHighlighted = false
        m.menu_shop.forceHighlighted = false
        m.menu_profile.forceHighlighted = false
        if key = "up"
            if m.currentMenu = 1
                m.menu_featured.setFocus(true)
                m.menu_featured.forceHighlighted = true
            else if m.currentMenu = 2
                m.menu_class.setFocus(true)
                m.menu_class.forceHighlighted = true
            else if m.currentMenu = 3
                m.menu_instructor.setFocus(true)
                m.menu_instructor.forceHighlighted = true
            else if m.currentMenu = 4
                m.menu_shop.setFocus(true)
                m.menu_shop.forceHighlighted = true
            end if

            if m.currentMenu > 0
                m.currentMenu = m.currentMenu - 1
            end if
            return true
        else if key = "down"
            if m.currentMenu = 0
                m.menu_class.setFocus(true)
                m.menu_class.forceHighlighted = true
            else if m.currentMenu = 1
                m.menu_instructor.setFocus(true)
                m.menu_instructor.forceHighlighted = true
            else if m.currentMenu = 2
                m.menu_shop.setFocus(true)
                m.menu_shop.forceHighlighted = true
            else if m.currentMenu = 3
                m.menu_profile.setFocus(true)
                m.menu_profile.forceHighlighted = true
            end if

            if m.currentMenu < 4
                m.currentMenu = m.currentMenu + 1
            end if
            return true
        else if key = "left"
            if m.currentMenu = 0
                m.menu_featured.setFocus(true)
                m.menu_featured.forceHighlighted = true
            else if m.currentMenu = 1
                m.menu_class.setFocus(true)
                m.menu_class.forceHighlighted = true
            else if m.currentMenu = 2
                m.menu_instructor.setFocus(true)
                m.menu_instructor.forceHighlighted = true
            else if m.currentMenu = 3
                m.menu_shop.setFocus(true)
                m.menu_shop.forceHighlighted = true
            else if m.currentMenu = 4
                m.menu_profile.setFocus(true)
                m.menu_profile.forceHighlighted = true
            end if
        end if
    end if
    return false
end function

sub startShoppingIap()
    dialog = createObject("roSGNode", "ProgressDialog")
    dialog.message = "Prepare in-app purchase"
    m.top.GetScene().dialog = dialog
    m.promoMgr.observeField("iapResult", "getCatalog")
    m.promoMgr.callFunc("getIapItems", {})
end sub

sub getCatalog()
    m.promoMgr.unobserveField("iapResult")
    m.catalog = m.promoMgr.iapResult
    
    m.promoMgr.observeField("iapResult", "getPurchased")
    m.promoMgr.callFunc("getPuchasedItems", {})
end sub

sub getpurchased()
    m.promoMgr.unobserveField("iapResult")
    m.purchased = m.promoMgr.iapResult

    for ii = 0 to m.catalog.getChildCount() - 1
        item = m.catalog.getChild(ii)
        found = false
        for jj = 0 to m.purchased.getChildCount() - 1
            purchase = m.purchased.getChild(jj)
            if item.id = purchase.id
                item.description = item.description + " (purchased)"
                found = true
                exit for
            end if
        end for
        if found = false and m.purchased.getChildCount() > 0
            if item.id = "platinum"
                item.description = item.description + " (downgrade)"
            else
                item.description = item.description + " (upgrade)"
            end if
        end if
    end for
    purchaseStep1()
end sub

sub purchaseStep1()
    if m.promoMgr.iapResult.getChildCount() > 0
        dialog = createObject("roSGNode", "Dialog")
        dialog.message = "Choose an inapp item"
        items = []
        for ii = 0 to m.catalog.getChildCount() - 1
            items.push(m.catalog.getChild(ii).description)
        end for
        dialog.buttons = items
        dialog.observeField("buttonSelected", "purchaseStep2")
        m.top.GetScene().dialog = dialog
    end if
end sub

sub purchaseStep2()
    index = m.top.GetScene().dialog.buttonSelected
    item = m.catalog.getChild(index)
    m.promoMgr.observeField("iapResult", "purchaseStep3")
    m.promoMgr.callFunc("purchaseIap", {sku: item.id, qty: 1})
end sub

sub purchaseStep3()
    m.promoMgr.unobserveField("iapResult")
    print m.promoMgr.iapResult
end sub