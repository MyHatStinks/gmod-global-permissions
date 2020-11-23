# gmod-global-permissions
Garry's Mod permissions compatibility for multiple moderation systems.

## Using Global Permissions in your addon

### Adding the file

If you want to use this script in your owna ddon, the first step is to copy it to a unique location in your own addon. By moving it out of the autorun folder you ensure that you're not overwriting other addons using the script, the script itself ensures that only the most up-to-date version is loaded at any time.

As this is a shared script, make sure you `include()` and `AddCSLuaFile()` as you would any other shared file.

### Checking a user's rank

If you don't need to set up any fancy permissions and just want to see a player's rank in whatever moderation system is installed, you can use the function `GlobalPermissions.GetRank( Player ToCheck )`. If a compatible moderation system is installed this will return a string with the player's current rank.

### Setting up your permissions

Global Permissions provides a simple system to load your custom permissions via the `Permission.OnLoad` hook and the `GlobalPermissions.SetupPermission( string PermissionName, enum DefaultGroup, string HelpText, string Category )` function. Permissions should be set up on both the client and the server.

The `GlobalPermissions.SetupPermission` function takes four arguments: `string PermissionName`, `enum DefaultGroup`, `string HelpText`, `string Category`.

* `PermissionName` - This is the name of your custom permission, you will use this string again later to check if a user has access.
* `DefaultGroup` - This determines which groups have this permission by default, in moderation systems that support it. This should be one of the following:
	* `GlobalPermissions.GROUP_SUPERADMIN` for superadmins
	* `GlobalPermissions.GROUP_ADMIN` for administrators
	* `GlobalPermissions.GROUP_ALL` for all users.
* `HelpText` - This describes what this permission does, where supported by the moderation systems.
* `Category` - This is the category in which this permission apears, where supported by the moderation systems.

Here is an example of setting up custom permissions:

```Lua
-- Use the hook to make sure everything is already set up
hook.Add( "Permission.OnLoad", "GlobalPermissions Example", function()
	-- Set up a superadmin permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_SuperAdmin", GlobalPermissions.GROUP_SUPERADMIN, "Treat user as a superadmin!", "GlobalPermissions" )
	
	-- Set up an admin permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_Admin", GlobalPermissions.GROUP_ADMIN, "Treat user as an admin!", "GlobalPermissions" )
	
	-- Set up a user permission
	GlobalPermissions.SetupPermission( "GlobalPermissions_User", GlobalPermissions.GROUP_ALL, "Treat user as a user!", "GlobalPermissions" )
end)
```

### Checking your custom permissions.

You can check a user's permission at any point using the simple function `GlobalPermissions.HasPermission( Player ToCheck, string PermissionName, bool DefaultValue )`. The default value will be used when no moderation systems are detected.

In the following example we implement a simple command to tell the user which permissions they have:

```Lua
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
	if GlobalPermissions.HasPermission( p, "GlobalPermissions_User", true ) then
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
```

## Using GlobalPermissions in your moderation system

If you have made a moderation system that isn't inherently supported by GlobalPermissions, you can add support easily using a few simple hooks. You do not need to include GlobalPermissions files, you can safely assume any addon that relies on it is using a suitable version.

* `Permission.SetUp`
	* Arguments `string PermissionName`, `enum DefaultGroup`, `string HelpText`, `string Category`.
	* This hook allows you to register a custom permission with your addon. You do not need to return any value.
* `Permission.HasPermission`
	* Arguments `Player ToCheck`, `string PermissionName`, `bool DefaultValue`.
	* The permission string should exactly match the string in `Permission.SetUp`. You should return either `true` or `false` here, dependant on whether the user should have access to this permission.
* `Permission.GetRank`
	* Arguments `Player ToCheck`
	* This hook should return the player's current role as a string.
