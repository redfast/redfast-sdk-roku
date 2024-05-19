sub init()
    m.Site_ID = "5f5aa775007c308041027bcf"
    m.BASE_URL = "https://api.webflow.com/"
end sub

sub getContent(params as Object)
    m.top.functionName = "getContentImpl"
    m.top.control = "run"
    m.params = params
end sub

function makeUrl(api as string) as object
    urlString = m.BASE_URL + api
    connection = CreateObject("roUrlTransfer")
    connection.SetCertificatesFile("common:/certs/ca-bundle.crt")
    connection.InitClientCertificates() 
    connection.AddHeader("Authorization", "Bearer 4a1f244c1650fa43c4d28cc00c59cd14e94f287619199fb9bb8b8b46622a17a0")
    connection.AddHeader("accept-version", "1.0.0")
    connection.AddHeader("Content-Type", "application/json")
    connection.AddHeader("Accept", "*/*")
    connection.AddHeader("Connection", "keep-alive")
    port = CreateObject("roMessagePort")
    connection.SetPort(port)
    connection.SetUrl(urlString)
    if connection.AsyncGetToString()
        event = wait(10000, port)
        if type(event) = "roUrlEvent"
            if event.GetResponseCode() = 200
                json = event.GetString()
                return ParseJson(json)
            else
                print event.GetFailureReason()
            end if
        end if
    else
        print "AsyncGetToString failed"
    end if
    return invalid
end function

sub getContentImpl()
    contentRoot = createObject("RoSGNode", "ContentNode")
    rootJson = makeUrl("sites/" + m.Site_ID + "/collections")
    if rootJson = invalid then return
    subsetNames = m.params.subset
    for ii = 0 to subsetNames.count() - 1 step 1
        for jj = 0 to rootJson.count() - 1 step 1
            if subsetNames[ii] = rootJson[jj].name
                itemsJson = makeUrl("collections/" + rootJson[jj]._id + "/items")
                itemsRoot = contentRoot.createChild("ContentNode")
                itemsRoot.title = subsetNames[ii]
                for kk = 0 to itemsJson.items.count() - 1 step 1
                    item = itemsRoot.createChild("ContentNode")
                    item.title = itemsJson.items[kk].name
                    item.Description = itemsJson.items[kk]["short-description"]
                    if m.params.screen = 0 or m.params.screen = 2
                        appImage = itemsJson.items[kk]["app-image"]
                        profileImage = itemsJson.items[kk]["app-profile-image"]
                        if appImage <> invalid
                            item.HDPOSTERURL = appImage.url
                        end if
                        if profileImage <> invalid
                            item.HDPOSTERURL = profileImage.url
                        end if
                        if subsetNames[ii] <> "Trainers"
                            item.ContentType = "movie"
                        else
                            item.ContentType = "series"
                        end if
                    else if m.params.screen = 1
                        image1 = itemsJson.items[kk]["image-1"]
                        appImage = itemsJson.items[kk]["app-image"]
                        if image1 <> invalid
                            item.HDPOSTERURL = image1.url
                        else if appImage <> invalid
                            item.HDPOSTERURL = appImage.url
                        end if
                    else if m.params.screen = 3
                        item.ShortDescriptionLine1 = itemsJson.items[kk]["name"]
                        item.ShortDescriptionLine2 = itemsJson.items[kk]["price"]
                        appImage = itemsJson.items[kk]["app-image"]
                        if appImage <> invalid
                            item.HDPOSTERURL = appImage.url
                        end if
                    end if
                end for
                exit for
            end if
        end for
    end for
    m.top.content = contentRoot
end sub