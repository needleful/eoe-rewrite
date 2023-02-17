import std.stdio;

import lantana.input;
import lantana.render;

void main()
{
	Input input;
	Window window = Window(640, 480, "At the Ends of Eras");
	window.grabMouse(false);

	writeln("At the Ends of Eras");

	while(!window.state[WindowState.CLOSED]) {
		window.pollEvents(&input);
		window.beginFrame();
		window.endFrame();
	}
	writeln("Exiting...");
}
