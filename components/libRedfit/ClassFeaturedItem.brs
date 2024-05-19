sub init()
    m.itemPoster = m.top.findNode("itemPoster")
    m.description = m.top.findNode("description")
    m.shortDescription = m.top.findNode("shortDescription")
end sub

sub setSize()
    m.itemPoster.width = m.top.width
    m.itemPoster.height = m.top.height
    m.description.translation = [50, m.top.height / 2 + 40]
    m.shortDescription.translation = [50, m.top.height / 2 + 100]
end sub

sub showcontent()
    itemcontent = m.top.itemContent
    m.itemPoster.uri = itemcontent.HDPOSTERURL
    m.description.text = itemcontent.title
    m.shortDescription.text = itemcontent.description
end sub