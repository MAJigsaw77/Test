package;

import android.content.Context;
import android.widget.Toast;
import hxlua.Lua;
import hxlua.LuaL;
import hxlua.Types;
import lime.app.Application;
import lime.graphics.RenderContext;

class Main extends Application
{
	public function new()
	{
		super();

		// create the new state
		var vm:cpp.RawPointer<Lua_State> = LuaL.newstate();

		// open the libs
		LuaL.openlibs(vm);

		// do the file
		var ret:Int = LuaL.dofile(vm, Context.getExternalFilesDir(null) + "/script.lua");

		// check if isn't ok
		if (ret != Lua.OK)
		{
			Application.current.window.alert(Lua.tostring(vm, ret), "Lua Script Error!");
			Lua.pop(vm, 1);
		}

		// call 'foo' function
		Lua.getglobal(vm, "foo");
		Lua.pushinteger(vm, 1);
		Lua.pushnumber(vm, 2.0);
		Lua.pushstring(vm, "three");
		Lua.pcall(vm, 3, 0, 1);

		// close the state after pcall
		Lua.close(vm);
		vm = null;

		Toast.makeText('Script Executed!', Toast.LENGTH_LONG);
	}

	public override function render(context:RenderContext):Void
	{
		switch (context.type)
		{
			case CAIRO:
				var cairo = context.cairo;
				cairo.setSourceRGB(0.75, 1, 0);
				cairo.paint();
			case CANVAS:
				var ctx = context.canvas2D;
				ctx.fillStyle = "#BFFF00";
				ctx.fillRect(0, 0, window.width, window.height);
			case DOM:
				var element = context.dom;
				element.style.backgroundColor = "#BFFF00";
			case FLASH:
				var sprite = context.flash;
				sprite.graphics.beginFill(0xBFFF00);
				sprite.graphics.drawRect(0, 0, window.width, window.height);
			case OPENGL, OPENGLES, WEBGL:
				var gl = context.webgl;
				gl.clearColor(0.75, 1, 0, 1);
				gl.clear(gl.COLOR_BUFFER_BIT);
			default:
		}
	}
}
