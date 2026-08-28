# OCT Thickness Analysis

This is an ImageJ macro that semi-automatically measures retinal layer thickness in OCT images. The image file must be in a format that can be read by ImageJ.

The macro is controlled using keyboard shortcuts. The available shortcuts are described below and are also displayed in the **Log** dialog as the macro runs.

## How to Use

1. Using the **Line Tool**, draw a line from one end of the image to the other. Start and end the line on the borders of the region you want to measure.
2. Press **`[a]`** to add splines to the line. Add and adjust the splines until the line follows the border you want to measure.
3. When you are satisfied with the placement of the line, press **`[s]`** to lock it in.
4. Repeat steps 2–3 for the other border.
5. Mark the center of the optic nerve using a vertical line, then press **`[s]`** to confirm.
6. The macro will display the measurement data in tables and draw lines on the image showing where measurements were taken, according to the user's selected parameters.
7. Continue to the next image and repeat the process. Press **`[d]`** to have ImageJ open the next image.

## User-Set Parameters

User-set parameters can be accessed by pressing **`[1]`**.

These parameters are reset to their default values whenever the macro is reinstalled. To change the default parameters, edit the variables at the beginning of the code. These variables are clearly labeled.

## Image File Naming

The macro does not require a specific file-naming convention, but following the convention below will make the data tables easier to label.

Image filenames should contain the following information:

1. **Subject identifier** — The filename should begin with the subject identifier (e.g., `mouse1`, `control_485`, or `2054`).

2. **Eye** — Follow the subject identifier with either `_OD` or `_OS` to indicate the eye.

3. **Orientation** — Include one of the following terms to indicate image orientation:
   * `horizontal`
   * `vertical`
   * `superior`
   * `inferior`
   * `temporal`
   * `nasal`

For example:

`Mouse1_OD_temporal.tif`

## Additional Notes

* **Lines cannot be deleted:** Lines drawn by the program cannot be deleted unless the image is closed without being saved. It is recommended that users make a copy of their images before beginning an analysis.

* **Reset the current image:** Press **`[w]`** to close and reopen the current image. This will also reset the lines.

* **Restart the macro:** If an issue persists and cannot be resolved using the options above, reinstalling the macro will provide a fresh start. Any user-set preferences will need to be configured again.
