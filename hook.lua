-- can't use get_script_directory because this comes into existence through load-script
local script_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") -- https://stackoverflow.com/a/23535333
package.path = script_dir .. "\\?.lua;" .. package.path

local ffi = require("ffi")
local common = require("common")
local C = ffi.C
local band = require("bit").band

ffi.cdef [[
    typedef struct tagMSG {
        void *hwnd;
        unsigned int message;
        unsigned __int64 wParam;
        __int64 lParam;
        unsigned long time;
        long pt[2];
    } MSG, *LPMSG;

    typedef __int64 (__stdcall *HOOKPROC)(int code, unsigned __int64 wParam, __int64 lParam);
    void* __stdcall SetWindowsHookExW(int idHook, HOOKPROC lpfn, void *hmod, unsigned long dwThreadId);
    __int64 __stdcall CallNextHookEx(void *hhk, int nCode, unsigned __int64 wParam, __int64 lParam);
    bool __stdcall UnhookWindowsHookEx(void *hhk);
]]
local WH_GETMESSAGE = 3

local callbacks = {
    [common.button_ids[C.BUTTON_PREV]] = function() mp.command("playlist-prev") end,
    [common.button_ids[C.BUTTON_PLAY_PAUSE]] = function() mp.commandv("cycle", "pause") end,
    [common.button_ids[C.BUTTON_NEXT]] = function() mp.command("playlist-next") end
}

local mpv_hwnd, mpv_tid = common.get_mpv_hwnd()
local hHook = nil
local hookfn = ffi.cast("HOOKPROC", function(code, wParam, lParam)
    if code >= 0 then -- HC_ACTION
        local cwpret = ffi.cast("LPMSG", lParam)
        if cwpret.message == 0x0111 and cwpret.hwnd == mpv_hwnd then -- WM_COMMAND
            local wmId = tonumber(band(cwpret.wParam, 0xffff)) -- LOWORD
            if callbacks[wmId] then
                callbacks[wmId]()
                cwpret.message = 0x0000 -- WM_NULL
                return 0
            end
        end
    end

    return C.CallNextHookEx(hHook, code, wParam, lParam)
end)

local function start()
    mp.unregister_idle(start)
    hHook = C.SetWindowsHookExW(WH_GETMESSAGE, hookfn, nil, mpv_tid)
    if hHook == nil then return end
    mp.register_event("shutdown", function()
        if hHook ~= nil then
            C.UnhookWindowsHookEx(hHook)
            hHook = nil
        end
        -- if hookfn ~= nil then -- unlikely, but the hook might still be running
        --     hookfn:free()
        --     hookfn = nil
        -- end
    end)
end

if mpv_tid ~= 0 then mp.register_idle(start) end
