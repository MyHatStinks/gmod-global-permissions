-------------------------------------------
------------ Global Permissions -----------
-------------------------------------------
-- sh_permissions.lua             SHARED --
--                                       --
-- Set up permissions for multiple Gmod  --
-- moderation systems.                   --
-------------------------------------------

-- Get the most up-to-date version from GitHub:
-- https://github.com/MyHatStinks/gmod-global-permissions


------------------------
-- Set up permissions --
------------------------

-- Use the hook to make sure everything is already set up
hook.Add( "Permission.OnLoad", "GlobalPermissions Example", function()
	-- Set up a superadmin permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_SuperAdmin", GlobalPermissions.GROUP_SUPERADMIN, "Treat user as a superadmin!", "GlobalPermissions" )
	
	-- Set up an admin permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_Admin", GlobalPermissions.GROUP_ADMIN, "Treat user as an admin!", "GlobalPermissions" )
	
	-- Set up a user permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_User", GlobalPermissions.GROUP_ALL, "Treat user a user!", "GlobalPermissions" )
end)

-----------------------
-- Check Permissions --
-----------------------

if SERVER then -- Permissions can also be checked client-side
	hook.Add("PlayerSay", "GlobalPermissions CheckPermissions Example", function( p, txt, tm )
		if not IsValid(p) then return end
		if txt~="!checkpermissions" then return end
		
		local hasPrinted = false
		if GlobalPermissions.HasPermission( p, "GlobalPermissions_SuperAdmin", false ) then
			p:ChatPrint("You are considered a superadmin!")
			hasPrinted = true
		end
		if GlobalPermissions.HasPermission( p, "GlobalPermissions_Admin", false ) then
			if hasPrinted then
				p:ChatPrint("You are also considered an admin!")
			else
				p:ChatPrint("You are considered an admin!")
			end
			hasPrinted = true
		end
		if GlobalPermissions.HasPermission( p, "GlobalPermissions_User", false ) then
			if hasPrinted then
				p:ChatPrint("You are also considered a user!")
			else
				p:ChatPrint("You are considered a user!")
			end
			hasPrinted = true
		end
		
		if not hasPrinted then
			p:ChatPrint("You have no permissions!")
		end
		
		return ""
	end)
end



---------- You shouldn't need to edit below this line ----------


-- This number will be incremented when a new permissions system is added
-- Should help keep compatibility with other addons using this code
-- Format YYYYMMDD.revision
local version = 20201123.0
if GlobalPermissions and GlobalPermissions.Version>=version then return end -- Only overwrite if this is newer

GlobalPermissions = GlobalPermissions or {}
GlobalPermissions.Version = version

-- Permission groups
GlobalPermissions.GROUP_SUPERADMIN = 0
GlobalPermissions.GROUP_ADMIN      = 1
GlobalPermissions.GROUP_ALL        = 2

------------------------
-- Set up permissions --
------------------------

function GlobalPermissions.SetupPermission( Permission, DefaultGroup, Help, Cat )
	hook.Run( "Permission.SetUp", Permission, DefaultGroup, Help, Cat )
	
	-- ULX
	if ULib and ULib.ucl then
		if ULib.ucl.registerAccess then
			local grp = GlobalPermissions.GetULXPermissionGroup(DefaultGroup) or ULib.ACCESS_SUPERADMIN
			
			return ULib.ucl.registerAccess( Permission, grp, Help, Cat )
		end
	end
	-- Evolve
	if evolve and evolve.privileges then
		table.Add( evolve.privileges, {Permission} )
		table.sort( evolve.privileges )
		return
	end
	-- Exsto
	if exsto then
		exsto.CreateFlag( Permission:lower(), Help )
		return
	end
	-- Serverguard
	if serverguard and serverguard.permission then
		serverguard.permission:Add(Permission)
		return
	end
	-- SAM
	if sam and sam.permissions and sam.permissions.add then
		sam.permissions.add( Permission, Cat, GlobalPermissions.GetSAMPermissionGroup(DefaultGroup) )
		return
	end
end
function GlobalPermissions.HasPermission( ply, Permission, Default )
	if not IsValid(ply) then return Default end
	
	local hasPermission = hook.Run( "Permission.HasPermission", ply, Permission, Default )
	if hasPermission~=nil then
		return hasPermission
	end
	
	-- ULX
	if ULib then
		return ULib.ucl.query( ply, Permission, true )
	end
	-- Evolve
	if ply.EV_HasPrivilege then
		return ply:EV_HasPrivilege( Permission )
	end
	-- Exsto
	if exsto then
		return ply:IsAllowed( Permission:lower() )
	end
	-- Serverguard
	if serverguard and serverguard.player then
		return serverguard.player:HasPermission(ply, Permission)
	end
	-- SAM
	if sam and ply.HasPermission then
		return ply:HasPermission( Permission )
	end
	
	return Default
end


-------------------------------
-- Default permission groups --
-------------------------------

local GroupToULX
function GlobalPermissions.GetULXPermissionGroup( perm )
	if not perm then return ULib.ACCESS_SUPERADMIN end
	
	if not GroupToULX then -- Delayed so ULib can load
		GroupToULX = {
			[GlobalPermissions.GROUP_SUPERADMIN] = ULib and ULib.ACCESS_SUPERADMIN,
			[GlobalPermissions.GROUP_ADMIN] = ULib and ULib.ACCESS_ADMIN,
			[GlobalPermissions.GROUP_ALL] = ULib and ULib.ACCESS_ALL,
		}
	end
	
	return GroupToULX[perm] or ULib.ACCESS_SUPERADMIN
end

local GroupToSAM = {
	[GlobalPermissions.GROUP_SUPERADMIN] = "superadmin",
	[GlobalPermissions.GROUP_ADMIN] = "admin",
	[GlobalPermissions.GROUP_ALL] = "user",
}
function GlobalPermissions.GetSAMPermissionGroup( perm )
	return GroupToSAM[ perm or "" ] or nil
end

---------------
-- On Loaded --
---------------

hook.Add( "Initialize", "Permission.OnLoad", function() --Short delay, to load after admin mods
	if not (GlobalPermissions and GlobalPermissions.SetupPermission) then return end --Just in case
	
	hook.Run( "Permission.OnLoad" )
end)
