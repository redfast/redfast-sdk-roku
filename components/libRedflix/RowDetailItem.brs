sub init()
    m.meta = m.top.findNode("meta")
    m.itemPoster = m.top.findNode("itemPoster")
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")
    m.duration = m.top.findNode("duration")
    m.director = m.top.findNode("director")

    m.posterOnly = m.top.findNode("posterOnly")
end sub

sub setSize()
    m.itemPoster.width = 440
    m.itemPoster.height = 585

    m.posterOnly.width = m.top.width
    m.posterOnly.height = m.top.height

end sub

sub showcontent()
    itemcontent = m.top.itemContent
    if itemcontent.ContentType = 1
        m.meta.visible = true
        m.posterOnly.visible = false

        m.itemPoster.uri = itemcontent.HDPOSTERURL
        m.title.text = itemcontent.title
        m.description.text = itemcontent.description
        m.duration.text = itemcontent.ShortDescriptionLine2
        m.director.text = itemcontent.Directors[0]
    else
        m.meta.visible = false
        m.posterOnly.visible = true
        m.posterOnly.uri = itemcontent.HDPOSTERURL
    end if
end sub