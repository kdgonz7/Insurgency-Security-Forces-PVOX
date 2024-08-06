if ! PVox then return Derma_Message( "PVOX Is not installed!", "Error", "OK" ) end

local AmmoBlackList = {
    [10] = true,
    [-1] = true,
}

if SERVER then
    util.AddNetworkString("INS2_PV_LowAmmoCallout")

    net.Receive("INS2_PV_LowAmmoCallout", function(len, ply)
        local pr = ply:GetNWString("vox_preset", "none")
        if pr == "none" then return end

        local m = PVox.Modules[pr]
        if ! m then return end

        m:EmitAction(ply, "ammo_low")
    end)
end

if CLIENT then
    local DoLowCallout = CreateConVar("pvox_ins2_yellwhenlow", 1, FCVAR_ARCHIVE)
    local AmmoThresh = CreateConVar("pvox_ins2_ammothresh", 1, FCVAR_ARCHIVE)  

    hook.Add("KeyPress", "INS2_PV_EnsureAmmo", function(ply, key)
        if ! ply:IsValid()      then return end
        if ! DoLowCallout:GetBool() then return end

        local ac = ply:GetActiveWeapon()
        if ! IsValid(ac) then return end
        local pt = ac:GetPrimaryAmmoType()

        if AmmoBlackList[pt]    then return end

        if key == IN_RELOAD and ply:GetAmmoCount(pt) == 0 then
            net.Start("INS2_PV_LowAmmoCallout")
            net.SendToServer()
        end

        timer.Simple(0.1, function()
            if ! IsValid(ply) then return end
            ac = ply:GetActiveWeapon()

            if ! IsValid(ac) then return end
            local new = ac:Clip1()

            if (new <= AmmoThresh:GetInt()) then
                net.Start("INS2_PV_LowAmmoCallout")
                net.SendToServer()
            end
        end)
    end)
end

PVox:ImplementModule("ins2-security", function(_) return true end)
