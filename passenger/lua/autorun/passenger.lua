print(" ---- Passenger Mod v1.0 Initialized! ----- ")
print(" ------- Passenger Mod by Wood -------- ")
print(" ------- Please report any bugs to the github or workshop area  -------- ")
 
local function IsSCar( veh )
		if IsValid(veh) and veh.Base and veh.Base == "sent_sakarias_scar_base" then
				return true
		end
		return false
end
 
local function IsSCarSeat( seat )
		if IsValid(seat) and seat.IsScarSeat and seat.IsScarSeat == true then
				return true
		end
		return false
end
 
local function DoHorn( ply )
		ply.canuse = ply.canuse or true
		if !(ply.canuse) then return end
		ply.canuse = false
		timer.Create("pm_mod_hh", 2, 1, function() ply.canuse = true end)
		if ply:KeyDown( IN_RELOAD ) then
				local veh = ply:GetVehicle() or {}
				if IsValid( veh ) && veh:GetClass() != "prop_vehicle_prisoner_pod" then
						veh:EmitSound("/beepbeep1.wav", 100, 100)
				end
		end
end
hook.Add("KeyPress", "TurnOnHorn", DoHorn)
 
local function SpawnedVehicle( ply, vehicle )
		if !IsSCar( vehicle ) then
			local localpos = vehicle:GetPos()
			local localang = vehicle:GetAngles()
		   
			local seatdata = (list.Get( "Vehicles" )[ "airboat_seat" ] or {})
		   
			if (seatdata == nil) then print("Can't read the vehicle data!") return end
		   
			vehicle.Seats = {}
		   
			local vcextraseats = (vehicle.VehicleTable.VC_ExtraSeats or {})
		   
			for a,b in pairs(vcextraseats) do
				local SeatPos = localpos + ( localang:Forward() * b.Pos.x) + ( localang:Right() * b.Pos.y) + ( localang:Up() * b.Pos.z)
				local Seat = ents.Create( "prop_vehicle_prisoner_pod" )
			   
				local SeatPos = localpos + ( localang:Forward() * b.Pos.x) + ( localang:Right() * b.Pos.y) + ( localang:Up() * b.Pos.z)
				local Seat = ents.Create( "prop_vehicle_prisoner_pod" )
				Seat:SetModel( seatdata.Model )
				Seat:SetKeyValue( "vehiclescript" , "scripts/vehicles/prisoner_pod.txt" )
				Seat:SetAngles( localang + b.Ang )
				Seat:SetPos( vehicle:LocalToWorld(b.Pos) )
				Seat:SetColor(Color(255,255,255, 0))
				Seat:SetRenderMode( RENDERMODE_TRANSALPHA )
				Seat:Spawn()
				Seat:Activate()
			   
			   -- Removed whilst we fix the colour issue, seems to not set it correctly.
				--if b.Hide then 
					--Seat:SetColor(Color(255,255,255, 0))
					--Seat:SetRenderMode( RENDERMODE_TRANSALPHA )
				--end
			   
				constraint.Weld(Seat, vehicle, 0,0,0,0)
				Seat:SetParent(vehicle)
			   
				if ( seatdata.KeyValues ) then
					for k, v in pairs( seatdata.KeyValues ) do
					Seat:SetKeyValue( k, v )
					end            
				end
							   
					   
				Seat.VehicleName = "Jeep Seat"
				Seat.ClassOverride = "prop_vehicle_prisoner_pod"
				Seat.locked = false
				Seat:DeleteOnRemove( vehicle )
				table.insert(vehicle.Seats, Seat)
				----------- Replace the position with the ent so we can find it later.
				--vehicle.VehicleTable.Passengers[a].Ent = Seat
			end
		end
end
hook.Add( "PlayerSpawnedVehicle", "SpawnedVehicle", SpawnedVehicle )
 
local function LockAllSeats( ply )
	if !(IsValid( ply )) then return end
	if !(ply:InVehicle()) then return end
	if ply:GetVehicle():GetClass() == "prop_vehicle_prisoner_pod" then return end
   
	local v = ply:GetVehicle()
	local seats = 0
   
	for _, seat in pairs(v.Seats or {}) do
		seat.locked = true
		seats = seats + 1
	end
	ply:ChatPrint(seats .. " Seats are now locked!")
end
concommand.Add("lock", LockAllSeats)
 
local function UnLockAllSeats( ply )
	if !(IsValid( ply )) then return end
	if !(ply:InVehicle()) then return end
	if ply:GetVehicle():GetClass() == "prop_vehicle_prisoner_pod" then return end
   
	local v = ply:GetVehicle()
	local seats = 0
   
	for _, seat in pairs(v.Seats or {}) do
		seat.locked = false
		seats = seats + 1
	end
	ply:ChatPrint(seats .. " Seats are now unlocked!")
end
concommand.Add("unlock", UnLockAllSeats)
 
local function EjectPassengers(ply)
	if !(IsValid( ply )) then return end
	if !(ply:InVehicle()) then return end
	if ply:GetVehicle():GetClass() == "prop_vehicle_prisoner_pod" then return end
   
	local v = ply:GetVehicle()
   
	for _, seat in pairs(v.Seats or {}) do
			if IsValid(seat:GetDriver()) && !(seat:GetDriver() == ply) then
					seat:GetDriver():ExitVehicle()
			end
	end
		   
	return ""
end
concommand.Add("eject", EjectPassengers)
 
local function HonkHorn( player,cmd,arg )
	if player:InVehicle() then
	local vehicle = player:GetVehicle()
	   if vehicle.VehicleTable then
			player:GetVehicle():EmitSound("/beepbeep1.wav", 100, 100)
	   end
	end
end
concommand.Add( "HonkHorn", HonkHorn )
 
local function SetPlayerInts( ply )
	ply.canuse = true
	ply.nextHyd = CurTime() + .5
end
hook.Add("PlayerSpawn", "ghtrshstrhtsrhtr", SetPlayerInts)
 
function ChooseSeat( ply, car )
		if ply:InVehicle() then
			ply.canuse = false
			timer.Simple(2, function() ply.canuse = true end)
			return true
		end
	   
		ply.canuse = ply.canuse or true
	   
		if (car:IsVehicle() && IsValid(car:GetDriver()) && ply.canuse) then
 
		ply.canuse = false
		timer.Simple(2, function() ply.canuse = true end)
   
			local distancetable = {}
   
			for k, v in pairs(ents.FindInSphere(ply:GetPos(), 100 )) do
				if v:GetClass() == "prop_vehicle_prisoner_pod" && IsValid( v ) && car != v && v.locked == false then
					if !(IsOnCar( v, car )) then continue end
					local dtable = {
							seat = v,
							distance = v:GetPos():Distance( ply:GetPos() )
					}
					table.insert( distancetable, dtable )
				end
			end
		   
		   
			local maxdist = 500
			local nearestseat = 1
			local found = false
			for k, v in pairs( distancetable ) do
					if v.distance < maxdist then
							maxdist = v.distance
							nearestseat = k
							found = true
					end
			end
		   
		   
			if !(found) then return false end
		   
			ply:EnterVehicle( distancetable[nearestseat].seat )

		else
				return true
		end
end
hook.Add("PlayerUse", "ChooseSeat", ChooseSeat)
 
local function FlipCar( ply )
	local pos = ply:EyePos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ply:GetForward()*450)
	tracedata.filter = ply
	local tr = util.TraceLine(tracedata)
   
	if tr.Entity:IsVehicle() && !(tr.Entity:GetClass() == "prop_vehicle_prisoner_pod") && tr.Entity.Owner == ply then
	local mass = tr.Entity:GetPhysicsObject():GetMass()
		tr.Entity:GetPhysicsObject():SetVelocity(tr.Entity:GetUp()*-(mass/2) + tr.Entity:GetRight()*5)
	end
end
concommand.Add("flip", FlipCar)
 
local function catchHyd ( Player )
	if (Player.nextHyd && Player.nextHyd > CurTime()) then return end
	if (!Player:InVehicle()) then return end
   
	local vehicleTable = Player:GetVehicle().VehicleTable
	local owner = Player:GetVehicle().Owner
   
	if (!vehicleTable) then return end
   
	if !(owner:IsUserGroup("donator") or owner:IsAdmin()) then return end
		   
	Player:GetVehicle():GetPhysicsObject():ApplyForceCenter(Player:GetVehicle():GetUp() * Player:GetVehicle():GetPhysicsObject():GetMass() * 200)
   
	Player.nextHyd = CurTime() + .5
end
concommand.Add("hydr", catchHyd)
 
function IsOnCar( seat, car )
	local cons = constraint.GetAllConstrainedEntities( car )
   
	for k, v in pairs(cons) do
			if IsValid( v ) && v == seat then
					return true
			end
	end
	return false
end
 
local function FindExitPos( ply, veh )
	local fis = veh:GetPos() + Vector(0, 0, 55)
   
	if ply:VisibleVec( fis ) then
			ply:ExitVehicle()
			ply:SetPos( fis )
	else
			FindExitPos( ply, veh )
	end
end
 
local function ShowCursor( ply )
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end
hook.Add("ShowSpare1", "ShowCursor_passenger", ShowCursor)
 
hook.Add("CanExitVehicle", "PAS_ExitVehicle", function( veh, ply )
	if !IsSCarSeat( veh ) then
			// L+R
			if ply:VisibleVec( veh:LocalToWorld(Vector(80, 0, 5) )) then
					ply:ExitVehicle()
					ply:SetPos( veh:LocalToWorld(Vector(75, 0, 5) ))
					return false
			end
		   
			if ply:VisibleVec( veh:LocalToWorld(Vector(-80, 0, 5) )) then
					ply:ExitVehicle()
					ply:SetPos( veh:LocalToWorld(Vector(-75, 0, 5) ))
					return false
			end
	end

	--return false --//YOU SHOULDNT RETURN HERE! THIS WILL OVERRIDE THE HOOKS FOR ALL OTHER MOUNTED ADDONS
end)
