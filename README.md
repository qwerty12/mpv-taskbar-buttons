Hack to add media control taskbar buttons (well, thumbbar buttons) for mpv:

![Screenshot of the usual Windows taskbar preview but with media control buttons (yes, I miss the 90s)](https://github.com/qwerty12/mpv-taskbar-buttons/blob/preview/screenshot.png)

## Requirements

* Windows 7 or later (although it's only been tested on Windows 11)

* 64-bit mpv. This will not work with 32-bit mpv without changes I am not willing to make, this script is already long enough

* mpv that uses LuaJIT. You can safely assume this to be the case; it is 99% likely you're using an mpv [build by shinchiro](https://github.com/shinchiro/mpv-winbuild-cmake) (or one derived from his), which use LuaJIT and nothing else.

## Installation

To install this, just run `git clone https://github.com/qwerty12/mpv-taskbar-buttons` in your mpv scripts folder. If you downloaded the zipped version of this repo instead, just copy the mpv-taskbar-buttons(-master) folder as-is into your mpv scripts folder.  
The files **must** be in a subfolder of your mpv scripts folder for this script to load. To remove this script, just delete the folder. It does not make any changes to your system elsewhere.

If your needs are simple and you just need mpv to run a command (or many, separated by `;`), then you can create a [`mpv-taskbar-buttons.conf`](https://github.com/qwerty12/mpv-taskbar-buttons/blob/master/script-opts/mpv-taskbar-buttons.conf) file in your script-opts folder and set `prev_command`, `play_pause_command` and `next_command` as needed. You might want to do this to call uosc's functions, [for example](https://github.com/qwerty12/mpv-taskbar-buttons/issues/3). For anything more advanced, look at the `callbacks` table in hook.lua and edit the Lua functions as desired.

I will ignore requests to add extra buttons. If, however, you have code to perform a custom action already written but are unsure on how to add a button to your own copy of this script to call it, make an issue and I will help. Windows allows up to seven buttons.

## Known issues

* If you edit the playlist and the current file suddenly becomes the first or last (or in the middle if it wasn't before), the buttons probably won't reflect that. Should be fixable, I'm too lazy to do it as I don't edit playlists. If you find the auto-disabling behaviour annoying, it can be disabled by setting the script-opt `never_disable_buttons=yes`

* Again, this is a hack. It relies on assumptions that, unlikely as it is, may not hold true in the future. If you suddenly start noticing mpv crashing where it wouldn't before, the first thing to try is probably deleting this script

## Is this a virus? Actually, why do you even need a DLL file?

I'll forgo the usual cries of "it's open source" and simply mention I'm not stupid enough to stick my actual name on something I would know to have a virus in that scenario.

The way Windows lets applications know a thumbbar button has been hit is by posting a message to a window, mpv's in this case. As this is an external script and does not have direct control over the mpv function handling the message loop, it must use a [facility provided by Windows to intercept the message loop](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw). You can't pass said WinAPI function a Lua function and expect Windows to know what to do with it.  
LuaJIT does provide an interoperability mechanism for this, but the problem is, to quote the [LuaJIT manual](https://luajit.org/ext_ffi_semantics.html#callback), "[LuaJIT] callbacks are slow!". They actually work pretty great 99.9% of the time, but when trying one for this I noticed that very rapid mouse movements would cause mpv to crash, as the hook function couldn't handle the high amount of messages to process. There's also the issue of thread-safety: Windows runs the hook function on the same thread mpv's message loop is running on, while mpv runs Lua scripts in their own threads. Going with something compiled was going to be the way to go.

I didn't want to provide a pre-compiled DLL because I wanted to keep the C part as easily editable as the Lua code, hence using TCC to build the C code on-the-fly. The downside to that decision is that TCC is more fast at compiling instead of trying to be a compiler that studiously tries to produce fast code, so a lot (but not all!) of the optimisations GCC etc. would make when building a DLL aren't there. Still, we're only talking about one pretty-short function, and the TCC-compiled callback is still undoubtedly faster and safer than the one written in Lua.

If you wish to make sure the included libtcc.dll is unmodified, then replace it with the one in tcc-0.9.27-win64-bin.zip from https://download.savannah.gnu.org/releases/tinycc/ 

If you want to try a version written in nothing but Lua(JIT) - with the caveat it will crash when trying to handle a large number of messages -  check out the `pure-luajit` branch of this repo. It's there for curiosity's sake and I don't recommend using it; I will not update it or provide support.

## Credits

https://github.com/duncanc/ljf-com - for the great COM binding in ljf-com, which just happened to have a definition for the very interface I needed to use

https://github.com/reupen/columns_ui - for the taskbar icons in res, which are just straight-up lifted from the excellent Columns UI for foobar2000

All rights reserved to the original authors of the third-party resources included in this repo.

## SMTC

This is not the same thing as Windows 8+ System Media Transport Controls integration. Check out one of the following for that:

https://github.com/datasone/MPVMediaControl

https://github.com/x0wllaar/MPV-SMTC

Combine one of the above with https://github.com/krlvm/MediaFlyout and you've got yourself an alternative to this, actually.