sub init()
    m.itemPoster = m.top.findNode("itemPoster")
    m.description = m.top.findNode("description")
    m.shortDescription = m.top.findNode("shortDescription")
end sub

sub setSize()
    m.itemPoster.width = m.top.width
    m.itemPoster.height = m.top.height - 70
    m.description.translation = [10, m.top.height - 60]
    m.description.width = m.top.width - 20
    m.shortDescription.translation = [10, m.top.height - 25]
    m.shortDescription.width = m.top.width - 20
end sub

sub showcontent()
    itemcontent = m.top.itemContent
    m.itemPoster.uri = itemcontent.HDPOSTERURL
    m.description.text = itemcontent.title
    m.shortDescription.text = itemcontent.description
end sub