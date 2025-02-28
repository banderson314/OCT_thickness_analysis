# OCT_thickness_analysis
This is an ImageJ macro that semi-automatically measures retinal layer thickness in OCT images. The file must be in a format readable by ImageJ.

Please note that image files need to have a certain name format for this program to work properly:
1. The file must start out with the subject identifier 
2. This is then followed by either "_OD" or "_OS"
3. The name must also include one of the following: "horizontal" or "vertical" if they are central images or "superior", "inferior", "temporal", or "nasal"
Example: "Mouse1_OD_temporal.tif"

The macro is controlled through keyboard shortcuts, defined below and in ImageJ when it is installed. Alternatively, the user could use the menu under the macro tab.

Parameters for measurements can be set by pressing [1]. These will be reset to their original format any time this macro is reinstalled. Users can change the default variables by changing lines 29-38.

To use:
1. Using the line tool, make a line from one end of the image to the other, starting and ending on the one of the borders you want to measure.
2. By pressing [a], add splines along the line just created to have it match the border that you want to measure.
3. When you are happy with how the line is situated, press [s] to lock in the line. 
4. Repeat step 2 for the other border, then press [s] again.
5. Mark the center of the optic nerve with a vertical line, pressing [s] to confirm. 
6. Data will be presented via tables and lines drawn where measurements were taken, according to the user's specifications. Copy this data to a spreadsheet. All tables will be overwritten the next time an image is analyzed, except for the total averaged table.
7. Continue to the next image and repeat. Users can press [d] to have ImageJ open up the next image.

A few additional buttons are available. Please ignore them if they don't seem useful:
- Any of the green lines drawn by the program cannot be deleted. It is recommended that users make a copy of the images before analyzing.
- Pressing [8] will reset the borders previously submitted by pressing [s]. However, this will not delete any green lines previously drawn.
- Similar to the above, pressing [z] will undo the last line submitted by pressing [s].
- Pressing [9] will erase all data in the tables. This is useful if the user needs to clear the averaged table.
- Pressing [0] will allow the user to delete a specific entry in the averaged table.
- Pressing [w] will close the image and reopen it. The lines will also be reset.
- If something is going wrong and none of the above will fix it, reinstalling the macro will give a fresh restart. Any preferences changed will need to be changed again.