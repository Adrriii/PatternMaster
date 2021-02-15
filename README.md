# PatternMaster

Edit a pattern that is repeated throughout the map

# Installation

Download and copy to Quaver/Plugins.

The path will look like : `Quaver\Plugins\PatternMaster\plugin.lua`

`plugin.lua` and `settings.ini` are required.

# Usage

- In the first tab, select boundaries to define your pattern and give it a name. This will create a new tab in which you'll be able to manage it.
- In you pattern's tab, add occurences where you want your pattern to be repeated.
- Use the refresh button to delete the notes during occurences and replace them by what is currently in your pattern's boundaries.

## Important notes

- This plugin destroys parts of the map according to your input (When using Refresh). Be careful.
- This plugins uses layers to store your patterns. 
    - It means you can exit the editor without losing them as long as you save your map. 
    - It also means that you might notice strange layers in your maps, and also that anyone modding the map will be able to see the patterns if they have this plugin as well.

## Tips

- You can fast forward to your pattern and its occurences by clicking the according buttons.
- You can delete an occurence by clicking the delete button next to it.
- You can delete a pattern by clicking the bottom-most button : There is no confirmation, click at your own risk.
- The "Current" buttons will autofill the offset input with your current position in the map. Use them.

## Credits

The code is largely inspired from these two plugins, thank you to their authors :
- https://github.com/IceDynamix/iceSV
- https://github.com/Illuminati-CRAZ/Memory-2
