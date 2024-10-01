//OCT image thickness analysis macro
//Made by Brandon Anderson
//Last updated: March 23, 2023
//Version 2.2

//Image name requirements:
//Must start out with mouse number (doesn't have to be number) followed by either "_OD" or "_OS"
//Name must also include one of the following: "horizontal" or "vertical" if they are central images or "superior", "inferior", "temporal", or "nasal"


var count = 0;  //this is for the 's' key macro

var xLine1 = newArray("nothing");
var yLine1 = newArray("nothing");
var xLine2 = newArray("nothing");
var yLine2 = newArray("nothing");

var mouseNumberArray = newArray();
var eyeArray = newArray();
var locationArray = newArray();
var thickness = newArray();

var spiderGraph_mouseNumberArray = newArray();
var spiderGraph_eyeArray = newArray();
var spiderGraph_locationArray = newArray();
var spiderGraph_thickness = newArray();
var spiderGraph_distanceFromOpticNerve = newArray();

var averagedResultsMouseNumber = newArray();  //these variables are for the averaged thickness table
var averagedResultsEye = newArray();
var averagedResultsLocation = newArray();
var averagedResultsThickness = newArray();

var distanceBetweenLines = 2;     //options that the dialog box [1] gives you
var processTotalAverage = true;
var reportAllMeasurements = true;
var processSpidergraphData = true;
var spiderGraphLineDistance = 50;
var spiderGraphNumberOfLines = 12;
var drawMeasurementLines = false;
var saveLinesWhenOpenNewImage = false;
var drawSpiderGraphLines = false;
var pixelToMicronConversion = 2.19;



macro "Set parameters [1]" {
  distanceBetweenLines = abs(distanceBetweenLines);
  spiderGraphLineDistance = abs(spiderGraphLineDistance);

  Dialog.create("Set measurement parameters");
  Dialog.addCheckbox("Draw measurement lines", drawMeasurementLines);
  Dialog.addCheckbox("Save lines when you press 'd'?", saveLinesWhenOpenNewImage);
  Dialog.addMessage("");
  Dialog.addCheckbox("Output all individual measurements", reportAllMeasurements);
  Dialog.addCheckbox("Output average of all measurements", processTotalAverage);
  Dialog.addNumber("Distance between measurements for total average: ", distanceBetweenLines, 0, 8, "pixels");
  Dialog.addMessage("");
  Dialog.addCheckbox("Output processed spider graph data", processSpidergraphData);
  Dialog.addCheckbox("Draw spidergraph lines", drawSpiderGraphLines);
  Dialog.addNumber("Distance between measurements for spider graph: ", spiderGraphLineDistance, 0, 8, "pixels");
  Dialog.addNumber("Number of lines in spidergraph measurements:       ", spiderGraphNumberOfLines);
  //Dialog.addMessage("Assuming the image is 640 pixels wide and you are analyzing\nmouse OCT images, 1 pixel = 2.19 microns approximately");
  Dialog.addNumber("On the horizontal axis, 1 pixel =                                      ", pixelToMicronConversion, 4, 8, "microns");



  Dialog.show();

  drawMeasurementLines = Dialog.getCheckbox();
  saveLinesWhenOpenNewImage = Dialog.getCheckbox();
  reportAllMeasurements = Dialog.getCheckbox();
  processTotalAverage = Dialog.getCheckbox();
  distanceBetweenLines = Dialog.getNumber();
  processSpidergraphData = Dialog.getCheckbox();
  drawSpiderGraphLines = Dialog.getCheckbox();
  spiderGraphLineDistance = Dialog.getNumber();
  spiderGraphNumberOfLines = Dialog.getNumber();
  pixelToMicronConversion = Dialog.getNumber();
}




macro "Redo image [w]" {
  imageDirectory = File.directory;
  imageTitle = getTitle();
  close();
  count = 0;
  open(imageDirectory + imageTitle);
}

macro "Undo last line [z]" {
  count = count - 1;
  if (count < 0)
    count = 0;
}

function list(a) {
    for (i=0; i<a.length; i++)
        print(a[i]);

}

setTool("line");


var xLineLocation = newArray("nothing");
var yLineLocation = newArray("nothing");

macro "Make spline [a]" {
  if (xLineLocation[0] == "nothing") {
    Roi.getCoordinates(x,y);
    getCursorLoc(x2, y2, z2, flags);

    xLineLocation = Array.concat(x[0], x2, x[1]);
    yLineLocation = Array.concat(y[0], y2, y[1]);

    Roi.setPolylineSplineAnchors(xLineLocation, yLineLocation);
  } else {
    Roi.getSplineAnchors(x, y);   //this first part checks to see if you adjusted points manually and changes it's coordinates if you did
    xLineLocation = newArray();
    yLineLocation = newArray();
    for (i = 0; i < x.length; i++) {
      xLineLocation = Array.concat(xLineLocation, x[i]);
      yLineLocation = Array.concat(yLineLocation, y[i]);
    }

    getCursorLoc(x3, y3, z3, flags);

    xLineLocation = Array.concat(xLineLocation, x3); //adding a point wherever your cursor is
    yLineLocation = Array.concat(yLineLocation, y3);

    Array.sort(xLineLocation, yLineLocation);   //making sure the line goes from left to right

    Roi.setPolylineSplineAnchors(xLineLocation, yLineLocation);
  }
}



function contains(array, value) {
    for (i=0; i<array.length; i++)
      if (array[i] == value) return true;
    return false;
}





macro "Record line [s]" {
  if (count == 0) {     //The first time you call up this macro
    count = 1;
    Roi.getCoordinates(x, y);

    xShortened = newArray();
    yShortened = newArray();

    for (i = 0; i < x.length; i++) {    //Getting rid of repeat x values
      if (contains(xShortened, round(x[i])) == true) {
        continue;
      } else {
        xShortened = Array.concat(xShortened, round(x[i]));
        yShortened = Array.concat(yShortened, round(y[i]));
      }
    }

    xComplete = newArray();
    yComplete = newArray();


    xLine1 = xShortened;    //Applying it to the global variable
    yLine1 = yShortened;

    if(drawMeasurementLines == true) {    //Making a permanent line on image, if selected
      run("RGB Color");
      setForegroundColor(0, 255, 0);
      run("Draw");
    }

    run("Select None");     //removing the ROI line
    var xLineLocation = newArray("nothing");
    var yLineLocation = newArray("nothing");

    exit;
  }



  if (count == 1) {     //The second time you call up this macro
    count = 2;
    Roi.getCoordinates(x, y);

    xShortened = newArray();
    yShortened = newArray();

    for (i = 0; i < x.length; i++) {    //Getting rid of repeat x values
      if (contains(xShortened, round(x[i])) == true) {
        continue;
      } else {
        xShortened = Array.concat(xShortened, round(x[i]));
        yShortened = Array.concat(yShortened, round(y[i]));
      }
    }

    xLine2 = xShortened;    //Applying it to the global variable
    yLine2 = yShortened;

    if(drawMeasurementLines == true) {
      run("RGB Color");   //making a line where you put it
      setForegroundColor(0, 255, 0);
      run("Draw");
    }

    run("Select None");     //removing the line
    var xLineLocation = newArray("nothing");
    var yLineLocation = newArray("nothing");
    exit;
  }



  if (count == 2) {   //The third time you call up this macro
    count = 0;
    Roi.getCoordinates(x, y);
    opticNerveLocation = x[0];
    x1 = round(opticNerveLocation);


    ID = getTitle();

    if (indexOf(ID, "inferior") >= 0) {   //Determining if optic nerve on right side
      opticNerveSide = "right";
      location = "inferior";
    }
    if (indexOf(ID, "temporal") >= 0 && indexOf(ID, "OD") >= 0) {
      opticNerveSide = "right";
      location = "temporal";
    }
    if (indexOf(ID, "nasal") >= 0 && indexOf(ID, "OS") >= 0) {
      opticNerveSide = "right";
      location = "nasal";
    }

    if (indexOf(ID, "superior") >= 0) {         //Determining if optic nerve on left side
      opticNerveSide = "left";
      location = "superior";
    }
    if (indexOf(ID, "temporal") >= 0 && indexOf(ID, "OS") >= 0) {
      opticNerveSide = "left";
      location = "temporal";
    }
    if (indexOf(ID, "nasal") >= 0 && indexOf(ID, "OD") >= 0) {
      opticNerveSide = "left";
      location = "nasal";
    }


    if (indexOf(ID, "horizontal") >= 0){    //Determining if optic nerve is in the center
      opticNerveSide = "central";
      location = "horizontal";
    }

    if (indexOf(ID, "vertical") >= 0){
      opticNerveSide = "central";
      location = "vertical";
    }


    if (opticNerveSide == "right") {
      distanceBetweenLines = -1 * abs(distanceBetweenLines);     //Adjusting if the lines go to the left or the right
      spiderGraphLineDistance = -1 * abs(spiderGraphLineDistance);
      if (distanceBetweenLines > -30) {      //making sure the measurements don't start in the optic nerve
        x1 = x1 - 30;
      }
    }

    if (opticNerveSide == "left") {
      distanceBetweenLines = abs(distanceBetweenLines);
      spiderGraphLineDistance = abs(spiderGraphLineDistance);
      if (distanceBetweenLines < 30) {      //making sure the measurements don't start in the optic nerve
        x1 = x1 + 30;
      }
    }

    if (opticNerveSide == "central") {
      distanceBetweenLines = abs(distanceBetweenLines);
      spiderGraphLineDistance = abs(spiderGraphLineDistance);
      if (distanceBetweenLines < 30) {      //making sure the measurements don't start in the optic nerve
        x1 = x1 + 30;
      }
    }


    if (indexOf(ID, "OD") >= 0) {    //Figuring out what eye this is
      eye = "OD";
    }
    else if (indexOf(ID, "OS") >= 0) {
      eye = "OS";
    }
    else {eye = "?";}

    mouseNumber = substring(ID, 0, indexOf(ID, "_O"));  //Determining mouse, which should be the beginning of the title right before _OD or _OS


    mouseNumberArray = newArray();    //Uncomment this section if you want the result table to refresh with each image
    eyeArray = newArray();
    locationArray = newArray();
    distanceFromOpticNerve = newArray();
    thickness = newArray();


    while (x1 < 680 && x1 > -40) {      //While it is within the image. I want to have the loop go longer than the image
                                        //boundaries so that it will work for central images. It won't actually record past the image.
      x1 = x1 + distanceBetweenLines;

      if (opticNerveSide == "central" && x1 > 640) {   //going to the left in central images after it did the right side
          x1 = opticNerveLocation;
          distanceBetweenLines = -1 * abs(distanceBetweenLines);
          if (abs(distanceBetweenLines) < 30) {      //making sure the measurements don't start in the optic nerve
            x1 = x1 - 30;
          }
          x1 = x1 + distanceBetweenLines;
      }


      if (x1 > 640)   //If the line goes past the image, then it won't record
        continue;

      if (x1 < 0)
        continue;

      for (j = 0; j < xLine1.length; j++) {
        if (x1-5 == xLine1[j])  //if the x value isn't in the array, then it'll get close to it
          y1 = yLine1[j];
        if (x1-4 == xLine1[j])
          y1 = yLine1[j];
        if (x1-3 == xLine1[j])
          y1 = yLine1[j];
        if (x1-2 == xLine1[j])
          y1 = yLine1[j];
        if (x1-1 == xLine1[j])
          y1 = yLine1[j];

        if (x1 == xLine1[j]) {    //ideally this is the actual number I want
          y1 = yLine1[j];
          continue;
        }
      }

      for (j = 0; j < xLine2.length; j++) {   //Doing the same thing but for the second line
        if (x1-5 == xLine2[j])  //if the x value isn't in the array, then it'll get close to it
          y2 = yLine2[j];
        if (x1-4 == xLine2[j])
          y2 = yLine2[j];
        if (x1-3 == xLine2[j])
          y2 = yLine2[j];
        if (x1-2 == xLine2[j])
          y2 = yLine2[j];
        if (x1-1 == xLine2[j])
          y2 = yLine2[j];

        if (x1 == xLine2[j]) {    //ideally this is the actual number I want
          y2 = yLine2[j];
          continue;
        }
      }



      run("RGB Color");
      setForegroundColor(0, 255, 0);
      makeLine(x1, y1, x1, y2, 1);
      if(drawMeasurementLines == true)
        run("Draw");
      lineLength = abs(y1 - y2);



      mouseNumberArray = Array.concat(mouseNumberArray, mouseNumber);
      eyeArray = Array.concat(eyeArray, eye);
      locationArray = Array.concat(locationArray, location);
      distanceFromOpticNerve = Array.concat(distanceFromOpticNerve, x1 - round(opticNerveLocation));
      thickness = Array.concat(thickness, lineLength);
    }


    Mouse = mouseNumberArray;   //reporting the measurements
    Eye = eyeArray;
    Location = locationArray;
    Distance_From_Optic_Nerve = distanceFromOpticNerve;
    Thickness = thickness;
    if (reportAllMeasurements == true) {      //checking if the user decided if they want all the measurement reported
      Array.show("Results (row numbers)", Mouse, Eye, Location, Distance_From_Optic_Nerve, Thickness);
    }

    if (processTotalAverage == true) {      //checking if the user decided if they want the total average (see macro [1])
      Array.getStatistics(thickness, ignore1, ignore2, averageThickness, ignore3);  //getting the average thickness for the image
      averagedResultsMouseNumber = Array.concat(averagedResultsMouseNumber, Mouse[0]);  //these variables are for the averaged thickness table
      averagedResultsEye = Array.concat(averagedResultsEye, Eye[0]);
      averagedResultsLocation = Array.concat(averagedResultsLocation, Location[0]);
      averagedResultsThickness = Array.concat(averagedResultsThickness, averageThickness);

      Mouse = averagedResultsMouseNumber;   //reporting the measurements
      Eye = averagedResultsEye;
      Location = averagedResultsLocation;
      Thickness = averagedResultsThickness;

      Array.show("Averaged results (row numbers)", Mouse, Eye, Location, Thickness);
    }




    if (processSpidergraphData == true) {       //this section is if the user wants data processed for the spidergraphs.
                                                //a lot of this section is a repeat of the above section.
      x1 = round(opticNerveLocation);

      spiderGraph_mouseNumberArray = newArray();
      spiderGraph_eyeArray = newArray();
      spiderGraph_locationArray = newArray();
      spiderGraph_distanceFromOpticNerve = newArray();
      spiderGraph_thickness = newArray();


      for (i = 0; i < spiderGraphNumberOfLines; i++) {
        if (opticNerveSide == "central" && i == spiderGraphNumberOfLines/2) {   //if this is a central image, halfway through it'll analyze the left side
          x1 = round(opticNerveLocation);
          spiderGraphLineDistance = -1 * abs(spiderGraphLineDistance);
        }

        x1 = x1 + spiderGraphLineDistance;
        modifiedX1 = x1;

        if (x1 > 640)   //If the line goes past the image, then it will record the edge of the image
          modifiedX1 = 639;
        if (x1 < 0)
          modifiedX1 = 1;

        for (j = 0; j < xLine1.length; j++) {
          if (modifiedX1-5 == xLine1[j])  //if the x value isn't in the array, then it'll get close to it
            y1 = yLine1[j];
          if (modifiedX1-4 == xLine1[j])
            y1 = yLine1[j];
          if (modifiedX1-3 == xLine1[j])
            y1 = yLine1[j];
          if (modifiedX1-2 == xLine1[j])
            y1 = yLine1[j];
          if (modifiedX1-1 == xLine1[j])
            y1 = yLine1[j];

          if (modifiedX1 == xLine1[j]) {    //ideally this is the actual number I want
            y1 = yLine1[j];
            continue;
          }
        }

        for (j = 0; j < xLine2.length; j++) {   //Doing the same thing but for the second line
          if (modifiedX1-5 == xLine2[j])  //if the x value isn't in the array, then it'll get close to it
            y2 = yLine2[j];
          if (modifiedX1-4 == xLine2[j])
            y2 = yLine2[j];
          if (modifiedX1-3 == xLine2[j])
            y2 = yLine2[j];
          if (modifiedX1-2 == xLine2[j])
            y2 = yLine2[j];
          if (modifiedX1-1 == xLine2[j])
            y2 = yLine2[j];

          if (modifiedX1 == xLine2[j]) {    //ideally this is the actual number I want
            y2 = yLine2[j];
            continue;
          }
        }

        if (modifiedX1 != x1) {
          print("Error found when analyzing " + ID);
          print("Measurement at " + x1-round(opticNerveLocation) + " is outside of the image. Measurement instead taken at " + modifiedX1-round(opticNerveLocation) + ".");
        }


        run("RGB Color");
        setForegroundColor(255, 0, 0);    //making the lines red
        makeLine(x1, y1, x1, y2, 1);
        if(drawSpiderGraphLines == true)
          run("Draw");
        lineLength = abs(y1 - y2);



        spiderGraph_mouseNumberArray = Array.concat(spiderGraph_mouseNumberArray, mouseNumber);
        spiderGraph_eyeArray = Array.concat(spiderGraph_eyeArray, eye);
        spiderGraph_locationArray = Array.concat(spiderGraph_locationArray, location);
        spiderGraph_distanceFromOpticNerve = Array.concat(spiderGraph_distanceFromOpticNerve, x1 - round(opticNerveLocation));
        spiderGraph_thickness = Array.concat(spiderGraph_thickness, lineLength);

      }

      //This next part just adds the 0 distance from optic nerve
      if (location == "superior" || location == "nasal" || opticNerveSide == "central") {
        spiderGraph_mouseNumberArray = Array.concat(spiderGraph_mouseNumberArray, mouseNumber);
        spiderGraph_eyeArray = Array.concat(spiderGraph_eyeArray, eye);
        spiderGraph_locationArray = Array.concat(spiderGraph_locationArray, location);
        spiderGraph_distanceFromOpticNerve = Array.concat(spiderGraph_distanceFromOpticNerve, 0);
        spiderGraph_thickness = Array.concat(spiderGraph_thickness, 0);
      }

      //This next part rearranges the data so that it can be directly pasted into Prism or whatever graphing software

      if (opticNerveSide == "central") {
        specificLocationArray = newArray();
        if (spiderGraph_locationArray[0] == "vertical") {
          for (i=0; i<spiderGraph_distanceFromOpticNerve.length; i++) {
            if (spiderGraph_distanceFromOpticNerve[i] < 0)
              specificLocationArray = Array.concat(specificLocationArray, "inferior");
            if (spiderGraph_distanceFromOpticNerve[i] >= 0)
              specificLocationArray = Array.concat(specificLocationArray, "superior");
          }
        }
        if (spiderGraph_locationArray[0] == "horizontal") {
          for (i=0; i<spiderGraph_distanceFromOpticNerve.length; i++) {
            if (eye == "OS" && spiderGraph_distanceFromOpticNerve[i] != 0)
              spiderGraph_distanceFromOpticNerve[i] = -1 * spiderGraph_distanceFromOpticNerve[i];   //this is making it so spiderGraph_distanceFromOpticNerve
              //                                                                                      orients to the eye position (nasal/lateral), not image
              //                                                                                      position (left/right of optic nerve)
            if (spiderGraph_distanceFromOpticNerve[i] < 0)
              specificLocationArray = Array.concat(specificLocationArray, "temporal");
            if (spiderGraph_distanceFromOpticNerve[i] >= 0)
              specificLocationArray = Array.concat(specificLocationArray, "nasal");
          }
        }
        spiderGraph_locationArray = specificLocationArray;    //I just created that variable temporarily so I could redifine it for the central image sides
      }

      if (location == "nasal" || location == "temporal") {
        if (eye == "OS") {
          for (i = 0; i < spiderGraph_distanceFromOpticNerve.length; i++) {
            if (spiderGraph_distanceFromOpticNerve[i] != 0)
              spiderGraph_distanceFromOpticNerve[i] = -1 * spiderGraph_distanceFromOpticNerve[i];
          }
        }
      }

      Array.sort(spiderGraph_distanceFromOpticNerve, spiderGraph_mouseNumberArray, spiderGraph_eyeArray, spiderGraph_locationArray, spiderGraph_thickness);

      mmDistanceFromOpticNerve = newArray();      //making another column that has the distance from optic nerve in microns
      for (i=0; i<spiderGraph_distanceFromOpticNerve.length; i++) {
        convertedValue = spiderGraph_distanceFromOpticNerve[i] * abs(pixelToMicronConversion)/1000;   //divide by 1000 to convert micron to mm
        mmDistanceFromOpticNerve = Array.concat(mmDistanceFromOpticNerve, convertedValue);
      }


      Mouse = spiderGraph_mouseNumberArray;   //reporting the measurements
      Eye = spiderGraph_eyeArray;
      Location = spiderGraph_locationArray;
      Pixels_From_Optic_Nerve = spiderGraph_distanceFromOpticNerve;
      mm_From_Optic_Nerve = mmDistanceFromOpticNerve;
      Thickness = spiderGraph_thickness;
      Array.show("Spidergraph results (row numbers)", Mouse, Eye, Location, Pixels_From_Optic_Nerve, mm_From_Optic_Nerve, Thickness);

    }


    run("Select None");     //resetting everything for the next image
    var xLineLocation = newArray("nothing");
    var yLineLocation = newArray("nothing");
    var xLine1 = newArray("nothing");
    var yLine1 = newArray("nothing");
    var xLine2 = newArray("nothing");
    var yLine2 = newArray("nothing");
  }
}



macro "Open next [d]" {
  if (saveLinesWhenOpenNewImage == true) {
    run("Save");
  }
	run("Open Next");
}

macro "Reset lines [8]" {
  run("Select None");
  var xLineLocation = newArray("nothing");
  var yLineLocation = newArray("nothing");
  var xLine1 = newArray("nothing");
  var yLine1 = newArray("nothing");
  var xLine2 = newArray("nothing");
  var yLine2 = newArray("nothing");

  count = 0;
}


macro "Reset tables [9]" {
  var mouseNumberArray = newArray();
  var eyeArray = newArray();
  var locationArray = newArray();
  var distanceFromOpticNerve = newArray();
  var thickness = newArray();

  var averagedResultsMouseNumber = newArray();  //these variables are for the averaged thickness table
  var averagedResultsEye = newArray();
  var averagedResultsLocation = newArray();
  var averagedResultsThickness = newArray();
}

macro "Delete specific line in averaged table [0]" {
  Dialog.create("Delete line");
  Dialog.addMessage("What line do you want deleted?");
  Dialog.addNumber("Line number: ", 1);

  Dialog.show();

  deleteThisLine = Dialog.getNumber() - 1;    //Subtracting by one because the line number starts at 1 but the array starts at 0

  averagedResultsMouseNumber = Array.deleteIndex(averagedResultsMouseNumber, deleteThisLine);
  averagedResultsEye = Array.deleteIndex(averagedResultsEye, deleteThisLine);
  averagedResultsLocation = Array.deleteIndex(averagedResultsLocation, deleteThisLine);
  averagedResultsThickness = Array.deleteIndex(averagedResultsThickness, deleteThisLine);
  Array.show("Averaged results (row numbers)", averagedResultsMouseNumber, averagedResultsEye, averagedResultsLocation, averagedResultsThickness);
}
