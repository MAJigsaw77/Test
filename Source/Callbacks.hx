package;

import hxlua.Lua;
import hxlua.Types;

class Callbacks
{
	private static var callbacks:Map<String, Dynamic> = [];

	public static function add(L:cpp.RawPointer<Lua_State>, name:String, callback:Dynamic):Void
	{
		if (callbacks.exists(name) || !Reflect.isFunction(callback))
			return;

		callbacks.set(name, callback);

		Lua.pushstring(L, name);
		Lua.pushcclosure(L, cpp.Callable.fromStaticFunction(callbackHandler), 1);
		Lua.setglobal(L, name);
	}

	public static inline function remove(L:cpp.RawPointer<Lua_State>, name:String):Void
	{
		if (!callbacks.exists(name))
			return;

		callbacks.remove(name);

		Lua.pushnil(L);
		Lua.setglobal(L, name);
	}

	private static function callbackHandler(L:cpp.RawPointer<Lua_State>):Int
	{
		var name:String = Lua.tostring(L, Lua.upvalueindex(1));

		if (!callbacks.exists(name) || callbacks.get(name) == null)
			return 0;

		var args:Array<Dynamic> = [];

		for (i in 0...Lua.gettop(L))
			args[i] = Convert.fromLua(L, i + 1);

		var ret:Dynamic = Reflect.callMethod(null, callbacks.get(name), args);

		if (ret != null)
		{
			Convert.toLua(l, ret);
			return 1;
		}

		return 0;
	}
}
