positions <- [];
spawners <- [];
displayIndex <- 0;
hasBeenCleared <- true;


function initArrays() {
	spawners <- [
		Entities.FindByName(null, "numb_spawner_0"),
		Entities.FindByName(null, "numb_spawner_1"),
		Entities.FindByName(null, "numb_spawner_2"),
		Entities.FindByName(null, "numb_spawner_3"),
		Entities.FindByName(null, "numb_spawner_4"),
		Entities.FindByName(null, "numb_spawner_5"),
		Entities.FindByName(null, "numb_spawner_6"),
		Entities.FindByName(null, "numb_spawner_7"),
		Entities.FindByName(null, "numb_spawner_8"),
		Entities.FindByName(null, "numb_spawner_9")
	];
	positions <- [
		Vector(-1900.0, -1800.0, 1000.0),
		Vector(-1900.0, -1600.0, 1000.0),
		Vector(-1900.0, -1400.0, 1000.0),
		Vector(-1900.0, -1200.0, 1000.0)
	];
	displayIndex <- 0;
	hasBeenCleared <- true;

}

function setNumberAtPos(number, pos) {
	if ( typeof number == "string" ) number = number.tointeger();
	printl("Spawning " + number + " at pos " + pos );
	spawners[number].SpawnEntityAtLocation(positions[pos], Vector(1.0, 0.00, 0.0) );
	displayIndex++;
}

function clearDisplay() {
	printl("clearing display");
	for ( local i = 0; i < 4; i++ ) {
		handle <- Entities.FindByClassnameNearest("func_brush", positions[i], 100.0);
		EntFireByHandle( handle, "kill", "", 0.0, null, null );
	}
	displayIndex <- 0;
}

expression <- []

function pressed(button) {
	if (! hasBeenCleared ) {
		killDisplay();
		hasBeenCleared <- true;
	}
	if ( button == "c" ) {
		clearDisplay();
		hasBeenCleared <- true;
		expression <- [];
	} else if ( button == "=") {
		clearDisplay();
		newCalc();
	} else {
		expression.append(button);
		if (! contains( button, ["*", "+", "-"] ) ) {
			setNumberAtPos( button, displayIndex );
		} else {
			clearDisplay();
		}
	}
}


function newCalc() {
	local result = "";
	local index = 0;
	local num = 0;
	local size = 0;
	local stringExpression = []
	local numberExpression = []
	local coun = 0;
	local operations = ["*", "-", "+"]
	local i = null;

	// find all numbers
	foreach (char in expression) {
		char = char.tostring();
		// if its an operator just add it
		if ( contains( char, operations ) ) {
			stringExpression.append( char );
		} else {
			try {
				if ( contains( stringExpression[size], operations ) ) {
					result = stringExpression[size] + char.tostring();
					stringExpression.remove(size);
					stringExpression.append(result);
				} else {
					stringExpression.append( char.tostring() );
				}
			} catch (e) {
				stringExpression.append( char.tostring() );
			}
		}
	}
	// convert numbers to actual number objects
	foreach (i in stringExpression) {
		if ( contains(i, operations) ) {
			// its an operator, just add it
			numberExpression.append( i );
		} else {
			// its a number, convert and add
			numberExpression.append( i.tointeger() );
		}
	}
	// do operations
	// multiplication
	coun = count( "*", numberExpression );
	for (local i = 0; i < coun; i++) {
		index = find( "*", numberExpression );
		// do operation
		num = numberExpression[index - 1];
		num = num * numberExpression[index + 1];
		// remove non-result values
		numberExpression[index - 1] = num;
		numberExpression.remove( index );
		numberExpression.remove( index );
	}
	// addition
	coun = count( "+", numberExpression );
	for (local i = 0; i < coun; i++) {
		index = find( "+", numberExpression );
		// do operation
		num = numberExpression[index - 1];
		num = num + numberExpression[index + 1];
		// remove non-result values
		numberExpression[index - 1] = num;
		numberExpression.remove( index );
		numberExpression.remove( index );
	}
	// subtraction
	coun = count( "-", numberExpression );
	for (local i = 0; i < coun; i++) {
		index = find( "-", numberExpression );
		// do operation
		num = numberExpression[index - 1];
		num = num - numberExpression[index + 1];
		// remove non-result values
		numberExpression[index - 1] = num;
		numberExpression.remove( index );
		numberExpression.remove( index );
	}

	// add up the results
	result = "";
	foreach (i in numberExpression) {
		result = result + i.tostring();
	}
	// display the result
	clearDisplay();
	printl("The result is " + result);
	foreach( chr in result.tostring() ) {
		setNumberAtPos( chr.tochar(), displayIndex );
	}
	expression <- [];
}

function contains(char, array) {
	foreach (c in array) {
		if ( char == c.tostring() ) return true;
	}
	return false;
}

function count(char, array) {
	local i = 0
	foreach (c in array) {
		if ( c.tostring() == char ) i++;
	}
	return i;
}

function find(char, array) {
	for (local i = 0; i < array.len(); i++) {
		if ( array[i].tostring() == char ) return i;
	}
	return -1;
}

function dump() {
	printl( displayHandles.tostring() );
	printl( positions.tostring() );
	printl( spawners.tostring() );
	printl( numbers.tostring() );
	printl( index );
	printl( prevResult );
}

/* WHAT IT NEED TO DO

string -> numbers, operators -> cycle -> dosum/mul/sub -> display result

*/