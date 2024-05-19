sub init()
    m.itemPoster = m.top.findNode("itemPoster")
    m.itemLabel = m.top.findNode("itemLabel")
    m.firstName = m.top.findNode("firstName")
    m.lastName = m.top.findNode("lastName")
    m.labelHeight = 80
    m.labelWidthOffset = 10
end sub

sub setSize()
    m.itemPoster.width = m.top.width
    m.itemPoster.height = m.top.height
    m.firstName.translation = [10, m.top.height / 2 + 40]
    m.lastName.translation = [10, m.top.height / 2 + 80]
    m.itemLabel.width = m.top.width - m.labelWidthOffset * 2
end sub

sub showcontent()
    itemcontent = m.top.itemContent
    m.itemPoster.uri = itemcontent.HDPOSTERURL
    if itemcontent.ContentType <> 0
        if itemcontent.ContentType <> 2
            m.itemPoster.height = m.top.height - m.labelHeight
            m.firstName.visible = false
            m.lastName.visible = false
            m.itemLabel.height = m.labelHeight
            m.itemLabel.translation = [m.labelWidthOffset, m.top.height - m.labelHeight]
            m.itemLabel.text = itemcontent.Description
        else
            m.itemPoster.height = m.top.height
            m.firstName.visible = false
            m.lastName.visible = false
            m.itemLabel.height = 0
            m.itemLabel.translation = [m.labelWidthOffset, m.top.height]
            m.itemLabel.text = ""
            fullName = itemcontent.title.split(" ")
            if fullName.count()  = 2
                m.firstName.visible = true
                m.lastName.visible = true
                m.firstName.text = fullName[0]
                m.lastName.text = fullName[1]
            end if
        end if
    else
        m.itemPoster.height = m.top.height
        m.firstName.visible = false
        m.lastName.visible = false
        m.itemLabel.height = 0
        m.itemLabel.translation = [m.labelWidthOffset, m.top.height]
        m.itemLabel.text = ""
    end if
end sub
