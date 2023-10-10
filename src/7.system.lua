local system

function system_init()
    system = {
        settings = {
            colorblind = "off" --off, on
        },
        toggle_colorblind_mode = function(self)
            if (self.settings.colorblind == "off") then
                self.settings.colorblind = "on"
            else
                self.settings.colorblind = "off"
            end
        end
    }
    function menuitem_colorblind(b)
        if (b&112 > 0) then
            system:toggle_colorblind_mode()
            menuitem(_, "colorblind: "..system.settings.colorblind)
        end
        return true -- stay open
    end
    function clear_save()
        dset(0, 0)
    end
    menuitem(1, "colorblind: "..system.settings.colorblind, menuitem_colorblind)
    menuitem(2, "clear save", clear_save)
end

function adjust_for_colorblindness()
    if (system.settings.colorblind == "off") then
        pal()
    elseif (system.settings.colorblind == "on") then
        pal({[3]=13, [8]=9, [9]=6, [10]=15, [11]=12, [13]=5, [14]=15}, 0)
    end
    map()
end
