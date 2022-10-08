local ffi = require("ffi")

ffi.cdef [[
    void* __stdcall FindWindowExA(void *hWndParent, void *hWndChildAfter, const char *lpszClass, const char *lpszWindow);
    unsigned int __stdcall GetWindowThreadProcessId(void *hWnd, unsigned int *lpdwProcessId);

    enum {
        BUTTON_FIRST,
        BUTTON_PREV = BUTTON_FIRST,
        BUTTON_PLAY_PAUSE,
        BUTTON_NEXT,
        BUTTON_LAST // note: Windows imposes a limit of seven buttons.
    };
]]

local common = {
    button_ids = {}
}
for i = ffi.C.BUTTON_FIRST, ffi.C.BUTTON_LAST - 1 do
    common.button_ids[i] = 0x0400 + i
end

function common.get_mpv_hwnd()
    local our_pid = mp.get_property_number("pid")
    local hwnd_pid = ffi.new("unsigned int[1]")
    local hwnd = nil

    repeat
        hwnd = ffi.C.FindWindowExA(nil, hwnd, "mpv", nil)
        if hwnd ~= nil then
            local thread_id = ffi.C.GetWindowThreadProcessId(hwnd, hwnd_pid)
            if hwnd_pid[0] == our_pid then
                return hwnd, thread_id
            end
        else
            return nil, 0
        end
    until false
end

return common
