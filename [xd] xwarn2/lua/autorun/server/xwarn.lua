--░█████╗░░█████╗░██████╗░███████╗██████╗░    ██████╗░██╗░░░██╗    ██╗░░██╗░█████╗░██╗░░░░░██╗██╗░░██╗
--██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗    ██╔══██╗╚██╗░██╔╝    ╚██╗██╔╝██╔══██╗██║░░░░░██║██║░██╔╝
--██║░░╚═╝██║░░██║██║░░██║█████╗░░██║░░██║    ██████╦╝░╚████╔╝░    ░╚███╔╝░██║░░██║██║░░░░░██║█████═╝░
--██║░░██╗██║░░██║██║░░██║██╔══╝░░██║░░██║    ██╔══██╗░░╚██╔╝░░    ░██╔██╗░██║░░██║██║░░░░░██║██╔═██╗░
--╚█████╔╝╚█████╔╝██████╔╝███████╗██████╔╝    ██████╦╝░░░██║░░░    ██╔╝╚██╗╚█████╔╝███████╗██║██║░╚██╗
--░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═════╝░    ╚═════╝░░░░╚═╝░░░    ╚═╝░░╚═╝░╚════╝░╚══════╝╚═╝╚═╝░░╚═╝

XWarn = XWarn or {}

-- Группы, имеющие доступ к командам ниже
XWarn.GroupAccess = {
	["developer"] = true,
	["superadmin"] = true,
	["admin"] = true,
	["user"] = true,
}
-- Команда, для открытия меню
XWarn.WarnMenu = "/warn"
-- Выбор Админ Мода (ulx, serverguard, fadmin)
XWarn.AdminMod = "ulx"

MsgC( Color( 127, 0, 255 ), '| [XLib] ', Color( 220, 20, 60 ), 'XWarn2', Color( 255, 255, 255 ), ' initializating..\n' )
--------- ЭТО НЕ ТРОГАТЬ! ---------===============================
--   НУЖНО ДЛЯ РАБОТЫ СКРИПТА!   --===============================
util.AddNetworkString( "XWarn:Client" )
util.AddNetworkString( "XWarn:SendInfo" )
util.AddNetworkString( "XWarn:GetInfo" )
util.AddNetworkString( "XWarn:Warns" )
util.AddNetworkString( 'XWarn:ClientGetWarn' )
util.AddNetworkString( 'XWarn:LastWarn' )

file.CreateDir("warns")

hook.Add( "Think", "ReadWarns", function( ply )

	for i, v in ipairs( player.GetAll() ) do

		if file.Exists("warns/" .. v:SteamID64() .. ".txt", "DATA") then
			v.WarnCount = file.Read("warns/" .. v:SteamID64() .. ".txt", "DATA")
		else
			file.Write("warns/" .. v:SteamID64() .. ".txt", "0")
		end

	end

end)

if XWarn.AdminMod == "ulx" then

	function XWarn.RemoveUser()
		RunConsoleCommand( 'ulx', 'removeuser', XWarn.To:GetName() )
		file.Write("warns/" .. XWarn.To:SteamID64() .. ".txt", "0")
		XWarn.To.WarnCount = 0
	end

	function XWarn.BanUser()
		RunConsoleCommand( 'ulx', 'ban', XWarn.To:GetName(), '0', '[XWarn] Максимальное количество варнов (3/3)')
		file.Delete("warns/" .. v:SteamID64() .. ".txt" )
	end

elseif XWarn.AdminMod == "serverguard" then

	function XWarn.RemoveUser()
		RunConsoleCommand( 'sg', 'setrank', XWarn.To:GetName(), 'user' )
		file.Write("warns/" .. XWarn.To:SteamID64() .. ".txt", "0")
		XWarn.To.WarnCount = 0
	end

	function XWarn.BanUser()
		RunConsoleCommand( 'sg', 'ban', XWarn.To:GetName(), '0', '[XWarn] Максимальное количество варнов (3/3)' )
		file.Delete("warns/" .. v:SteamID64() .. ".txt" )
	end

end

hook.Add( "PlayerSay", "XWarn:WarnMenu", function( ply, text )

	text = string.lower( text )
	if text == XWarn.WarnMenu and XWarn.GroupAccess[ ply:GetUserGroup() ] then
		net.Start( "XWarn:Client" )
		net.Send( ply )
		return ""
	end

end)

net.Receive( "XWarn.LastWarn", function()

	XWarn.To = net.ReadEntity()

	if file.Exists( "warns/" .. XWarn.To:SteamID64() .. "_l.txt", "DATA" ) then

		XWarn.LastWarnExist = true
		XWarn.InfoTable = string.Split( file.Read( "warns/" .. XWarn.To:SteamID64() .. "_l.txt", "DATA" ), "/" )
		XWarn.WarnCount = XWarn.InfoTable[1]
		XWarn.WarnType = XWarn.InfoTable[2]
		XWarn.WarnFrom = XWarn.InfoTable[3]
		XWarn.WarnReason = XWarn.InfoTable[4]

		net.Start( "XWarn.LastWarn" )
		net.WriteBool( XWarn.LastWarnExist )
		net.WriteString( XWarn.WarnCount )
		net.WriteString( XWarn.WarnType )
		net.WriteString( XWarn.WarnFrom )
		net.WriteString( XWarn.WarnReason )
		net.Send( XWarn.From )

	else

		XWarn.LastWarnExist = false
		net.Start( "XWarn.LastWarn" )
		net.WriteBool( XWarn.LastWarnExist )
		net.Send( XWarn.From )


	end

end)

net.Receive( "XWarn.Warns", function()

		XWarn.Type = net.ReadString()
		XWarn.Reason = net.ReadString()
		XWarn.To = net.ReadEntity()
		XWarn.From = net.ReadEntity()

		if XWarn.GroupAccess[ XWarn.From:GetUserGroup() ] then

			if XWarn.Type == "GiveWarn" then

				XWarn.To.WarnCount = XWarn.To.WarnCount + 1
				file.Write("warns/" .. XWarn.To:SteamID64() .. ".txt", XWarn.To.WarnCount )
				file.Write("warns/" .. XWarn.To:SteamID64() .. "_l.txt", XWarn.To.WarnCount .. "/" .. XWarn.Type .. "/" ..  XWarn.From:Nick() .. "/" .. XWarn.Reason )

				XWarn.From:SendLua( 'chat.AddText( Color(116, 0, 255), \"[XWarn] \", Color(255, 255, 255), \"Выдан варн игроку \", Color( 116, 0, 255 ), ' .. '"' .. XWarn.To:GetName() .. ': "' .. ', Color(255, 255, 255), ' .. '"' .. XWarn.To.WarnCount .. '"' .. ', Color(255, 255, 255), \"/\", Color(255, 0, 0), \"3\" )' )

				if XWarn.To.WarnCount == 3 then
					if XWarn.To:IsAdmin() or XWarn.To:IsSuperAdmin() then
						XWarn.RemoveUser()
					else
						XWarn.BanUser()
					end
				end

				net.Start( 'XWarn.ClientGetWarn' )
				XWarn.Type = 'XWarn.GiveWarn'
				net.WriteString( XWarn.Type )
				net.WriteEntity( XWarn.From )
				net.WriteString( XWarn.To.WarnCount )
				net.WriteString( XWarn.Reason )
				net.Send( XWarn.To )

			elseif XWarn.Type == "TakeWarn" then

				XWarn.To.WarnCount = XWarn.To.WarnCount - 1
				file.Write("warns/" .. XWarn.To:SteamID64() .. ".txt", XWarn.To.WarnCount )
				file.Write("warns/" .. XWarn.To:SteamID64() .. "_l.txt", XWarn.To.WarnCount .. "/" .. XWarn.Type .. "/" ..  XWarn.From:Nick() .. "/" .. XWarn.Reason )

				XWarn.From:SendLua( 'chat.AddText( Color(116, 0, 255), \"[XWarn] \", Color(255, 255, 255), \"Отозван варн игроку \", Color( 116, 0, 255 ), ' .. '"' .. XWarn.To:GetName() .. ': "' .. ', Color(255, 255, 255), ' .. '"' .. XWarn.To.WarnCount .. '"' .. ', Color(255, 255, 255), \"/\", Color(255, 0, 0), \"3\" )' )


				net.Start( 'XWarn.ClientGetWarn' )
				XWarn.Type = 'XWarn.TakeWarn'
				net.WriteString( XWarn.Type )
				net.WriteEntity( XWarn.From )
				net.WriteString( XWarn.To.WarnCount )
				net.WriteString( XWarn.Reason )
				net.Send( XWarn.To )

			end

		end

end)
