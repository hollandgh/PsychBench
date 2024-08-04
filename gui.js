//Giles Holland 2024.08.02 4:14 pm


//TODO check for menus sheet exists and okay before doing anything




//////////////////////////////////////////////////////////////////////////////////////////////////// ON EDIT
function onEdit(e) {

                var range = e.range;
                var sheet = range.getSheet();

    if (!includesi(["about", "trial list", "docs", "menus"], sheet.getName()) && sheet.getMaxRows() > 1) {
        //Table sheet and at least 2 heading rows

                var workingCell = SpreadsheetApp.getActive().getSheetByName("MENUS").getRange(1, 2);
                var numRows = range.getNumRows();
                var numCols = range.getNumColumns();
                
        if (!(e.value == undefined && e.oldValue == undefined && numRows == 1 && numCols == 1 && workingCell.getValue() == "...")) {
            //Not programmatic edits caused by Undo/Redo (Google bug #1).
            //Works at the last undo step (removing working cell val) because that's at a different cell from the user-edited cell.
            //e.value, .oldValue both === undefined even for single cell at undo, even if simple value edit.
            //e.value, .oldValue still = undefined if PASTE a single cell (not paste IN a cell), so can't just go by them only (Google bug #2).
            //TODO still leaves corner case that could undo partially through programmatic steps and then paste a single cell.

                var n_row1 = range.getRow();
                var n_col1 = range.getColumn();

            if (n_row1 == 1) {
                workingCell.setValue("...");

                var n_col; for (n_col = n_col1; n_col <= n_col1-1+numCols; n_col++) {
                    onEditObjectHeading(sheet, n_col)
                }

                workingCell.setValue("");
            } 
            if (n_row1 == 1 && numRows > 1 || n_row1 == 2) {
                workingCell.setValue("...");

                var n_col; for (n_col = n_col1; n_col <= n_col1-1+numCols; n_col++) {
                    onEditPropertyHeading(sheet, n_col);
                }

                workingCell.setValue("");
            }
        }
    }

}


function onEditObjectHeading(sheet, n_col) {
    
    var objectCell = sheet.getRange(1,n_col);
    var objectHeading = objectCell.getValue();
    var propertyCell = sheet.getRange(2,n_col);

    //Check dropdown in object cell
            var objectDropdown, objectDropdownRange, objectDropdownVals;
    var vl = objectCell.getDataValidation();
    if (vl) {
        if (vl.getCriteriaType() == SpreadsheetApp.DataValidationCriteria.VALUE_IN_RANGE) {
            //Assume dropdown is object dropdown
            objectDropdown = vl;
            [objectDropdownRange, objectDropdownVals] = unpackDropdown(objectDropdown);

            if (!(objectHeading == "" || objectDropdownVals.includes(objectHeading))) { //validation is case-sensitive
                //Dropdown present and heading not empty and invalid -> clear dropdown so don't get invalid warning
                objectCell.clearDataValidations();
            }
        }
    }
    else {
            [objectDropdown, objectDropdownRange, objectDropdownVals] = getObjectDropdown(objectCell, objectHeading, undefined, undefined, undefined, sheet);
            if (objectDropdown && (objectHeading == "" || objectDropdownVals.includes(objectHeading))) {
                //No validation (or dropdown) and heading empty or will be valid -> re-add object dropdown
                objectCell.setDataValidation(objectDropdown);
            }
    }
    
    //Check class name in object heading whether or not whole heading allows for dropdown
    var [className, objectDropdown, objectDropdownRange, objectDropdownVals] = getClassName(objectCell, objectHeading, objectDropdown, objectDropdownRange, objectDropdownVals, sheet);
    if (className) {
        //Class name found -> refresh object link, and property dropdowns/tips forward to next object heading
        refreshObjectLink(objectCell, objectHeading, className, objectDropdownRange, objectDropdownVals);
        refreshPropertyDropdownsForward(sheet, n_col, className);
    }
    else {
        clearLink(objectCell);
        //Don't clear property dropdowns/tips if no class name found
    }

}


function onEditPropertyHeading(sheet, n_col) {

    var propertyCell = sheet.getRange(2,n_col);
    var propertyHeading = propertyCell.getValue();
    
    var vl = propertyCell.getDataValidation();
    if (vl) {
        if (vl.getCriteriaType() == SpreadsheetApp.DataValidationCriteria.VALUE_IN_RANGE) {
            //Assume dropdown is property dropdown
            var propertyDropdown = vl;
            var [propertyDropdownRange, propertyDropdownVals] = unpackDropdown(propertyDropdown);

            //Check dropdown
            if (!(propertyHeading == "" || propertyDropdownVals.includes(propertyHeading))) { //not i cause validation is case-sensitive
                //Dropdown present and heading not empty and invalid -> clear dropdown so don't get invalid warning
                propertyCell.clearDataValidations();
            }

            //Check tip
            if (propertyHeading != "" && includesi(propertyDropdownVals, propertyHeading)) {
                //Heading not empty and in dropdown case-insens, whether or not dropdown still applied -> refresh tip
                refreshPropertyNote(propertyCell, propertyHeading, propertyDropdownRange, propertyDropdownVals);
            }
            else {
                //Don't know place in a dropdown -> clear any tip
                propertyCell.clearNote();
            }
        }
        else {
            //Some other kind of data validation
                //At least clear any tip
                propertyCell.clearNote();
        }
    }
    else {
        //Last object heading not empty up to col
        var i = sheet.getRange(1, 1, 1, n_col-1+1).getValues().flat().reverse().findIndex(v => v !== "");
        if (i != -1) {
            var n_objectCol = n_col-i;
            var objectCell = sheet.getRange(1,n_objectCol);
            var objectHeading = objectCell.getValue();
            var [className] = getClassName(objectCell, objectHeading, undefined, undefined, undefined, sheet);
            if (className) {
                //No dropdown and class name found directly above -> refresh property dropdown/tip
                refreshPropertyDropdown(propertyCell, propertyHeading, className);
            }
        }
    }

}




///////////////////////// ON EDIT MORE
function refreshObjectLink(cell, heading, className, dropdownRange, dropdownVals) {

    var n_linkRow = indexOfi(dropdownVals, className)+3;
    var n_linkCol = dropdownRange.getColumn()+1;
    var link = SpreadsheetApp.getActive().getSheetByName("MENUS").getRange(n_linkRow, n_linkCol).getValue();
    if (link) {
        var heading_link = SpreadsheetApp.newRichTextValue()
            .setText(heading)
            .setLinkUrl(link)
            .build();
        cell.setRichTextValue(heading_link);
    }
    else {
        //No link for this class -> clear any existing link
        clearLink(cell);
    }
    
}


function refreshPropertyDropdownsForward(sheet, n_col1, className) {
    
    var menusSheet = SpreadsheetApp.getActive().getSheetByName("MENUS");

    var numSheetCols = sheet.getMaxColumns();

    var classNames = menusSheet.getRange(2, 1, 1, menusSheet.getMaxColumns()).getValues().flat();
    var n_classCol = indexOfi(classNames, className)+1;
    var classColA = getColA(n_classCol, menusSheet);
    //Open range so if update menus sheet adds rows there dropdowns will be updated with new vals
    var dropdownRange = menusSheet.getRange(classColA+"3:"+classColA);
    var dropdownVals = dropdownRange.getValues().flat();
    var dropdown = SpreadsheetApp.newDataValidation()
        .requireValueInRange(dropdownRange)
        .build();

    //Add range = n_col1 to col before first object heading not empty after this column
    var i = sheet.getRange(1, n_col1+1, 1, numSheetCols-(n_col1+1)+1).getValues().flat().findIndex(v => v !== "");
    var n_col3;
    if (i != -1) {
        n_col3 = n_col1+1+i-1;
    }
    else {
        n_col3 = numSheetCols;
    }

    //Last property heading not empty in add range
    var i = sheet.getRange(2, n_col1, 1, n_col3-n_col1+1).getValues().flat().reverse().findIndex(v => v !== "");
    var n_col2;
    if (i != -1) {
        n_col2 = n_col3-i
    }
    else {
        n_col2 = n_col1-1;
    }

    //Up to last property heading not empty in add range
    var n_col; for (n_col = n_col1; n_col <= n_col2; n_col++) {
        var cell = sheet.getRange(2, n_col);
        var heading = cell.getValue();

        //Check property dropdown
        if (dropdownVals.includes(heading)) { //not i cause validation is case-sensitive
            //Heading empty or will be valid -> refresh dropdown
            cell.setDataValidation(dropdown);
        }
        else {
            //Heading not empty and invalid -> clear any dropdown so don't get invalid warning
            cell.clearDataValidations();
        }

        //Check tip
        if (includesi(dropdownVals, heading)) {
            //Heading not empty and in dropdown case-insens, whether or not dropdown still applied -> refresh tip
            refreshPropertyNote(cell, heading, dropdownRange, dropdownVals);
        }
        else {
            //Don't know place in a dropdown -> clear any tip
            cell.clearNote();
        }
    }

    //Remaining property heading cells in add range, all empty
    if (n_col3 > n_col2) {
        var range = sheet.getRange(2, n_col2+1, 1, n_col3-(n_col2+1)+1);
        range.setDataValidation(dropdown);
        range.clearNote();
    }

}


function refreshPropertyDropdown(cell, heading, className) {
    
    var menusSheet = SpreadsheetApp.getActive().getSheetByName("MENUS");

    var classNames = menusSheet.getRange(2, 1, 1, menusSheet.getMaxColumns()).getValues().flat();
    var n_classCol = indexOfi(classNames, className)+1;
    var classColA = getColA(n_classCol, menusSheet);
    //Open range so if update menus sheet adds rows there dropdowns will be updated with new vals
    var dropdownRange = menusSheet.getRange(classColA+"3:"+classColA);
    var dropdownVals = dropdownRange.getValues().flat();

    //Check dropdown
    if (heading == "" || dropdownVals.includes(heading)) { //not i cause validation is case-sensitive
        //Heading empty or will be valid -> refresh dropdown
        var dropdown = SpreadsheetApp.newDataValidation()
            .requireValueInRange(dropdownRange)
            .build();
        cell.setDataValidation(dropdown);
    }
    else {
        //Heading not empty and invalid -> clear any dropdown so don't get invalid warning
        cell.clearDataValidations();
    }

    //Check tip
    if (heading != "" && includesi(dropdownVals, heading)) {
        //Heading not empty and in dropdown case-insens, whether or not dropdown still applied -> refresh tip
        refreshPropertyNote(cell, heading, dropdownRange, dropdownVals);
    }
    else {
        //Don't know place in a dropdown -> clear any tip
        cell.clearNote();
    }

}


function refreshPropertyNote(cell, heading, dropdownRange, dropdownVals) {

    /*if (heading == "") {
            cell.setNote("Copy & paste this property menu into as many other columns as you need. When you select a heading in it, you can hover over it to see a quick doc. You can also type over any menu to make a custom heading.");
    }
    else {*/
        var n_tipRow = indexOfi(dropdownVals, heading)+3;
        var n_tipCol = dropdownRange.getColumn()+1;
        var tip = SpreadsheetApp.getActive().getSheetByName("MENUS").getRange(n_tipRow, n_tipCol).getValue();
        if (tip) {
            cell.setNote(tip);
        }
        else {
            //No tip for this property -> clear any existing tip
            cell.clearNote();
        }
    //}
    
}




///////////////////////// ON EDIT GENERAL
function getClassName(cell, heading, dropdown, dropdownRange, dropdownVals, sheet) {
    
    //OUTPUT
    //If className found, as much dropdown as possible also returned.
    //dropdown stuff maybe passed through only if className not found.


                var className = null;
    if (heading != "") {
        [dropdown, dropdownRange, dropdownVals] = getObjectDropdown(cell, heading, dropdown, dropdownRange, dropdownVals, sheet);
        if (dropdown) {
            var x = heading.split(/\s+/)[0];
            var i = indexOfi(dropdownVals, x);
            if (i != -1) {
                //Case-insens but return correct case, not nec case in heading
                className = dropdownVals[i];
            }
        }
    }
    
    return [className, dropdown, dropdownRange, dropdownVals];
    
}


function getObjectDropdown(cell, heading, dropdown, dropdownRange, dropdownVals, sheet) {

    //INPUTS dropdown, dropdownRange, dropdownVals:
    //- all
    //- none

        
        if (dropdown) {
            //Pass through
            return [dropdown, dropdownRange, dropdownVals];
        }

        var vl = cell.getDataValidation();
        if (vl && vl.getCriteriaType() == SpreadsheetApp.DataValidationCriteria.VALUE_IN_RANGE) {
            //From cell.
            //Assume dropdown is object dropdown.
            dropdown = vl;
            [dropdownRange, dropdownVals] = unpackDropdown(dropdown);
            return [dropdown, dropdownRange, dropdownVals];
        }
        
        var vll = sheet.getRange(1, 1, 1, sheet.getMaxColumns()).getDataValidations()[0];
        var i = vll.findIndex(vl => vl && vl.getCriteriaType() == SpreadsheetApp.DataValidationCriteria.VALUE_IN_RANGE);
        if (i != -1) {
            //From first dropdown in row 1.
            //Prioritize consistency of dropdowns across row.
            //Assume dropdown is object dropdown.
            dropdown = vll[i];
            [dropdownRange, dropdownVals] = unpackDropdown(dropdown);
            return [dropdown, dropdownRange, dropdownVals];
        }

    if (heading != "") {
            var menusSheet = SpreadsheetApp.getActive().getSheetByName("MENUS");

            //Open range so if update menus sheet adds rows there then dropdowns will be updated with new vals
            var r = menusSheet.getRange("C3:C");
            var vv = r.getValues().flat();
            var className = heading.split(/\s+/)[0];
        if (includesi(vv, heading) || includesi(vv, className)) { //don't call getClassName cause it calls this
            //From menus sheet--other based on class name
            dropdownRange = r;
            dropdownVals = vv;
            dropdown = SpreadsheetApp.newDataValidation()
                .requireValueInRange(dropdownRange)
                .build();
            return [dropdown, dropdownRange, dropdownVals];
        }

            r = menusSheet.getRange("A3:A");
            vv = r.getValues().flat();
            className = heading.split(/\s+/)[0];
        if (includesi(vv, heading) || includesi(vv, className)) {
            //From menus sheet--trial based on class name
            dropdownRange = r;
            dropdownVals = vv;
            dropdown = SpreadsheetApp.newDataValidation()
                .requireValueInRange(dropdownRange)
                .build();
            return [dropdown, dropdownRange, dropdownVals];
        }
    }

            dropdown = undefined;
            dropdownRange = undefined;
            dropdownVals = undefined;
            return [dropdown, dropdownRange, dropdownVals];
    
}




////////////////////////////////////////////////// ON OPEN
/*
function onOpen(e) {

    var spreadsheet = e.source;

    //Add PsychBench menu
    var menuItems = [];
    menuItems.push({name: "Check for update to heading menus", functionName: "updateMenus"});
    spreadsheet.addMenu("PsychBench", menuItems);

}
*/


function onOpen(e) {

    SpreadsheetApp.getActive().getSheetByName("MENUS").getRange(1, 2).setValue("");

}


function updateMenus() {

    //Get menu data from cloud
    var csvUrl = "https://storage.googleapis.com/psychbench/menus.csv";    
    //THIS IS THE LINE THAT GENERATES SECURITY REQUIREMENTS
    var response = UrlFetchApp.fetch(csvUrl);
    var csvData = response.getContentText();
    var data = Utilities.parseCsv(csvData);
    var numDataRows = data.length;
    var numDataCols = data[0].length;

    var sheet = SpreadsheetApp.getActive().getSheetByName("MENUS");
    var currentDate = sheet.getRange(1, 2).getValue();
    var newDate = data[0][1];
    if (newDate > currentDate) {
        //Clear and set menu data
        var numSheetRows = sheet.getMaxRows();
        var numSheetCols = sheet.getMaxColumns();
        if (numSheetRows < numDataRows) {
            sheet.insertRowsAfter(numSheetRows, numDataRows-numSheetRows);
            }
        else if (numSheetRows > numDataRows) {
            sheet.deleteRows(numDataRows+1, numSheetRows-numDataRows);
        }
        if (numSheetCols < numDataCols) {
            sheet.insertColumnsAfter(numSheetCols, numDataCols-numSheetCols);
            }
        else if (numSheetCols > numDataCols) {
            sheet.deleteColumns(numDataCols+1, numSheetCols-numDataCols);
        }
        sheet.clear();
        sheet.getRange(1, 1, numDataRows, numDataCols).setValues(data);
    }

}




//////////////////////////////////////////////////////////////////////////////////////////////////// GENERAL
function includesi(array, val) {

    return array.map(x => x.toLowerCase()).includes(val.toLowerCase());

}


function indexOfi(array, val) {

    return array.map(x => x.toLowerCase()).indexOf(val.toLowerCase());

}


function clearLink(cell) {

    //Fix Google bug that doesn't clear link style if delete value, only if type over value
    cell.setFontColor(SpreadsheetApp.ThemeColorType.TEXT);
    cell.setFontLine("none");

}


function unpackDropdown(dropdown) {

    var dropdownRange = dropdown.getCriteriaValues()[0];
    var dropdownVals = dropdownRange.getValues().flat();

    return [dropdownRange, dropdownVals];

}


function getColA(n_col, sheet) {

    var cell = sheet.getRange(1, n_col);
    var cellA1 = cell.getA1Notation();
    var colA = cellA1.slice(0, -1);
    return colA;

}