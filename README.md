Hack to add taskbar buttons (well, thumbbar buttons) to mpv (slow, **UNSTABLE**, *unsupported*, pure LuaJIT version)

Obviously you need Windows (7+) - 64-bit at that. This also requires your mpv to be built against LuaJIT. This is something you can safely assume to be the case; it is 99% likely you're using a build by shinchiro (or one derived from his), which use nothing but LuaJIT.

Again, this is a hack. If you suddenly start noticing mpv crashing where it wouldn't before - and with this pure LuaJIT version you will - the first thing to try is using the TCC-callback-based version from the `master` branch.

If you want to add more buttons - Windows allows up to seven - you'll need to do it yourself.

## Known issues

* If you edit the playlist and the current file suddenly becomes the first or last (or in the middle if it wasn't before), the buttons probably won't reflect that. Easily fixable, but I'm too lazy to do it given I don't edit playlists

* To quote the [LuaJIT manual](https://luajit.org/ext_ffi_semantics.html#callback):

> **Callbacks are slow!**

This is important to know because a time-critical function is handled by one of said callbacks.

## Credits

https://github.com/duncanc/ljf-com - for the great COM binding in ljf-com, which just happened to have a definition for the very interface I needed to use

https://github.com/reupen/columns_ui - for the taskbar icons in res, which are just straight-up lifted from the excellent Columns UI for foobar2000

## SMTC

This is not the same thing as Windows 8+ System Media Transport Controls integration. Check out one of the following for that:

https://github.com/datasone/MPVMediaControl

https://github.com/x0wllaar/MPV-SMTC