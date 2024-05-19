sub init()
    content = createObject("RoSGNode", "ContentNode")
    for i = 0 to 9
        poster = content.createChild("ContentNode")
        poster.HDPOSTERURL = "pkg:/images/placement.jpg"
        poster.SHORTDESCRIPTIONLINE1 = "hello #" + i.toStr()
        poster.SHORTDESCRIPTIONLINE2 = "world"
    end for
    
    m.classGrid = m.top.findNode("classGrid")
    m.classGrid.numRows = (content.getChildCount() + 1) / 2
    m.classGrid.content = content
    m.classGrid.setFocus(true) 
end sub