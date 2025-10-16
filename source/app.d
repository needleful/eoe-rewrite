import std.stdio;

import np.dialog;
import np.dialog.conditions;

void main()
{

	DialogSequence nd;

	nd.items = [
		1: DialogItem.message("This is the test dialog!"),
		2: DialogItem.narration("It sucks."),
		3: DialogItem.branch((auto c) => Result.of(c.talked == 0)),
		4: DialogItem.message("We've never met before.", "You"),
		5: DialogItem.branch((auto c) => Result.of(c.otherwise)),
		6: DialogItem.message("I hate seeing you again", "You")
	];
	nd.items[1].next = 2;
	nd.items[2].next = 3;
	nd.items[3].withNeighbors(5, 4);
	nd.items[4].parent = 5;
	nd.items[5].child = 6;
	nd.items[6].parent = 5;


	writeln("Press ENTER to advance dialog");

	DialogEvaluator eval;
	eval.context.talked = 0;
	eval.start(&nd);
	DialogItem* currentItem = &nd.items[1];

	while(!eval.done()) {
		DialogItem* c = eval.currentItem;
		writefln("%s - %s", c.speaker || "Default", c.text);
		string s;
		readf("%s\n", &s);
		eval.advance();
	}
	writeln("--- FIN ---");
}
