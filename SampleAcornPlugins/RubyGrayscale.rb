# Just copy this file to:
# ~/Library/Application Support/Acorn/Plug-Ins/.
# restart Acorn, and you're good to go!
# You can also edit this file without restarting Acorn to make changes.

ac_spec(
  :menuTitle    => "Ruby Convert to Grayscale", # required
  :superMenuTitle => 'Color',                   # optional
  :shortcutKey  => 'j',                         # optional
  :shortcutMask => [:command, :control] )       # optional

ac_action do |image, userObject|
    
    color = CIColor.colorWithRed_green_blue(0.5, 0.5, 0.5)
    @filter = CIFilter.filterWithName('CIColorMonochrome')
    @filter.setDefaults()
    @filter.setValue_forKey(image, 'inputImage')
    @filter.setValue_forKey(color, 'inputColor')
    @filter.setValue_forKey(1, 'inputIntensity')
    
    # this returns our image via some sort of ruby magic
    @filter.valueForKey('outputImage')
end
