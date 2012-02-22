# Just copy this file to:
# ~/Library/Application Support/Acorn/Plug-Ins/.
# and away you go!

import objc
from Foundation import *

ACScriptSuperMenuTitle = None
ACScriptMenuTitle = "Add Grey Border"

CIImage = objc.lookUpClass('CIImage')
NSColor = objc.lookUpClass('NSColor')
NSBezierPath = objc.lookUpClass('NSBezierPath')

def main(image):
    
    nsimg = image.NSImage()
    
    nsimg.lockFocus()
    NSColor.grayColor().set()
    
    path = NSBezierPath.bezierPathWithRect_(NSMakeRect(.5, .5, nsimg.size().width - 1, nsimg.size().height - 1))
    
    path.stroke()
    
    nsimg.unlockFocus()
    
    return CIImage.imageWithData_(nsimg.TIFFRepresentation())

