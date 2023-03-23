-- █████╗  █████╗ ██████╗ ███████╗██████╗     ██████╗ ██╗   ██╗    ██╗  ██╗ █████╗ ██╗     ██╗██╗  ██╗
--██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗    ██╔══██╗╚██╗ ██╔╝    ╚██╗██╔╝██╔══██╗██║     ██║██║ ██╔╝
--██║  ╚═╝██║  ██║██║  ██║█████╗  ██║  ██║    ██████╦╝ ╚████╔╝      ╚███╔╝ ██║  ██║██║     ██║█████═╝
--██║  ██╗██║  ██║██║  ██║██╔══╝  ██║  ██║    ██╔══██╗  ╚██╔╝       ██╔██╗ ██║  ██║██║     ██║██╔═██╗
--╚█████╔╝╚█████╔╝██████╔╝███████╗██████╔╝    ██████╦╝   ██║       ██╔╝╚██╗╚█████╔╝███████╗██║██║ ╚██╗
-- ╚════╝  ╚════╝ ╚═════╝ ╚══════╝╚═════╝     ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚════╝ ╚══════╝╚═╝╚═╝  ╚═╝
surface.CreateFont( "mainFrame30", {
	font = "Tahoma",
	size = 30,
	weight = 500,
	extended = true,
} )

surface.CreateFont( "mainFrame25", {
		font = "Tahoma",
		size = 25,
		weight = 500,
		extended = true,
} )

surface.CreateFont( "mainFrame21", {
	font = "Tahoma",
	size = 21,
	weight = 500,
	extended = true,
} )

surface.CreateFont( "mainFrame18", {
	font = "Tahoma",
	size = 18,
	weight = 600,
	extended = true,
} )

local blur = Material("pp/blurscreen")
local tCreate, tRemove = timer.Create, timer.Remove
local drawText, drawBox = draw.SimpleText, draw.RoundedBox
local getTextSize = surface.GetTextSize
local frTime = FrameTime
local sw, sh = ScrW(), ScrH()
local tallbal = sh*.4*.070
local warnReason
local x,y

function XText(text, font, x, y, color, x_a, y_a, color_shadow)
    color_shadow = color_shadow or Color(0, 0, 0)
    draw.SimpleText(text, font, x + 1, y + 1, color_shadow, x_a, y_a)
    local w,h = draw.SimpleText(text, font, x, y, color, x_a, y_a)
    return w,h
end

local function drawBlur( panel, amount )
  x, y = panel:LocalToScreen(0, 0)
  surface.SetDrawColor(255, 255, 255)
  surface.SetMaterial(blur)

  for i = 1, 3 do
    blur:SetFloat("$blur", (i / 3) * (amount or 6))
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, sw, sh)
  end
end

local mfw, mfh = sw*.5, sh*.65
local function warnMenu()

	local mainFrame = vgui.Create( "DFrame" )
	mainFrame:SetSize( mfw, mfh )
	mainFrame:Center()
	mainFrame:SetTitle( "" )
	mainFrame:SetDraggable( false )
	mainFrame:ShowCloseButton( false )
	mainFrame:MakePopup( true )
	mainFrame:SetAlpha( 0 )
	mainFrame:AlphaTo( 255, 0.5, 0 )
	mainFrame.Paint = function( self, w, h )
		drawBlur( self, 5 )
    drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
		drawBox( 0, 0, 0, w, tallbal, Color( 0, 0, 0, 200 ) )
		drawBox( 0, 0, h - tallbal, w, tallbal, Color( 0, 0, 0, 200 ) )
		drawText( "X", "mainFrame30", w*.46, 1, Color( 127, 0, 255 ), TEXT_ALIGN_CENTER )
		drawText( "Warn", "mainFrame30", w*.503, 1, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		drawText( "2", "mainFrame30", w*.542, 1, Color( 127, 0, 255 ), TEXT_ALIGN_CENTER )
		drawText( "Список Игроков", "mainFrame30", (mfw*.5 + 10)/2, h*.06, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	local cmb = vgui.Create( "DButton", mainFrame )
	cmb:SetSize( tallbal - 4, tallbal - 4 )
	cmb:SetPos( mainFrame:GetWide()-tallbal-4, 2 )
	cmb:SetText("")
	cmb.Paint = function( self, w, h )
		drawText("X", "mainFrame30", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if self.Hovered then
			drawBox( 0, 0, 0, w, h, Color( 220, 20, 60, 150 ) )
		else
			drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
		end
	end

	cmb.DoClick = function()
		surface.PlaySound( "garrysmod/ui_click.wav" )
		mainFrame:AlphaTo(0, 0.2, 0, function() if IsValid(mainFrame) then mainFrame:Remove() end end)
	end

	local playersList = vgui.Create( "DPanel", mainFrame)
	playersList:SetSize( mainFrame:GetWide()*.5, mainFrame:GetTall()*.809 )
	playersList:SetPos( 10, mainFrame:GetTall()*.12 )
	playersList.Paint = function( self, w, h )
		drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 120 ) )
	end

	local playersTable = vgui.Create( "DScrollPanel", playersList )
	playersTable:Dock( FILL )

	for i, v in ipairs ( player.GetAll() ) do

		local playerButton = playersTable:Add( "DButton" )
		playerButton:Dock( TOP )
		playerButton:SetSize( playersList:GetWide(), playersList:GetTall()*.08 )
		playerButton:SetText( "" )
		playerButton.lerp = 0
		playerButton.Paint = function( self, w, h )
			drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
			drawBox( 0, 0, h-5, self.lerp, 5, Color( 127, 0, 255 ) )
			drawText( string.sub( v:GetName(), 0, 20 ) .. " [" .. v:GetUserGroup() .. "]", "mainFrame21", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			if self:IsHovered() then
				self.lerp = Lerp( frTime() * 7, self.lerp, w )
			else
				self.lerp = Lerp( frTime() * 7, self.lerp, 0 )
			end
		end

		playerButton.DoClick = function()

			surface.PlaySound( "garrysmod/ui_click.wav" )
		  playerWarns = v:GetNWInt( "XWarn:WarnsCount" )

		  if playerStats then playerStats:Remove() end
		  playerStats = vgui.Create( "DPanel", mainFrame )
		  playerStats:SetSize( mainFrame:GetWide()*.45, mainFrame:GetTall()*.85 )
			playerStats:SetPos( mainFrame:GetWide()*.538, mainFrame:GetTall()*.0795 )
		  playerStats:SetAlpha( 0 )
		  playerStats:AlphaTo( 255, 0.5, 0 )
		  playerStats.Paint = function( self, w, h )
		    drawBox( 0, 0, 0, w, h, Color(0, 0, 0, 120) )
		    drawText( string.sub( v:GetName(), 0, 12 ), "mainFrame30", w*.28, h*.03, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT )
		    drawText( "Количество варнов: ", "mainFrame21", w*.28, h*.13, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		    drawText( playerWarns, "mainFrame21", w*.65, h*.131, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				drawText( "/3", "mainFrame21", w*.67, h*.131, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		  end

		  local playerSteamID = vgui.Create( "DButton", playerStats )
			playerSteamID:SetSize( playerStats:GetWide()*.47, playerStats:GetTall()*.05 )
		  playerSteamID:SetPos( playerStats:GetWide()*.263, playerStats:GetTall()*.07 )
		  playerSteamID:SetText( "" )
		  playerSteamID:SetSelectable( true )
		  playerSteamID.Paint = function( self, w, h )
		    //drawBox( 5, 0, 0, w, h, Color( 60, 60, 60, 200 ) )
		    drawText( "[" .. v:SteamID() .. "]", "mainFrame21", w/2, h/2, Color( 127, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		  end

		  playerSteamID.DoClick = function()
		    surface.PlaySound("garrysmod/ui_click.wav")
		    chat.AddText( Color( 127, 0, 255 ), "[XWarn] ", Color( 255, 255, 255 ), "Копирован SteamID игрока " .. v:GetName() )
		    SetClipboardText( v:SteamID() )
		  end

		  local lastWarn = vgui.Create( "DPanel", playerStats )
		  lastWarn:SetSize( playerStats:GetWide()*.95, playerStats:GetTall()*.4 )
		  lastWarn:SetPos( playerStats:GetWide()*.025, playerStats:GetTall()*.2 )
		  lastWarn.Paint = function( self, w, h )
		    drawBlur( self, 5 )
		    drawBox( 5, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
		  end

		  local playerAvatar = vgui.Create( "AvatarImage", playerStats )
		  playerAvatar:SetSize( playerStats:GetWide()*.24, playerStats:GetTall()*.17 )
		  playerAvatar:SetPos( 10, 10 )
		  playerAvatar:SetPlayer( v, 256 )

		  local setWarnReason = "Введите причину"

		  local giveWarnReason = vgui.Create( "DTextEntry", playerStats )
		  giveWarnReason:SetSize( playerStats:GetWide()*.8, playerStats:GetTall()*.07 )
			giveWarnReason:SetPos( playerStats:GetWide()*.1, playerStats:GetTall()*.66 )
		  giveWarnReason:SetPlaceholderText( setWarnReason )
		  giveWarnReason.OnChange = function( self )
		    setWarnReason = self:GetValue()
		  end

		  local giveWarnButton = vgui.Create( "DButton", playerStats )
		  giveWarnButton:SetSize( playerStats:GetWide()*.3, playerStats:GetTall()*.06 )
			giveWarnButton:SetPos( playerStats:GetWide()*.15, playerStats:GetTall()*.75 )
		  giveWarnButton:SetText( "" )
		  giveWarnButton.lerp = 0
		  giveWarnButton.Paint = function( self, w, h )
		    drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 155 ) )
				drawBox( 0, 0, 0, self.lerp, h, Color( 127, 0, 255 ) )
		    drawText( "Выдать варн", "mainFrame18", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		    if self:IsHovered() then
		      self.lerp = Lerp( frTime() * 7, self.lerp, w+1 )
		    else
		      self.lerp = Lerp( frTime() * 7, self.lerp, 0 )
		    end

		  end

		  giveWarnButton.DoClick = function()

		    surface.PlaySound("garrysmod/ui_click.wav")

		    if setWarnReason == "Введите причину" then
		      chat.AddText( Color(220, 20, 60), "[XWarn] ", Color(255, 255, 255), "Введите причину!" )
		    else
		      net.Start( "XWarn.Warns" )
		      net.WriteBool( true )
		      net.WriteString( XWarn.WarnReason )
		      net.WriteEntity( v )
		      net.SendToServer()
		    end

		  end

			local removeWarnButton = vgui.Create( "DButton", playerStats )
		  removeWarnButton:SetSize( playerStats:GetWide()*.3, playerStats:GetTall()*.06 )
			removeWarnButton:SetPos( playerStats:GetWide()*.55, playerStats:GetTall()*.75 )
		  removeWarnButton:SetText( "" )
		  removeWarnButton.lerp = 0
		  removeWarnButton.Paint = function( self, w, h )
		    drawBox( 0, 0, 0, w, h, Color( 0, 0, 0, 155 ) )
				drawBox( 0, 0, 0, self.lerp, h, Color( 127, 0, 255 ) )
		    drawText( "Отозвать варн", "mainFrame18", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		    if self:IsHovered() then
		      self.lerp = Lerp( frTime() * 7, self.lerp, w+1 )
		    else
		      self.lerp = Lerp( frTime() * 7, self.lerp, 0 )
		    end

		  end

			removeWarnButton.DoClick = function()

		    surface.PlaySound("garrysmod/ui_click.wav")

		    if XWarn.WarnReason == "" then
		      chat.AddText( Color(220, 20, 60), "[XWarn] ", Color(255, 255, 255), "Введите причину!" )
		    else
		      net.Start( "XWarn:SetWarn" )
		      net.WriteBool( false )
		      net.WriteString( XWarn.WarnReason )
		      net.WriteEntity( v )
		      net.SendToServer()
		    end

		  end

		end

	end

end

local fsw, fsh
local function warnInfo( type, from, warns, reason )

	fsw, fsh = getTextSize( from:GetName() )

	if warnAdvert then warnAdvert:Remove() end
	warnAdvert = vgui.Create( "DFrame" )
	warnAdvert:SetPos( 10, 10 )
	warnAdvert:SetSize( 0, 0 )
	warnAdvert:SetTitle( "" )
	warnAdvert:SetDraggable( false )
	warnAdvert:ShowCloseButton( false )
	warnAdvert:SizeTo( 400, 120, 1, 0, 0.4)
	warnAdvert.Paint = function(panel, w, h)
		drawBox( 10, 0, 0, w, h, Color(0, 0, 0, 200) )
		drawText( from:GetName(), "mainFrame25", 70, 22, Color( 220, 20, 60 ), TEXT_ALIGN_LEFT )
		if type then
			drawText( "выдал вам варн", "mainFrame21", string.len( from:GetName() )*27 - 8, 24, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
		else
			drawText( "отозвал ваш варн", "mainFrame21", string.len( from:GetName() )*27 - 8, 24, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
		end
		drawText( "Причина: ", "mainFrame21", 10, 65, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
		drawText( reason, "mainFrame21", 90, 65, Color( 200, 0, 0 ), TEXT_ALIGN_LEFT)
		drawText( "Ваше количество варнов: ", "mainFrame21", 10, 85, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT)
		drawText( warns, "mainFrame21", 215, 85, Color( 200, 0, 0 ), TEXT_ALIGN_LEFT)
		drawText( "/3", "mainFrame21", 225, 85, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT)
	end

	wacb = vgui.Create( "DButton", warnAdvert )
		wacb:SetPos( 370, 0 )
		wacb:SetSize( 30, 30 )
		wacb:SetText( "" )
		wacb.Paint = function(panel, w, h)
		draw.DrawText( "X", "mainFrame25", 7, 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT )
	end

	wacb.DoClick = function()

		surface.PlaySound( "garrysmod/ui_click.wav" )
		warnAdvert:Close()
		timer.Remove( "XWarn:ShowAdvert" )
		timer.Remove( "XWarn:CloseAdvert" )

	end

	local playerImage = vgui.Create( "AvatarImage", warnAdvert )
	playerImage:SetSize( 50, 50 )
	playerImage:SetPos( 10, 10 )
	playerImage:SetPlayer( from, 64	 )


	timer.Create( "XWarn:ShowAdvert", 10, 1, function()
		warnAdvert:SizeTo( 0, 0, 1, 0, 0.4, function() warnAdvert:Remove() end)
	end)

end

local warnType, warnFrom, warnCount, warnReason
net.Receive( "XWarn:Client", warnMenu)
net.Receive( "XWarn:ClientGetWarn", function( ply )

	warnType = net.ReadBool()
	warnFrom = net.ReadEntity()
	warnCount = net.ReadString()
	warnReason = net.ReadString()

	warnInfo( warnType, warnFrom, warnCount, warnReason )

end)
