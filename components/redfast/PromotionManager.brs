' Copyright (C) 2023 Redfast Inc - All Rights Reserved
'
' Must not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.currentScreenName = ""
    m.allResults = PromotionResult()
    m.allErrors = ErrorMessage()
    m.billing = m.top.FindNode("billing")
    m.pingRetry = 60
    m.lastEtag = invalid
    m.lastGoodPingInterval = 60
    di = CreateObject("roDeviceInfo")
    m.displaySize = di.GetDisplaySize()
    m.localStorage = CreateLocalStorage()
    m.localStorage.reset(true)
    m.modalParamsDictionary = {}
    m.promotionEnabled = true
end sub

function callApi(observer as String) as object
    action = createObject("RoSGNode", "PromotionApi")
    action.appId = m.appId
    action.userId = m.userId
    action.deviceType = m.deviceType
    if m.actions <> invalid and m.actions.anonymous_user_id <> invalid
        action.anonymous_user_id = m.actions.anonymous_user_id
    end if
    if observer <> ""
        action.observeField("state", observer)
    end if
    return action
end function

sub initPromotion(params as Object)
    m.actions = invalid
    m.initialPing = true
    m.appId = params.appId
    m.userId = params.userId
    m.deviceType = "roku_os"
    if params.deviceType <> invalid
        m.deviceType = params.deviceType
    end if
    updatePing()
end sub

sub ping(params as Object)
    params.event = "traitping"
    m.ping = callApi("")
    m.ping.callFunc("fireEvent", params)
end sub

sub enablePromotion(params as Object)
    if Type(params.enabled) = "roBoolean"
        m.promotionEnabled = params.enabled
    endif
end sub

sub updatePing()
    if m.initialPing and m.timer <> invalid
        m.timer.unobserveField("fire")
        m.timer = invalid
    end if
    if m.promotionEnabled
        m.ping = callApi("onUpdatePing")
        m.ping.callFunc("fireEvent", {event: "ping", name: m.currentScreenName, etag: m.lastEtag})
    else
        print  "Rf: promotion is temporary disabled; idle timer"
        m.timer = createObject("RoSGNode", "Timer")
        m.timer.duration = m.pingRetry
        m.timer.observeField("fire", "updatePing")
        m.timer.repeat = false
        m.timer.control = "start"
        m.actions = invalid
    endif
end sub

function scheduleNextPingInterval() as Integer
    m.lastEtag = invalid
    nextInterval = m.pingRetry
    m.pingRetry = m.pingRetry * 2
    if m.pingRetry > 3084
        m.pingRetry = 3084
    end if
    return nextInterval
end function

sub onUpdatePing()
    if m.ping.state = "stop"
        m.ping.unobserveField("fireEvent")
        interval = m.pingRetry
        if m.ping.content <> invalid
            m.actions = m.ping.content
            if m.ping.content.configs <> invalid and m.ping.content.configs.ping_frequency <> invalid
                if m.initialPing
                    m.initialPing = false
                    m.top.result = {value: m.allResults.accepted}
                end if
                interval = m.ping.content.configs.ping_frequency
                m.lastEtag = m.ping.content.etag
                m.lastGoodPingInterval = interval
                m.pingRetry = 60
            else if m.ping.content.etag <> invalid
                m.lastEtag = m.ping.content.etag
                interval = m.lastGoodPingInterval
            else
                interval = scheduleNextPingInterval()
            end if

            if m.actions.reset <> invalid and m.actions.reset = true
                resetGoal({})
            end if
        else
            interval = scheduleNextPingInterval()
        end if
        print "Rf: next ping after " + interval.toStr() + " seconds"
        m.timer = createObject("RoSGNode", "Timer")
        m.timer.duration = interval
        m.timer.observeField("fire", "updatePing")
        m.timer.repeat = false
        m.timer.control = "start"
        m.ping = invalid
    end if
end sub

function getPath(actions as Object, clickId as String) as Object
    paths = []
    pathTypes = PathType()
    deviceTypes = DeviceType()
    if actions.paths <> invalid
        for ii = 0 To actions.paths.count() - 1
            path = actions.paths[ii]
            if path.path_type = pathTypes.modal or path.path_type = pathTypes.modal2 or path.path_type = pathTypes.video
                paths.push(path)
             end if
        end for
    end if

    for ii = 0 to paths.count() - 1
        path = paths[ii]
        for jj = 0 to path.triggers.count() - 1
            trigger = path.triggers[jj]
            urlPath = trigger.url_path
            useRegex = trigger.use_regex
            checkTriggerScreenName = false
            if useRegex <> invalid and useRegex
                pattern = CreateObject("roRegex", urlPath, "")
                checkTriggerScreenName = pattern.IsMatch(m.currentScreenName)
            else if urlPath = m.currentScreenName
                checkTriggerScreenName = true
            end if
            if checkTriggerScreenName
                if (trigger.click_id = invalid or trigger.click_id ="") and clickId = ""
                    path.delay_seconds = trigger.delay_seconds
                    return path
                end if
                if trigger.click_id = clickId
                    path.delay_seconds = trigger.delay_seconds
                    return path
                end if
            end if
        end for
    end for
    return invalid
end function

sub onInlineClicked(params as Object)
    track = callApi("")
    track.callFunc("fireEvent", {event: "goal", pathId: params.pathId, actionGroupId: params.actionGroupId})
    for ii = 0 To m.actions.paths.count() - 1
        path = m.actions.paths[ii]
        if path.id = params.pathId
             m.top.result = {
                value: m.allResults.accepted,
                extra: {
                    meta: path.actions.rf_metadata,
                    deeplink: path.actions.rf_settings_deeplink
                }
             }
             return
        end if
    end for
end sub

sub onInlineViewed(params as Object)
    track = callApi("")
    track.callFunc("fireEvent", {event: "impression", pathId: params.pathId, actionGroupId: params.actionGroupId})
end sub

sub onButtonClicked(params as Object)
    if m.actions = invalid
        m.top.lastError = m.allErrors.invalid_action
        return
    end if

    findMatch = false
    path = getPath(m.actions, params.id)
    if path <> invalid
        modalParam = {}
        modalParam.appId = m.appId
        modalParam.userId = m.userId
        modalParam.deviceType = m.deviceType
        modalParam.path = path
        modalParam.root = params.root
        m.modalParamsDictionary.addReplace(m.currentScreenName, modalParam)
        onDisplayModal()
    else
        m.top.result = {value: m.allResults.notApplicable}
    end if

    usages = m.actions.configs.usage
    for kk = 0 to usages.count() - 1
        usage = usages[kk]
        if usage.type = "track"
            values = usage.values
            for ll = 0 to values.count() - 1
                value = values[ll]
                if params.id = value
                    click = callApi("")
                    click.callFunc("fireEvent", {event: "click", id: usage.id, type: usage.type, eventName: usage.event, value: value})
                    exit for
                end if
            end for
        end if
    end for
end sub

sub onModalDismissed()
    m.modal.unobserveField("result")
    m.modalParam.root.removeChildIndex(m.modalParam.root.getChildCount() - 1)

    m.modalResult = m.modal.result
    m.modal = invalid
    prod_id = m.modalParam.path.actions.rf_settings_roku_product_id
    prod_op = m.modalParam.path.actions.rf_settings_roku_product_operation
    if prod_id <> invalid and prod_op <> invalid and prod_id <> "" and prod_op <> ""
        m.billing.ObserveField("catalog", "inAppUpdate1")
        m.billing.command = "getCatalog"
    else
        m.top.result = m.modalResult
        m.modalParam = invalid
    end if
    m.modalParamsDictionary = {}
    m.screenChangeDelay = invalid
end sub

sub inAppUpdate1()
    m.billing.unobserveField("catalog")
    m.catalog = m.billing.catalog
    for ii = 0 to m.catalog.getChildCount() - 1
        item = m.catalog.getChild(ii)
        if item.id = m.modalParam.path.actions.rf_settings_roku_product_id
            print "inapp update: found product id"
            m.updateItem = item
            m.billing.ObserveField("purchases", "inAppUpdate2")
            m.billing.command = "getPurchases"
            return
        end if
    end for
    m.top.result = m.modalResult
    m.modalParam = invalid
end sub

sub inAppUpdate2()
    m.billing.unobserveField("purchases")
    m.purchased = m.billing.purchases
    for ii = 0 to m.purchased.getChildCount() - 1
        item = m.purchased.getChild(ii)
        if item.id = m.modalParam.path.actions.rf_settings_roku_product_id
            print "inapp update: already purchased"
            m.top.result = m.modalResult
            m.modalParam = invalid
            return
        end if
    end for

    orders = CreateObject("roSGNode", "ContentNode")
    order = orders.createChild("ContentNode")
    order.addFields({ "code": m.updateItem.id, "qty": 1})
    orders.action = m.modalParam.path.actions.rf_settings_roku_product_operation
    m.billing.order = orders
    m.billing.ObserveField("orderStatus", "inAppUpdate3")
    m.billing.command = "doOrder"
end sub

sub inAppUpdate3()
    m.billing.unobserveField("orderStatus")
    m.modalResult.orderStatus = m.billing.orderStatus.status
    m.top.result = m.modalResult
    m.modalParam = invalid
end sub

sub onScreenChanged(params as Object)
    if m.promotionEnabled = false
        print "Rf: SDK disabled - " + params.screenName
        return
    endif
    print  "Rf: onScreenChanged - " + params.screenName
    m.currentScreenName = params.screenName
    if m.actions = invalid
        m.top.lastError = m.allErrors.invalid_action
        return
    end if

    path = getPath(m.actions, "")
    if path <> invalid
        modalParam = {}
        modalParam.appId = m.appId
        modalParam.userId = m.userId
        modalParam.deviceType = m.deviceType
        if path.action_group_id = invalid then path.action_group_id = ""
        modalParam.path = path
        modalParam.root = params.root
        m.modalParamsDictionary.addReplace(m.currentScreenName, modalParam)

        if m.screenChangeDelay <> invalid
            m.screenChangeDelay.control = "stop"
            m.screenChangeDelay = invalid
        end if
        if (path.delay_seconds > 0)
            m.screenChangeDelay = createObject("RoSGNode", "Timer")
            m.screenChangeDelay.duration = path.delay_seconds
            m.screenChangeDelay.observeField("fire", "onDisplayModal")
            m.screenChangeDelay.repeat = false
            m.screenChangeDelay.control = "start"
        else
            onDisplayModal()
        end if
    end if
end sub

sub onHoldOutUpdate()
    if m.holdout.state = "stop"
        m.holdout.unobserveField("fireEvent")
        if m.holdout.content <> invalid and m.holdout.content.success = true and m.modalParam <> invalid
            m.localStorage.createHoldOutKey(m.modalParam.path.id)
        end if
    end if
end sub

function isSuppressedByHoldout(path) as boolean
    isPresented = m.localStorage.hasHoldOutPresented(path.id)
    if path.holdout <> invalid and path.holdout = true
        if not isPresented
            m.holdout = callApi("onHoldOutUpdate")
            actionGroupId = ""
            if path.action_group_id <> invalid then actionGroupId = path.action_group_id
            m.holdout.callFunc("fireEvent", {event: "holdout", pathId: path.id, actionGroupId: actionGroupId})
        end if
        return true
    end if
    return isPresented
end function

sub onDisplayModal()
    print  "Rf: display modal for " + m.currentScreenName
    if not m.modalParamsDictionary.DoesExist(m.currentScreenName)
        print  "Rf: display modal aborted - screen obsolete"
        return
    end if
    m.modalParam = m.modalParamsDictionary.lookUp(m.currentScreenName)

    if isSuppressedByHoldout(m.modalParam.path)
        m.top.result = {value: m.allResults.holdout}
        return
    end if

    m.top.result = {value: m.allResults.launchingPromotion}

    if m.actions <> invalid and m.actions.anonymous_user_id <> invalid
        m.modalParam.anonymous_user_id = m.actions.anonymous_user_id
    end if
    m.modal = invalid
    pathTypes = PathType()
    if m.modalParam.path.path_type = pathTypes.modal or m.modalParam.path.path_type = pathTypes.modal2
        m.modal = createObject("roSGNode", "PromotionDialog")
    else
        m.modal = createObject("roSGNode", "PromotionVideoDialog")
    end if
    m.modal.font = m.top.font
    m.modal.observeField("result", "onModalDismissed")
    m.modal.callFunc("showModal", m.modalParam)
    m.modalParam.root.insertchild(m.modal, m.modalParam.root.getChildCount())
end sub

function getInlines(params as Object) as Object
    row = []
    di = CreateObject("roDeviceInfo")
    displaySize = di.GetDisplaySize()
    if m.actions <> invalid and m.actions.paths <> invalid
        for ii = 0 To m.actions.paths.count() - 1
            path = m.actions.paths[ii]
            isSuppressed = isSuppressedByHoldout(path)
            if not isSuppressed and path.actions.rf_settings_zone_id <> invalid and path.actions.rf_settings_zone_id = params.type
                heightSuffix = ""
                if displaySize.h = 480
                    heightSuffix = "&screen_size=480"
                else if displaySize.h = 720
                    heightSuffix = "&screen_size=720"
                else if displaySize.h = 1080
                    heightSuffix = "&screen_size=1080"
                else
                    heightSuffix = "&screen_size=1080"
                end if
                path.actions.rf_settings_bg_image_roku_os_tv_composite = path.actions.rf_settings_bg_image_roku_os_tv_composite + heightSuffix
                row.push(path)
            end if
        end for
    else
        m.top.lastError = m.allErrors.invalid_action
    end if
    return row
end function

sub getIapItems(params as Object)
    m.billing.ObserveField("catalog", "On_billing_catalog")
    m.billing.command = "getCatalog"
end sub

sub getPuchasedItems(params as Object)
    m.billing.ObserveField("purchases", "On_get_purchased")
    m.billing.command = "getPurchases"
end sub

sub On_get_purchased()
    m.billing.unobserveField("purchases")
    m.top.iapResult = m.billing.purchases
end sub

sub On_billing_catalog()
    m.billing.unobserveField("catalog")
    m.top.iapResult = m.billing.catalog
end sub

sub purchaseIap(params as Object)
    orders = CreateObject("roSGNode", "ContentNode")
    order = orders.createChild("ContentNode")
    order.addFields({ "code": params.sku, "qty": params.qty})
    if params.action <> invalid
        if "Upgrade" = params.action or "Downgrade" = params.action
            orders.action = params.action
        end if
    end if
    m.billing.order = orders
    m.billing.ObserveField("orderStatus", "On_billing_purchaseResult")
    m.billing.command = "doOrder"
end sub

sub On_billing_purchaseResult()
    m.billing.unobserveField("orderStatus")
    m.top.iapResult = m.billing.orderStatus
end sub

sub customTrack(params as Object)
    if m.promotionEnabled = false
        print  "Rf: SDK disabled - customTrack"
        return
    end if
    track = callApi("")
    track.callFunc("fireEvent", {event: "customTrack", customFieldId: params.customFieldId})
end sub

sub setUserId(params as Object)
    m.actions = invalid
    m.userid = params.userId
    updatePing()
end sub

function getUserId(params as Object) as Object
    return m.userid
end function

sub resetGoal(params as Object)
    m.localStorage.reset(false)
    track = callApi("")
    track.callFunc("fireEvent", {event: "resetGoal"})
end sub

function getMetas(params as Object) as Object
    meta = {}
    pathTypes = PathType()
    if m.actions <> invalid and m.actions.paths <> invalid
        for ii = m.actions.paths.count() - 1 To 0 step -1 'reverse order on the paths
            path = m.actions.paths[ii]
            if path.path_type = pathTypes.invisible and path.actions <> invalid and path.actions.rf_metadata <> invalid
                rt_meta = path.actions.rf_metadata
                keys = rt_meta.keys()
                for each key in rt_meta
                    meta[key] = rt_meta[key]
                end for
            end if
        end for
    end if
    return meta
end function