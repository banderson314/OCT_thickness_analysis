// ===============================================================================
// vvvv Edit the below variables if you want to change the default settings vvvv
// ===============================================================================
var reportAllMeasurements = true;
var processTotalAverage = true;
var drawMeasurementLines = true;
var distanceBetweenLines = 2;
var processSpidergraphData = true;
var drawSpiderGraphLines = true;
var spiderGraphLineDistance = 50;
var saveLinesWhenOpenNewImage = false;
var pixelToMicronConversion = 2.19;
var boundaryAroundOpticNerve = 30;
var forceMeasureBothSides = false;
// ===============================================================================
// ^^^^ Edit the above variables if you want to change the default settings ^^^^
// ===============================================================================

// ===================================
// Global variables not edited by user
// ===================================
var count = 0;
var xLine1 = newArray("nothing");
var yLine1 = newArray("nothing");
var xLine2 = newArray("nothing");
var yLine2 = newArray("nothing");
var xLineLocation = newArray("nothing");
var yLineLocation = newArray("nothing");
var thickness = newArray();
var reverseSpiderGraph = false;
var spiderGraph_thickness = newArray();
var spiderGraph_distanceFromOpticNerve = newArray();

// =========================================
// Initiating settings when first installed
// =========================================
macro "AutoRunAndHide" {
	setTool("line");
	doCommand("Set parameters [1]");
	print("\\Clear");
	print("Welcome to OCT_image_thickness.ijm!");
	print("\nIf you use this macro to publish data, please cite it:\nAnderson, B. (2026). Semiautomated OCT thickness analysis (Version v2.3) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.22150403");
	
	print("\\Update6:To get started, use the line tool to mark the first border of interest.")
	print("\\Update8:CONTROLS");
	print("\\Update9:[a] Adjust line shape");
	print("\\Update10:[s] Submit line");
	print("\\Update11:[w] Redo the image");
	print("\\Update12:[1] Change parameters");
}

// ================================
// Settings for the user to change
// ================================
macro "Set parameters [1]" {
	distanceBetweenLines = abs(distanceBetweenLines);
	spiderGraphLineDistance = abs(spiderGraphLineDistance);

	Dialog.create("Set Measurement Parameters");

	Dialog.setInsets(5, 20, 0);
	Dialog.addMessage("Average Measurements", 16);
	Dialog.setInsets(0, 20, 0);
	Dialog.addCheckbox("Output individual measurements", reportAllMeasurements);
	Dialog.addCheckbox("Output overall average", processTotalAverage);
	Dialog.addCheckbox("Draw measurement lines", drawMeasurementLines);
	Dialog.addNumber("Distance between measurements:", distanceBetweenLines, 0, 8, "pixels");

	Dialog.addMessage("Spidergraph Measurements", 16);
	Dialog.addCheckbox("Output spidergraph data", processSpidergraphData);
	Dialog.addCheckbox("Draw measurement lines", drawSpiderGraphLines);
	Dialog.addNumber("Distance between measurements:", spiderGraphLineDistance, 0, 8, "pixels");

	Dialog.addMessage("General Settings", 16);
	Dialog.addCheckbox("Save lines when opening a new image with [d]", saveLinesWhenOpenNewImage);
	Dialog.addCheckbox("Always measure both sides of the optic nerve", forceMeasureBothSides);
	Dialog.addNumber("Horizontal scale: 1 pixel =", pixelToMicronConversion, 2, 8, "microns");
	Dialog.addNumber("Exclusion distance around the optic nerve:", boundaryAroundOpticNerve, 0, 8, "pixels");

	Dialog.show();

	reportAllMeasurements = Dialog.getCheckbox();
	processTotalAverage = Dialog.getCheckbox();
	drawMeasurementLines = Dialog.getCheckbox();
	distanceBetweenLines = Dialog.getNumber();
	processSpidergraphData = Dialog.getCheckbox();
	drawSpiderGraphLines = Dialog.getCheckbox();
	spiderGraphLineDistance = Dialog.getNumber();
	saveLinesWhenOpenNewImage = Dialog.getCheckbox();
	forceMeasureBothSides = Dialog.getCheckbox();
	pixelToMicronConversion = Dialog.getNumber();
	boundaryAroundOpticNerve = Dialog.getNumber();
}


// ==================================================
// Close and reopen current image, resetting progress
// ==================================================
macro "Redo image [w]" {
	getLocationAndSize(x, y, width, height);
	imageDirectory = File.directory;
	imageTitle = getTitle();
	close();
	count = 0;
	open(imageDirectory + imageTitle);
	setLocation(x, y, width, height);
	reportProgress();
}


// =============================================
// Helper function to report on user's progress
// =============================================
function reportProgress() {
	print("\\Update0:CURRENT PROGRESS");
	print("\\Update2:");
	print("\\Update3:CURRENT IMAGE");
	print("\\Update7:");
	print("\\Update8:CONTROLS");
	print("\\Update11:[w] Redo the image");
	print("\\Update12:[1] Change parameters");

	if (count == 0){
		ID = getTitle();
		ID = toLowerCase(ID);
		if (indexOf(ID, "od")>=0 && indexOf(ID, "os")>=0)
			eye = "unknown";
		else if (indexOf(ID, "od")>=0)
			eye = "OD";
		else if (indexOf(ID, "os")>=0)
			eye = "OS";
		else
			eye = "unknown";
		if (indexOf(ID, "horizontal")>=0 || indexOf(ID, "temporal")>=0 || indexOf(ID, "nasal")>=0)
			position = "horizontal";
		else if (indexOf(ID, "vertical")>=0 || indexOf(ID, "inferior")>=0 || indexOf(ID, "superior")>=0)
			position = "vertical";
		else
			position = "unknown";

		print("\\Update1:Lines submitted: 0");
		print("\\Update4:Eye: " + eye);
		print("\\Update5:Position: " + position);
		if (eye == "OS" && position == "horizontal") {
			print("\\Update6:Spider graph flipped to match OD orientation");
			reverseSpiderGraph = true;
		} else {
			print("\\Update6:");
			reverseSpiderGraph = false;
		}

		print("\\Update9:[a] Adjust line shape");
		print("\\Update10:[s] Submit line");
	}

	else if (count ==1){
		print("\\Update1:Lines submitted: 1");
	}
	else if (count == 2) {
		print("\\Update1:Lines submitted: 2");
		print("\\Update9:[s] Submit line to indicate optic nerve");
		print("\\Update10:Note that only the first point you make with the line will matter");
	}
	else if (count ==3) {
		print("\\Update1:Analysis complete");
		print("\\Update9:[d] Open next image in the folder");
		print("\\Update10:[w] Redo the image");
		print("\\Update11:[1] Change parameters");
		print("\\Update12:");
	}

}

// =======================================================
// User ability to create splines to change shape of line
// =======================================================
macro "Make spline [a]" {
	reportProgress();
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


// ==============================================
// Helper function to see if an array has a value
// ===============================================
function contains(array, value) {
	for (i=0; i<array.length; i++)
	  if (array[i] == value) return true;
	return false;
}


// ======================================================================
// User submits a line - changes what it does depending on count variable
// ======================================================================
macro "Record line [s]" {
	// ===============================================
	// User submitting first line
	// ===============================================
	if (count == 0) {     //The first time you call up this macro
		count = 1;
		reportProgress();
		Roi.getCoordinates(x, y);

		xShortened = newArray();
		yShortened = newArray();

		// Getting rid of repeat x values
		for (i = 0; i < x.length; i++) {
		if (contains(xShortened, round(x[i])) == true) {
			continue;
		} else {
			xShortened = Array.concat(xShortened, round(x[i]));
			yShortened = Array.concat(yShortened, round(y[i]));
		}
		}

		xComplete = newArray();
		yComplete = newArray();

		imageWidth = getWidth();
		for (i = 0; i < imageWidth; i++) {
		// Find the two surrounding points in xShortened
		leftX = -1;
		rightX = -1;
		leftY = -1;
		rightY = -1;

		for (j = 0; j < xShortened.length - 1; j++) {
			if (xShortened[j] <= i && xShortened[j+1] >= i) {
			leftX = xShortened[j];
			leftY = yShortened[j];
			rightX = xShortened[j+1];
			rightY = yShortened[j+1];
			break;
			}
		}

		if (i < xShortened[0]) {
			// Left of all points
			yComplete = Array.concat(yComplete, yShortened[0]);
		
		} else if (i > xShortened[xShortened.length - 1]) {
			// Right of all points
			last = xShortened.length - 1;
			yComplete = Array.concat(yComplete, yShortened[last]);
		
		} else if (leftX != -1) {
			// Interpolate
			yInterp = leftY + (i - leftX) * (rightY - leftY) / (rightX - leftX);
			yComplete = Array.concat(yComplete, round(yInterp));
		}

		xComplete = Array.concat(xComplete, i);
		}

		xLine1 = xComplete;    //Applying it to the global variable
		yLine1 = yComplete;

		if(drawMeasurementLines == true) {    //Making a permanent line on image, if selected
			run("RGB Color");
			setForegroundColor(0, 255, 0);
			run("Draw");
		}

		run("Select None");     //removing the ROI line
		var xLineLocation = newArray("nothing");
		var yLineLocation = newArray("nothing");

		exit();
	}


	// ===============================================
	// User submitting second line
	// ===============================================
	if (count == 1) {     //The second time you call up this macro
		count = 2;
		reportProgress();
		Roi.getCoordinates(x, y);
	
		xShortened = newArray();
		yShortened = newArray();
	
		// Getting rid of repeat x values
		for (i = 0; i < x.length; i++) {    
		  if (contains(xShortened, round(x[i])) == true) {
			continue;
		  } else {
			xShortened = Array.concat(xShortened, round(x[i]));
			yShortened = Array.concat(yShortened, round(y[i]));
		  }
		}
	
		xComplete = newArray();
		yComplete = newArray();
	
		imageWidth = getWidth();
		for (i = 0; i < imageWidth; i++) {
			// Find the two surrounding points in xShortened
			leftX = -1;
			rightX = -1;
			leftY = -1;
			rightY = -1;
	  
			for (j = 0; j < xShortened.length - 1; j++) {
			  if (xShortened[j] <= i && xShortened[j+1] >= i) {
				leftX = xShortened[j];
				leftY = yShortened[j];
				rightX = xShortened[j+1];
				rightY = yShortened[j+1];
				break;
			  }
			}
	  
			if (i < xShortened[0]) {
				// Left of all points
				yComplete = Array.concat(yComplete, yShortened[0]);
			
			} else if (i > xShortened[xShortened.length - 1]) {
				// Right of all points
				last = xShortened.length - 1;
				yComplete = Array.concat(yComplete, yShortened[last]);
			
			} else if (leftX != -1) {
				// Interpolate
				yInterp = leftY + (i - leftX) * (rightY - leftY) / (rightX - leftX);
				yComplete = Array.concat(yComplete, round(yInterp));
			}
	  
			xComplete = Array.concat(xComplete, i);
		  }
	
		xLine2 = xComplete;    //Applying it to the global variable
		yLine2 = yComplete;
	
		if(drawMeasurementLines == true) {
			run("RGB Color");   //making a line where you put it
			setForegroundColor(0, 255, 0);
			run("Draw");
		}
	
		run("Select None");     //removing the line
		var xLineLocation = newArray("nothing");
		var yLineLocation = newArray("nothing");
	  
		// Coding test to print all the detected points
		test = false;
		if (test == true) {
			xPoints = xLine1;
			y1Points = yLine1;
			y2Points = yLine2;
			distanceBetweenPoints = newArray();
			for (i = 0; i < xPoints.length; i++) {
				calculatedDifference = y2Points[i] - y1Points[i];
				distanceBetweenPoints = Array.concat(distanceBetweenPoints, calculatedDifference);
			}
			Array.show("Points", xPoints, y1Points, y2Points, distanceBetweenPoints);
		}

		exit();
	}


	// ================================================
	// Measuring distance between both submitted lines
	// ================================================
	if (count == 2) {   //The third time this macro is called
		count = 3;
		reportProgress();

		count = 0;
		Roi.getCoordinates(x, y);
		opticNerveLocation = round(x[0]);
		x1 = opticNerveLocation;

		run("RGB Color");
		setForegroundColor(0, 255, 0);

		distanceFromOpticNerve = newArray();
		thickness = newArray();

		// Determining points to measure
		xPointsToMeasure = newArray();

		// Skipping left or right side if optic nerve is close to the edge
		skipLeftSide = false;
		skipRightSide = false;
		opticNerveLocationProportion = opticNerveLocation / getWidth();
		if (opticNerveLocationProportion < 0.25 && forceMeasureBothSides == false) {
			skipLeftSide = true;
		} else if (opticNerveLocationProportion > 0.75 && forceMeasureBothSides == false) {
			skipRightSide = true;
		}
		if (forceMeasureBothSides == true) {
			skipLeftSide = false;
			skipRightSide = false;
		}

		// Grabbing x values left of optic nerve
		xLeft = opticNerveLocation - boundaryAroundOpticNerve;
		while (xLeft >= 0 && skipLeftSide == false) {
			xPointsToMeasure = Array.concat(xPointsToMeasure, xLeft);
			xLeft -= distanceBetweenLines;
		}

		// Grabbing x values right of optic nerve
		xRight = opticNerveLocation + boundaryAroundOpticNerve;
		while (xRight < getWidth() && skipRightSide == false) {
			xPointsToMeasure = Array.concat(xPointsToMeasure, xRight);
			xRight += distanceBetweenLines;
		}

		Array.sort(xPointsToMeasure);

		// Measuring the points
		for (j=0; j<xPointsToMeasure.length; j++) {
			x_point = xPointsToMeasure[j];

			y1 = yLine1[x_point];
			y2 = yLine2[x_point];
		
			makeLine(x_point, y1, x_point, y2);
		
			if (drawMeasurementLines)
				run("Draw");
		
			lineLength = abs(y1 - y2);
		
			distanceFromOpticNerve = Array.concat(
				distanceFromOpticNerve,
				round(x_point - opticNerveLocation)
			);
		
			thickness = Array.concat(thickness, lineLength);
		}

		// =================================
		// Spidergraph processing
		// =================================
		if (processSpidergraphData == true) {
			spiderGraph_distanceFromOpticNerve = newArray();
			spiderGraph_thickness = newArray();
		
			// Determining points to measure
			xPointsToMeasure = newArray();
		
			// Grabbing x values left of optic nerve
			startingPoint = maxOf(boundaryAroundOpticNerve, spiderGraphLineDistance);
			xLeft = opticNerveLocation - startingPoint;
			while (xLeft >= 0 && skipLeftSide == false) {
				xPointsToMeasure = Array.concat(xPointsToMeasure, xLeft);
				xLeft -= spiderGraphLineDistance;
			}
		
			// Grabbing x values right of optic nerve
			xRight = opticNerveLocation + startingPoint;
			while (xRight < getWidth() && skipRightSide == false) {
				xPointsToMeasure = Array.concat(xPointsToMeasure, xRight);
				xRight += spiderGraphLineDistance;
			}
		
			Array.sort(xPointsToMeasure);
		
			// Measuring the points
			for (j=0; j<xPointsToMeasure.length; j++) {
				x_point = xPointsToMeasure[j];
		
				y1 = yLine1[x_point];
				y2 = yLine2[x_point];
			
				makeLine(x_point, y1, x_point, y2);

				run("RGB Color");
				setForegroundColor(255, 0, 0);    //making the lines red
				if(drawSpiderGraphLines == true)
				run("Draw");

				lineLength = abs(y1 - y2);
			
				spiderGraph_distanceFromOpticNerve = Array.concat(
					spiderGraph_distanceFromOpticNerve,
					round(x_point - opticNerveLocation)
				);
			
				spiderGraph_thickness = Array.concat(spiderGraph_thickness, lineLength);
			}
		}
	

		// =================================
		// Reporting data
		// =================================
		// Getting info on the image
		ID = getTitle();
		lowerID = toLowerCase(ID);

		// Determining eye
		if (indexOf(lowerID, "od") >= 0)
			eye = "OD";
		else if (indexOf(lowerID, "os") >=0)
			eye = "OS";
		else
			eye = "unknown";
		
		// Determining ID, which should be the beginning of the title right before _OD or _OS
		index = indexOf(lowerID, "_o");
		if (index > 0)
			idNumber = substring(ID, 0, index);
		else
			idNumber = ID;

		// Determining orientation
		if (indexOf(ID, "horizontal")>=0 || indexOf(ID, "temporal")>=0 || indexOf(ID, "nasal")>=0)
			orientation = "horizontal";
		else if (indexOf(ID, "vertical")>=0 || indexOf(ID, "inferior")>=0 || indexOf(ID, "superior")>=0)
			orientation = "vertical";
		else
			orientation = "unknown";


		// Give table of all measurements
		if (reportAllMeasurements == true) {
			if (!isOpen("Measurements")) {
				Table.create("Measurements");
				Table.setLocationAndSize(100, 100, 600, 800, "Measurements");
			}

			row = Table.size("Measurements");

			for (i = 0; i < distanceFromOpticNerve.length; i++) {
				Table.set("ID", row+i, idNumber);
				Table.set("Eye", row+i, eye);
				Table.set("Orientation", row+i, orientation);
				Table.set("Distance from optic nerve", row+i, distanceFromOpticNerve[i]);
				Table.set("Thickness", row+i, thickness[i]);
			}
			Table.update("Measurements");
		}

		// Give table of averaged thickness
		if (processTotalAverage == true) {
			Array.getStatistics(thickness, _, _, averageThickness, _);
			
			if (!isOpen("Averaged measurements")) {
				Table.create("Averaged measurements");
				Table.setLocationAndSize(700, 500, 400, 400, "Averaged measurements");
			}

			row = Table.size("Averaged measurements");
			
			Table.update("Averaged measurements");
			Table.set("ID", row, idNumber);
			Table.set("Eye", row, eye);
			Table.set("Orientation", row, orientation);
			Table.set("Thickness", row, averageThickness);
			Table.update("Averaged measurements");
		}

		// Give table of spidergraph measurements
		if (processSpidergraphData == true) {
			if (reverseSpiderGraph == true) {
				for (i = 0; i < spiderGraph_distanceFromOpticNerve.length; i++)
					spiderGraph_distanceFromOpticNerve[i] = -1 * spiderGraph_distanceFromOpticNerve[i];
			}
			
			// Adding the 0 thickness measurement at the optic nerve
			spiderGraph_distanceFromOpticNerve = Array.concat(spiderGraph_distanceFromOpticNerve, 0);
			spiderGraph_thickness = Array.concat(spiderGraph_thickness, 0);

			Array.sort(spiderGraph_distanceFromOpticNerve, spiderGraph_thickness);

			if (!isOpen("Spidergraph measurements")) {
				Table.create("Spidergraph measurements");
				Table.setLocationAndSize(700, 100, 700, 400, "Spidergraph measurements");
			}

			row = Table.size("Spidergraph measurements");
			Table.update("Spidergraph measurements");

			for (i = 0; i < spiderGraph_distanceFromOpticNerve.length; i++) {
				Table.set("ID", row+i, idNumber);
				Table.set("Eye", row+i, eye);
				Table.set("Orientation", row+i, orientation);
				Table.set("Distance from ON (px)", row+i, spiderGraph_distanceFromOpticNerve[i]);
				Table.set("Distance from ON (µm)", row+i, 
					round(spiderGraph_distanceFromOpticNerve[i] * pixelToMicronConversion));
				Table.set("Thickness", row+i, round(spiderGraph_thickness[i]));
			}
			Table.update("Spidergraph measurements");
		}


		// =========================================
		// Resetting measurements for the next image
		// =========================================
		run("Select None");
		var xLineLocation = newArray("nothing");
		var yLineLocation = newArray("nothing");
		var xLine1 = newArray("nothing");
		var yLine1 = newArray("nothing");
		var yLine2 = newArray("nothing");
	}
}


// =================================
// Open the next image in the folder
// =================================
macro "Open next [d]" {
	getLocationAndSize(x, y, width, height);
	if (saveLinesWhenOpenNewImage == true) {
		run("Save");
	}
	run("Open Next");
	setLocation(x, y, width, height);
	reportProgress();
}