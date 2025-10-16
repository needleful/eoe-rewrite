import std.stdio;

import lantana;

enum MAX_MEMORY = 1024*1024*64;

struct triangle {
	static immutable vec3[3] verts = [
		vec3(-1,-1, 0),
		vec3(1, -1, 0),
		vec3(0, 1, 0)
	];
	static immutable Color[3] colors = [
		Color(255, 0, 0),
		Color(0, 255, 0),
		Color(0, 0, 255)
	];

	static immutable uint[3] indeces = [0, 1, 2];
}

struct gbuffers {
	Color gAlbedo;
}

void main()
{
	Input input;
	Window window = Window(640, 480, "At the Ends of Eras");
	window.grabMouse(false);

	Mesh triMesh = Mesh.fromDict({
		"position": triangle.verts,
		"color": triangle.colors,
		"indeces": triangle.indeces
	});

	DeferredRenderer renderer = DeferredRenderer!gbuffers(window.getSize());
	WorldMaterial defaultMat = renderer.createMaterial("Default", "data/shaders/static.vert", "data/shaders/flat.frag");

	MeshRender triRender = renderer.createRender(triMesh, defaultMat);

	LightRender light = renderer.createLight();

	while(!window.state[WindowState.CLOSED]) {
		window.pollEvents(&input);

		window.beginFrame();

		renderer.renderMeshes(defaultMat);
		renderer.renderLight(light);

		window.endFrame();
	}
	writeln("Exiting...");
}
