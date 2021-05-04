local utils = {};


local cam = workspace.CurrentCamera;
local cframe_new = CFrame.new;
local vector3_new = Vector3.new;
local vector2_new = Vector2.new;
local cframeidentity = cframe_new();
local vector3identity = vector3_new();
local vector2identity = vector2_new();

local dot3 = vector3identity.Dot;
local dot2 = vector2identity.Dot;
local tos = cframeidentity.ToObjectSpace;
local ptos = cframeidentity.PointToObjectSpace;
local ptws = cframeidentity.PointToWorldSpace;
local getcomponents = cframeidentity.GetComponents;
local abs = math.abs;
local rad = math.rad;
local tan = math.tan;
local acos = math.acos;
local type = type;
--const

local pi = math.pi;
local inf = math.huge;
local r6s = {
    Head = true,
    Torso = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true;
};
local r15s = {
    Head = true,
    UpperTorso = true,
	LowerTorso = true,
    LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
    RightUpperArm = true,
    RightLowerArm = true,
    RightHand = true,
    LeftUpperLeg = true,
    LeftLowerLeg = true,
    LeftFoot = true,
    RightUpperLeg = true,
    RightLowerLeg = true,
    RightFoot = true
};

local getdescendants = game.GetDescendants;
local isa = game.IsA;

local function getboundingbox(model, orientation)
    orientation = orientation or cframeidentity;
    local minx, miny, minz = inf, inf, inf;
    local maxx, maxy, maxz = -inf, -inf, -inf;
    for i,v in pairs(getdescendants(model)) do
        if isa(v, "BasePart") then
            local cf = tos(orientation, v.CFrame);
            local size = v.Size;
            local sx, sy, sz = size.X, size.Y, size.Z;
            local x, y, z, r0, r1, r2, r10, r11, r12, r20, r21, r22 = getcomponents(cf);
            local wsx = (abs(r0) * sx + abs(r1) * sy + abs(r2) * sz) * 0.5;
            local wsy = (abs(r10) * sx + abs(r11) * sy + abs(r12) * sz) * 0.5;
            local wsz = (abs(r20) * sx + abs(r21) * sy + abs(r22) * sz) * 0.5;
            minx = minx > x - wsx and x - wsx or minx;
            miny = miny > y - wsy and y - wsy or miny;
            minz = minz > z - wsz and z - wsz or minz;

            maxx = maxx < x + wsx and x + wsx or maxx;
            maxy = maxy < y + wsy and y + wsy or maxy;
            maxz = maxz < z + wsz and z + wsz or maxz;
        end
    end
    local omin, omax = vector3_new(minx, miny, minz), vector3_new(maxx, maxy, maxz);
    return orientation - orientation.Position + ptws(orientation, (omax + omin) * 0.5), (omax - omin);
end

local function getboundingboxcharacter(model, humanoid, orientation)
    orientation = orientation or cframeidentity;
    local minx, miny, minz = inf, inf, inf;
    local maxx, maxy, maxz = -inf, -inf, -inf;
    local rigtype = humanoid.RigType.Name;
    for i,v in pairs(getdescendants(model)) do
        if isa(v, "BasePart") and (rigtype == "R6" and r6s[v.Name] or r15s[v.Name]) and v.Name ~= "HumanoidRootPart" then
            local cf = tos(orientation, v.CFrame);
            local size = v.Size;
            local sx, sy, sz = size.X, size.Y, size.Z;
            local x, y, z, r0, r1, r2, r10, r11, r12, r20, r21, r22 = getcomponents(cf);
            local wsx = (abs(r0) * sx + abs(r1) * sy + abs(r2) * sz) * 0.5;
            local wsy = (abs(r10) * sx + abs(r11) * sy + abs(r12) * sz) * 0.5;
            local wsz = (abs(r20) * sx + abs(r21) * sy + abs(r22) * sz) * 0.5;
            minx = minx > x - wsx and x - wsx or minx;
            miny = miny > y - wsy and y - wsy or miny;
            minz = minz > z - wsz and z - wsz or minz;

            maxx = maxx < x + wsx and x + wsx or maxx;
            maxy = maxy < y + wsy and y + wsy or maxy;
            maxz = maxz < z + wsz and z + wsz or maxz;
        end
    end
    local omin, omax = vector3_new(minx, miny, minz), vector3_new(maxx, maxy, maxz);
    return orientation - orientation.Position + ptws(orientation, (omax + omin) * 0.5), (omax - omin);
end
utils.getboundingbox = getboundingbox;
utils.getboundingboxcharacter = getboundingboxcharacter;
utils.r15 = r15s;
utils.r6 = r6s;
do
    local guiservice = game:GetService("GuiService");
    local inset = guiservice:GetGuiInset();
    local viewportx, viewporty = cam.ViewportSize.X, cam.ViewportSize.Y;
    local fov = cam.FieldOfView;
    local ratio = viewporty / tan(rad(fov) / 2);
    do
        cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            fov = cam.FieldOfView;
            ratio = viewporty / tan(rad(fov) / 2);
        end);
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            viewportx, viewporty = cam.ViewportSize.X, cam.ViewportSize.Y;
            ratio = viewporty / tan(rad(fov) / 2);
        end);
        local function worldtoviewportpoint(pos)
            local prel = ptos(cam.CFrame, pos);
            local x, y, z = prel.X, prel.Y, -prel.Z;
            return vector3_new((viewportx + x * ratio / z) / 2, (viewporty - y * ratio / z) / 2, z), z > 0;
        end
        local function worldtoscreenpoint(pos)
            local p, v = worldtoviewportpoint(pos);
            return vector3_new(p.X, p.Y - inset.Y, p.Z), v;
        end
        utils.worldtoscreenpoint = worldtoscreenpoint;
        utils.worldtoviewportpoint = worldtoviewportpoint;
        utils.camobj = cam;
    end
end
local function anglebetweenvector2(vec1, vec2)
    return acos(dot2(vec1, vec2) / (vec1.Magnitude * vec2.Magnitude));
end
local function anglebetweenvector3(vec1, vec2)
    return acos(dot3(vec1, vec2) / (vec1.Magnitude * vec2.Magnitude));
end
utils.anglebetweenvector2 = anglebetweenvector2;
utils.anglebetweenvector3 = anglebetweenvector3;
return utils;
