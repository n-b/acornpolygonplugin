# Just copy this file to:
# ~/Library/Application Support/Acorn/Plug-Ins/.
# and away you go!

import objc

ACScriptSuperMenuTitle = "Color"
ACScriptMenuTitle = "Make Grayscale (python)"

CIColor  = objc.lookUpClass('CIColor')
CIFilter = objc.lookUpClass('CIFilter')

def main(image):
    
    color = CIColor.colorWithRed_green_blue_(0.5, 0.5, 0.5)
    
    filter = CIFilter.filterWithName_('CIColorMonochrome')
    filter.setDefaults()
    
    filter.setValue_forKey_(image, 'inputImage')
    filter.setValue_forKey_(color, 'inputColor')
    filter.setValue_forKey_(1, 'inputIntensity')
    
    return filter.valueForKey_('outputImage')

