--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    WindUI - Stable Build (API Compatible)
    Fixed version with proper minimize, sections, and paragraphs
    Removed: RunService
    
    Original Author: Footagesus
]]

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

local Labels = {}
local Buttons = {}
local Toggles = {}
local Sliders = {}
local Dropdowns = {}
local Inputs = {}
local ColorPickers = {}
local Options = {}

local WindUI = {
    LocalPlayer = LocalPlayer,
    IsMobile = false,
    IsRobloxFocused = true,
    ScreenGui = nil,
    ActiveTab = nil,
    Tabs = {},
    ToggleKeybind = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Toggled = true,
    Unloaded = false,
    Minimized = false,
    
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Sliders = Sliders,
    Dropdowns = Dropdowns,
    Inputs = Inputs,
    ColorPickers = ColorPickers,
    Options = Options,
    
    CanDraggable = true,
    Signals = {},
    UnloadSignals = {},
    DPIScale = 1,
    CornerRadius = 10,
    Font = "rbxassetid://12187365364",
    Theme = nil,
    Objects = {},
    FontObjects = {},
    NotificationHolder = nil,
    OpenButton = nil,

    Themes = {
        Dark = {
            Accent = Color3.fromRGB(24, 24, 27),
            Background = Color3.fromRGB(15, 15, 16),
            Dialog = Color3.fromRGB(22, 22, 24),
            Outline = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(255, 255, 255),
            Placeholder = Color3.fromRGB(106, 106, 106),
            Button = Color3.fromRGB(63, 63, 70),
            Icon = Color3.fromRGB(161, 161, 170),
            Toggle = Color3.fromRGB(34, 197, 94),
            Slider = Color3.fromRGB(59, 130, 246),
            Section = Color3.fromRGB(30, 30, 35),
            Dark = Color3.new(0, 0, 0),
            White = Color3.new(1, 1, 1),
        },
        Light = {
            Accent = Color3.fromRGB(240, 240, 245),
            Background = Color3.fromRGB(255, 255, 255),
            Dialog = Color3.fromRGB(245, 245, 250),
            Outline = Color3.fromRGB(0, 0, 0),
            Text = Color3.fromRGB(0, 0, 0),
            Placeholder = Color3.fromRGB(120, 120, 120),
            Button = Color3.fromRGB(200, 200, 210),
            Icon = Color3.fromRGB(80, 80, 90),
            Toggle = Color3.fromRGB(34, 197, 94),
            Slider = Color3.fromRGB(59, 130, 246),
            Section = Color3.fromRGB(235, 235, 240),
            Dark = Color3.new(0, 0, 0),
            White = Color3.new(1, 1, 1),
        },
    },

    Scheme = nil,

    DefaultProperties = {
        ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
        Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        TextLabel = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", RichText = true, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextButton = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextBox = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
        ImageButton = { BorderSizePixel = 0, AutoButtonColor = false },
        UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
        ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0 },
    },

    Icons = nil,
}

WindUI.Scheme = WindUI.Themes.Dark

pcall(function()
    WindUI.DevicePlatform = UserInputService:GetPlatform()
end)
WindUI.IsMobile = (WindUI.DevicePlatform == Enum.Platform.Android or WindUI.DevicePlatform == Enum.Platform.IOS)

local function LoadIcons()
    local success, icons = pcall(function()
        local iconUrl = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
        return loadstring(game:HttpGet(iconUrl))()
    end)
    if success and icons then
        pcall(function() icons.SetIconsType("lucide") end)
        WindUI.Icons = icons
        return icons
    end
    return nil
end

pcall(LoadIcons)

function WindUI.AddSignal(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(WindUI.Signals, connection)
    return connection
end

function WindUI.DisconnectAll()
    for i = #WindUI.Signals, 1, -1 do
        local conn = table.remove(WindUI.Signals, i)
        if conn then pcall(function() conn:Disconnect() end) end
    end
end

function WindUI.SafeCallback(callback, ...)
    if not callback then return end
    local success, result = pcall(callback, ...)
    if not success then
        warn("[ WindUI ] Callback Error: " .. tostring(result))
    end
    return success, result
end

function WindUI.Icon(name, applyTheme)
    if WindUI.Icons and WindUI.Icons.Icon then
        local success, result = pcall(function()
            return WindUI.Icons.Icon(name, nil, applyTheme ~= false)
        end)
        if success then return result end
    end
    return nil
end

function WindUI.New(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in next, WindUI.DefaultProperties[className] or {} do
        pcall(function() instance[prop] = value end)
    end
    for prop, value in next, properties or {} do
        if prop ~= "ThemeTag" then
            pcall(function() instance[prop] = value end)
        end
    end
    for _, child in next, children or {} do
        if child then child.Parent = instance end
    end
    if properties and properties.FontFace then
        table.insert(WindUI.FontObjects, instance)
    end
    return instance
end

function WindUI.Tween(object, duration, properties, easingStyle, easingDirection)
    if not object then
        return {Play = function() end, Cancel = function() end}
    end
    if typeof(object) ~= "Instance" then
        return {Play = function() end, Cancel = function() end}
    end
    local ok = pcall(function() return object.Parent end)
    if not ok then
        return {Play = function() end, Cancel = function() end}
    end
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local success, tween = pcall(function()
        return TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    end)
    if success and tween then
        return tween
    end
    return {Play = function() end, Cancel = function() end}
end

function WindUI.Drag(target, dragElements, onDragCallback)
    local currentDragElement
    local isDragging = false
    local dragStart, startPos
    local dragController = { CanDraggable = true }

    if not dragElements or typeof(dragElements) ~= "table" then
        dragElements = { target }
    end

    local function update(input)
        if not isDragging or not dragController.CanDraggable then return end
        local delta = input.Position - dragStart
        WindUI.Tween(target, 0.02, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    for _, element in pairs(dragElements) do
        if element and typeof(element) == "Instance" then
            element.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragController.CanDraggable then
                    if currentDragElement == nil then
                        currentDragElement = element
                        isDragging = true
                        dragStart = input.Position
                        startPos = target.Position
                        if onDragCallback then onDragCallback(true, currentDragElement) end
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                isDragging = false
                                currentDragElement = nil
                                if onDragCallback then onDragCallback(false, nil) end
                            end
                        end)
                    end
                end
            end)

            element.InputChanged:Connect(function(input)
                if isDragging and currentDragElement == element then
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        update(input)
                    end
                end
            end)
        end
    end

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and currentDragElement ~= nil then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)

    function dragController:Set(enabled) 
        dragController.CanDraggable = enabled 
    end
    
    return dragController
end

function WindUI:Notify(options)
    options = options or {}
    local notifyData = {
        Title = options.Title or "Notification",
        Content = options.Content or options.Desc or "",
        Duration = options.Duration or 5,
        Icon = options.Icon,
    }
    
    if not WindUI.NotificationHolder then
        return notifyData
    end
    
    local iconImage
    if notifyData.Icon and WindUI.Icons then
        local iconData = WindUI.Icon(notifyData.Icon)
        if iconData then
            iconImage = WindUI.New("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 1,
                Image = iconData[1],
                ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                ImageColor3 = WindUI.Scheme.Icon,
            })
        end
    end
    
    local contentHeight = 0
    if notifyData.Content and notifyData.Content ~= "" then
        contentHeight = 20
    end
    
    local notifyHeight = 44 + contentHeight
    
    local notifyFrame = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, notifyHeight),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = WindUI.Scheme.Dialog,
        Parent = WindUI.NotificationHolder,
        ClipsDescendants = true,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, WindUI.CornerRadius) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.9,
        }),
    })
    
    local progressBar = WindUI.New("Frame", {
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = WindUI.Scheme.Slider,
        Parent = notifyFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })
    
    local contentFrame = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 1, -3),
        BackgroundTransparency = 1,
        Parent = notifyFrame,
    }, {
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 10),
        }),
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
        }),
    })
    
    if iconImage then
        iconImage.Parent = contentFrame
    end
    
    local textFrame = WindUI.New("Frame", {
        Size = UDim2.new(1, iconImage and -30 or 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = contentFrame,
    }, {
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 2) }),
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = notifyData.Title,
            TextColor3 = WindUI.Scheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
            TextSize = 15,
        }),
    })
    
    if notifyData.Content and notifyData.Content ~= "" then
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = notifyData.Content,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
            TextSize = 13,
            TextWrapped = true,
            Parent = textFrame,
        })
    end
    
    WindUI.Tween(notifyFrame, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint):Play()
    WindUI.Tween(progressBar, notifyData.Duration, { Size = UDim2.new(1, 0, 0, 3) }, Enum.EasingStyle.Linear):Play()
    
    task.delay(notifyData.Duration, function()
        WindUI.Tween(notifyFrame, 0.3, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quint):Play()
        task.wait(0.35)
        if notifyFrame and notifyFrame.Parent then
            notifyFrame:Destroy()
        end
    end)
    
    return notifyData
end

local function createParagraph(parent, options)
    options = options or {}
    local paragraphData = {
        Title = options.Title or "Paragraph",
        Content = options.Content or options.Desc or "",
    }

    local paragraphFrame = WindUI.New("Frame", {
        Name = paragraphData.Title,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = WindUI.Scheme.Dialog,
        Parent = parent,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 10),
        }),
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 4) }),
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = paragraphData.Title,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
        TextSize = 15,
        TextWrapped = true,
        Parent = paragraphFrame,
    })

    if paragraphData.Content and paragraphData.Content ~= "" then
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = paragraphData.Content,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
            TextSize = 13,
            TextWrapped = true,
            Parent = paragraphFrame,
        })
    end

    paragraphData.Frame = paragraphFrame

    function paragraphData:SetTitle(title)
        paragraphData.Title = title
        local titleLabel = paragraphFrame:FindFirstChildOfClass("TextLabel")
        if titleLabel then
            titleLabel.Text = title
        end
    end

    function paragraphData:SetContent(content)
        paragraphData.Content = content
        local labels = paragraphFrame:GetChildren()
        for _, label in pairs(labels) do
            if label:IsA("TextLabel") and label.TextTransparency > 0.1 then
                label.Text = content
                return
            end
        end
    end

    return paragraphData
end

local function createToggle(parent, toggleOptions)
    toggleOptions = toggleOptions or {}
    local toggleData = {
        Text = toggleOptions.Title or toggleOptions.Text or "Toggle",
        Default = toggleOptions.Default or false,
        Value = toggleOptions.Default or false,
        Callback = toggleOptions.Callback or function() end,
        Flag = toggleOptions.Flag,
    }

    local toggleFrame = WindUI.New("Frame", {
        Name = toggleData.Text,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = toggleData.Text,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        Parent = toggleFrame,
    })

    local toggleBack = WindUI.New("TextButton", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = toggleData.Value and WindUI.Scheme.Toggle or WindUI.Scheme.Button,
        Parent = toggleFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    local toggleCircle = WindUI.New("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = toggleData.Value and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(toggleData.Value and 1 or 0, 0.5),
        BackgroundColor3 = WindUI.Scheme.White,
        Parent = toggleBack,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    toggleData.Frame = toggleFrame
    toggleData.Back = toggleBack
    toggleData.Circle = toggleCircle

    function toggleData:SetValue(value, skipCallback)
        toggleData.Value = value
        WindUI.Tween(toggleBack, 0.2, { BackgroundColor3 = value and WindUI.Scheme.Toggle or WindUI.Scheme.Button }):Play()
        WindUI.Tween(toggleCircle, 0.2, { 
            Position = value and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(value and 1 or 0, 0.5)
        }):Play()
        if not skipCallback then
            WindUI.SafeCallback(toggleData.Callback, value)
        end
    end

    function toggleData:GetValue()
        return toggleData.Value
    end
    
    function toggleData:Set(value)
        toggleData:SetValue(value)
    end

    toggleBack.MouseButton1Click:Connect(function()
        toggleData:SetValue(not toggleData.Value)
    end)

    Toggles[toggleData.Text] = toggleData
    if toggleData.Flag then Options[toggleData.Flag] = toggleData end
    return toggleData
end

local function createButton(parent, buttonOptions)
    buttonOptions = buttonOptions or {}
    local buttonData = {
        Text = buttonOptions.Title or buttonOptions.Text or "Button",
        Desc = buttonOptions.Desc or nil,
        Callback = buttonOptions.Callback or function() end,
    }

    local buttonHeight = buttonData.Desc and 50 or 36

    local buttonFrame = WindUI.New("TextButton", {
        Name = buttonData.Text,
        Size = UDim2.new(1, 0, 0, buttonHeight),
        BackgroundColor3 = WindUI.Scheme.Button,
        Parent = parent,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.9,
        }),
    })

    local textContent = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = buttonFrame,
    }, {
        WindUI.New("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 2),
        }),
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Text = buttonData.Text,
        TextColor3 = WindUI.Scheme.Text,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
        TextSize = 14,
        Parent = textContent,
    })

    if buttonData.Desc then
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 14),
            BackgroundTransparency = 1,
            Text = buttonData.Desc,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.4,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
            TextSize = 12,
            Parent = textContent,
        })
    end

    buttonData.Frame = buttonFrame

    buttonFrame.MouseButton1Click:Connect(function()
        WindUI.Tween(buttonFrame, 0.1, { BackgroundColor3 = WindUI.Scheme.Toggle }):Play()
        task.wait(0.1)
        WindUI.Tween(buttonFrame, 0.1, { BackgroundColor3 = WindUI.Scheme.Button }):Play()
        WindUI.SafeCallback(buttonData.Callback)
    end)

    buttonFrame.MouseEnter:Connect(function()
        WindUI.Tween(buttonFrame, 0.1, { BackgroundTransparency = 0.1 }):Play()
    end)

    buttonFrame.MouseLeave:Connect(function()
        WindUI.Tween(buttonFrame, 0.1, { BackgroundTransparency = 0 }):Play()
    end)

    Buttons[buttonData.Text] = buttonData
    return buttonData
end

local function createSlider(parent, sliderOptions)
    sliderOptions = sliderOptions or {}
    local sliderData = {
        Text = sliderOptions.Title or sliderOptions.Text or "Slider",
        Default = sliderOptions.Default or sliderOptions.Min or 0,
        Min = sliderOptions.Min or 0,
        Max = sliderOptions.Max or 100,
        Rounding = sliderOptions.Rounding or 0,
        Suffix = sliderOptions.Suffix or "",
        Value = sliderOptions.Default or sliderOptions.Min or 0,
        Callback = sliderOptions.Callback or function() end,
        Flag = sliderOptions.Flag,
    }

    local sliderFrame = WindUI.New("Frame", {
        Name = sliderData.Text,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = sliderData.Text,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        Parent = sliderFrame,
    })

    local percent = (sliderData.Value - sliderData.Min) / math.max(sliderData.Max - sliderData.Min, 0.001)

    local sliderValueLabel = WindUI.New("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 18),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(sliderData.Value) .. sliderData.Suffix,
        TextColor3 = WindUI.Scheme.Text,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Right,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        Parent = sliderFrame,
    })

    local sliderBack = WindUI.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = WindUI.Scheme.Button,
        BackgroundTransparency = 0.3,
        Parent = sliderFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    local sliderFill = WindUI.New("Frame", {
        Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0),
        BackgroundColor3 = WindUI.Scheme.Slider,
        Parent = sliderBack,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    local sliderThumb = WindUI.New("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(math.clamp(percent, 0, 1), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = WindUI.Scheme.White,
        Parent = sliderBack,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    sliderData.Frame = sliderFrame
    sliderData.Back = sliderBack
    sliderData.Fill = sliderFill
    sliderData.Thumb = sliderThumb
    sliderData.ValueLabel = sliderValueLabel

    local function round(num, places)
        local mult = 10 ^ places
        return math.floor(num * mult + 0.5) / mult
    end

    function sliderData:SetValue(value, skipCallback)
        value = math.clamp(value, sliderData.Min, sliderData.Max)
        value = round(value, sliderData.Rounding)
        sliderData.Value = value
        local p = (value - sliderData.Min) / math.max(sliderData.Max - sliderData.Min, 0.001)
        p = math.clamp(p, 0, 1)
        WindUI.Tween(sliderFill, 0.1, { Size = UDim2.new(p, 0, 1, 0) }):Play()
        WindUI.Tween(sliderThumb, 0.1, { Position = UDim2.new(p, 0, 0.5, 0) }):Play()
        sliderValueLabel.Text = tostring(value) .. sliderData.Suffix
        if not skipCallback then
            WindUI.SafeCallback(sliderData.Callback, value)
        end
    end

    function sliderData:GetValue()
        return sliderData.Value
    end
    
    function sliderData:Set(value)
        sliderData:SetValue(value)
    end

    local dragging = false

    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = input.Position
            local rel = (pos.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local newValue = sliderData.Min + (sliderData.Max - sliderData.Min) * rel
            sliderData:SetValue(newValue)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position
            local rel = (pos.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local newValue = sliderData.Min + (sliderData.Max - sliderData.Min) * rel
            sliderData:SetValue(newValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Sliders[sliderData.Text] = sliderData
    if sliderData.Flag then Options[sliderData.Flag] = sliderData end
    return sliderData
end

local function createDropdown(parent, dropdownOptions)
    dropdownOptions = dropdownOptions or {}
    local dropdownData = {
        Text = dropdownOptions.Title or dropdownOptions.Text or "Dropdown",
        Values = dropdownOptions.List or dropdownOptions.Values or {},
        Default = dropdownOptions.Default,
        Multi = dropdownOptions.Multi or false,
        Value = dropdownOptions.Multi and {} or nil,
        Callback = dropdownOptions.Callback or function() end,
        Flag = dropdownOptions.Flag,
        Open = false,
    }

    if dropdownData.Default then
        if dropdownData.Multi then
            if typeof(dropdownData.Default) == "table" then
                dropdownData.Value = dropdownData.Default
            else
                dropdownData.Value = { dropdownData.Default }
            end
        else
            dropdownData.Value = dropdownData.Default
        end
    end

    local function getDisplayText()
        if dropdownData.Multi then
            if #dropdownData.Value == 0 then
                return "None selected"
            else
                return table.concat(dropdownData.Value, ", ")
            end
        else
            return dropdownData.Value or "Select..."
        end
    end

    local dropdownFrame = WindUI.New("Frame", {
        Name = dropdownData.Text,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = parent,
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = dropdownData.Text,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        Parent = dropdownFrame,
    })

    local dropdownButton = WindUI.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = WindUI.Scheme.Button,
        Parent = dropdownFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.9,
        }),
    })

    local dropdownButtonContent = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = dropdownButton,
    }, {
        WindUI.New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    local selectedLabel = WindUI.New("TextLabel", {
        Name = "Selected",
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = getDisplayText(),
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 13,
        Parent = dropdownButtonContent,
    })

    local dropdownList = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 58),
        BackgroundColor3 = WindUI.Scheme.Dialog,
        Visible = false,
        ZIndex = 50,
        ClipsDescendants = true,
        Parent = dropdownFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.9,
        }),
    })

    local optionsScroll = WindUI.New("ScrollingFrame", {
        Name = "Options",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = WindUI.Scheme.Button,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 51,
        Parent = dropdownList,
    }, {
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 2) }),
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
        }),
    })

    dropdownData.Frame = dropdownFrame
    dropdownData.Button = dropdownButton
    dropdownData.List = dropdownList
    dropdownData.SelectedLabel = selectedLabel
    dropdownData.OptionsScroll = optionsScroll

    local function updateList()
        for _, child in pairs(optionsScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, value in ipairs(dropdownData.Values) do
            local isSelected = dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value

            local optionButton = WindUI.New("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = isSelected and WindUI.Scheme.Button or WindUI.Scheme.Dialog,
                Parent = optionsScroll,
                ZIndex = 52,
            }, {
                WindUI.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
            })

            WindUI.New("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = value,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 12,
                ZIndex = 52,
                Parent = optionButton,
            })

            optionButton.MouseButton1Click:Connect(function()
                if dropdownData.Multi then
                    local idx = table.find(dropdownData.Value, value)
                    if idx then
                        table.remove(dropdownData.Value, idx)
                    else
                        table.insert(dropdownData.Value, value)
                    end
                else
                    dropdownData.Value = value
                    dropdownData.Open = false
                    dropdownList.Visible = false
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 56)
                end
                selectedLabel.Text = getDisplayText()
                updateList()
                WindUI.SafeCallback(dropdownData.Callback, dropdownData.Value)
            end)

            optionButton.MouseEnter:Connect(function()
                if not (dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value) then
                    WindUI.Tween(optionButton, 0.1, { BackgroundColor3 = WindUI.Scheme.Button }):Play()
                end
            end)

            optionButton.MouseLeave:Connect(function()
                local sel = dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value
                WindUI.Tween(optionButton, 0.1, { BackgroundColor3 = sel and WindUI.Scheme.Button or WindUI.Scheme.Dialog }):Play()
            end)
        end

        local listHeight = math.min(#dropdownData.Values * 28 + 8, 140)
        dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
        if dropdownData.Open then
            dropdownFrame.Size = UDim2.new(1, 0, 0, 56 + listHeight + 4)
        end
    end

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownData.Open = not dropdownData.Open
        dropdownList.Visible = dropdownData.Open
        if dropdownData.Open then
            updateList()
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 56)
        end
    end)

    function dropdownData:SetValue(value)
        dropdownData.Value = value
        selectedLabel.Text = getDisplayText()
        updateList()
    end
    
    function dropdownData:Set(values)
        if typeof(values) == "table" and not dropdownData.Multi then
            dropdownData.Values = values
        else
            dropdownData:SetValue(values)
        end
        updateList()
    end

    function dropdownData:Refresh(newValues, clearSelection)
        dropdownData.Values = newValues or {}
        if clearSelection then
            if dropdownData.Multi then
                dropdownData.Value = {}
            else
                dropdownData.Value = nil
            end
        end
        selectedLabel.Text = getDisplayText()
        updateList()
    end

    Dropdowns[dropdownData.Text] = dropdownData
    if dropdownData.Flag then Options[dropdownData.Flag] = dropdownData end
    return dropdownData
end

local function createInput(parent, inputOptions)
    inputOptions = inputOptions or {}
    local inputData = {
        Text = inputOptions.Title or inputOptions.Text or "Input",
        Default = inputOptions.Default or "",
        Placeholder = inputOptions.Placeholder or "Enter text...",
        Numeric = inputOptions.Numeric or false,
        Finished = inputOptions.Finished ~= false,
        Value = inputOptions.Default or "",
        Callback = inputOptions.Callback or function() end,
        Flag = inputOptions.Flag,
    }

    local inputFrame = WindUI.New("Frame", {
        Name = inputData.Text,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = inputData.Text,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        Parent = inputFrame,
    })

    local inputBox = WindUI.New("TextBox", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = WindUI.Scheme.Button,
        Text = inputData.Default,
        PlaceholderText = inputData.Placeholder,
        PlaceholderColor3 = WindUI.Scheme.Placeholder,
        TextColor3 = WindUI.Scheme.Text,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.9,
        }),
        WindUI.New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })

    inputData.Frame = inputFrame
    inputData.Box = inputBox

    function inputData:SetValue(value)
        inputData.Value = value
        inputBox.Text = value
    end

    function inputData:GetValue()
        return inputData.Value
    end

    if inputData.Finished then
        inputBox.FocusLost:Connect(function(enterPressed)
            local text = inputBox.Text
            if inputData.Numeric then
                text = tonumber(text) or inputData.Value
                inputBox.Text = tostring(text)
            end
            inputData.Value = text
            WindUI.SafeCallback(inputData.Callback, text)
        end)
    else
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = inputBox.Text
            if inputData.Numeric then
                text = tonumber(text) or inputData.Value
            end
            inputData.Value = text
            WindUI.SafeCallback(inputData.Callback, text)
        end)
    end

    Inputs[inputData.Text] = inputData
    if inputData.Flag then Options[inputData.Flag] = inputData end
    return inputData
end

local function createLabel(parent, labelOptions)
    labelOptions = labelOptions or {}
    local labelData = {
        Text = labelOptions.Title or labelOptions.Text or "Label",
    }

    local labelFrame = WindUI.New("TextLabel", {
        Name = labelData.Text,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = labelData.Text,
        TextColor3 = WindUI.Scheme.Text,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
        TextSize = 13,
        Parent = parent,
    })

    labelData.Frame = labelFrame

    function labelData:SetText(text)
        labelData.Text = text
        labelFrame.Text = text
    end

    Labels[labelData.Text] = labelData
    return labelData
end

function WindUI:CreateWindow(options)
    options = options or {}

    local themeName = options.Theme or "Dark"
    if WindUI.Themes[themeName] then
        WindUI.Scheme = WindUI.Themes[themeName]
    end

    local windowData = {
        Title = options.Title or "WindUI",
        Author = options.Author or "",
        Size = options.Size or UDim2.fromOffset(580, 460),
        Position = options.Position or UDim2.fromOffset(100, 100),
        Center = options.Center ~= false,
        Tabs = {},
        UICorner = options.CornerRadius or WindUI.CornerRadius,
        Icon = options.Icon or nil,
        Debug = options.Debug or false,
        Transparent = options.Transparent or false,
        HasOutline = options.HasOutline ~= false,
        Theme = themeName,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RINGTA"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() screenGui.Parent = gethui() end)
    if not screenGui.Parent then 
        pcall(function() screenGui.Parent = CoreGui end)
    end
    if not screenGui.Parent then
        pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    pcall(function() protectgui(screenGui) end)
    WindUI.ScreenGui = screenGui
    windowData.ScreenGui = screenGui

    local notificationHolder = WindUI.New("Frame", {
        Position = UDim2.new(1, -20, 0, 50),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 280, 1, -100),
        BackgroundTransparency = 1,
        Parent = screenGui,
        ZIndex = 100,
    }, {
        WindUI.New("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
        }),
    })
    WindUI.NotificationHolder = notificationHolder

    local mainFrame = WindUI.New("Frame", {
        Name = "MainWindow",
        Size = windowData.Size,
        Position = windowData.Center and UDim2.new(0.5, 0, 0.5, 0) or windowData.Position,
        AnchorPoint = windowData.Center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        BackgroundColor3 = WindUI.Scheme.Background,
        BackgroundTransparency = windowData.Transparent and 0.1 or 0,
        Parent = screenGui,
        ClipsDescendants = true,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, windowData.UICorner) }),
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = windowData.HasOutline and 0.92 or 1,
        }),
    })

    windowData.MainFrame = mainFrame
    windowData.OriginalSize = windowData.Size

    local topbar = WindUI.New("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = WindUI.Scheme.Accent,
        BackgroundTransparency = 0.4,
        Parent = mainFrame,
    }, {
        WindUI.New("UIStroke", {
            Color = WindUI.Scheme.Outline,
            Transparency = 0.92,
        }),
    })

    local titleContent = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = topbar,
    }, {
        WindUI.New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
        }),
    })

    local titleIcon
    if windowData.Icon and WindUI.Icons then
        local iconData = WindUI.Icon(windowData.Icon)
        if iconData then
            titleIcon = WindUI.New("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 1,
                Image = iconData[1],
                ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                ImageColor3 = WindUI.Scheme.Text,
                Parent = titleContent,
            })
        end
    end

    WindUI.New("TextLabel", {
        Size = UDim2.new(1, titleIcon and -30 or 0, 1, 0),
        BackgroundTransparency = 1,
        Text = windowData.Title,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
        TextSize = 16,
        Parent = titleContent,
    })

    local controlsContainer = WindUI.New("Frame", {
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Parent = topbar,
    }, {
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
        }),
    })

    local function createControlButton(icon, callback, color)
        local controlBtn = WindUI.New("TextButton", {
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = color or WindUI.Scheme.Button,
            BackgroundTransparency = 0.5,
            Parent = controlsContainer,
        }, {
            WindUI.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })

        if icon and WindUI.Icons then
            local iconData = WindUI.Icon(icon)
            if iconData then
                WindUI.New("ImageLabel", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = iconData[1],
                    ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                    ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                    ImageColor3 = WindUI.Scheme.Text,
                    Parent = controlBtn,
                })
            end
        end

        controlBtn.MouseButton1Click:Connect(callback)

        controlBtn.MouseEnter:Connect(function()
            WindUI.Tween(controlBtn, 0.1, { BackgroundTransparency = 0.3 }):Play()
        end)

        controlBtn.MouseLeave:Connect(function()
            WindUI.Tween(controlBtn, 0.1, { BackgroundTransparency = 0.5 }):Play()
        end)

        return controlBtn
    end

    local function minimizeWindow()
        WindUI.Minimized = true
        mainFrame.Visible = false
        if WindUI.OpenButton and WindUI.OpenButton.Parent then
            WindUI.OpenButton.Visible = true
        end
    end

    local contentHolder = WindUI.New("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })

    if not WindUI.OpenButton then
        local openBtn = WindUI.New("Frame", {
            Name = "OpenButtonContainer",
            Size = UDim2.new(0, 180, 0, 32),
            Position = UDim2.new(0.5, 0, 0, 10),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = WindUI.Scheme.Button,
            Visible = false,
            Parent = screenGui,
        }, {
            WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
            WindUI.New("UIStroke", {
                Color = WindUI.Scheme.Outline,
                Transparency = 0.9,
                Thickness = 1,
            }),
        })

        local dragHandle = WindUI.New("Frame", {
            Name = "DragHandle",
            Size = UDim2.new(0, 30, 1, 0),
            BackgroundTransparency = 1,
            Parent = openBtn,
        }, {
            WindUI.New("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10747379654", -- Grabbable handle icon
                ImageColor3 = WindUI.Scheme.Text,
                ImageTransparency = 0.5,
                Parent = dragHandle,
            })
        })

        local realButton = WindUI.New("TextButton", {
            Name = "RealButton",
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            Text = "Open The Script",
            TextColor3 = WindUI.Scheme.Text,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
            TextSize = 14,
            Parent = openBtn,
        })

        realButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            WindUI.Toggled = true
            openBtn.Visible = false
        end)

        WindUI.Drag(openBtn, { dragHandle })
        WindUI.OpenButton = openBtn
    else
        WindUI.OpenButton.Visible = false
    end

    local minimizeBtn = createControlButton("minus", minimizeWindow, Color3.fromRGB(244, 201, 72))

    local dragController = WindUI.Drag(mainFrame, { topbar })

    local sidebar = WindUI.New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = WindUI.Scheme.Accent,
        BackgroundTransparency = 0.5,
        Parent = contentHolder,
    })

    local sidebarContent = WindUI.New("ScrollingFrame", {
        Name = "SidebarContent",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = WindUI.Scheme.Button,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    }, {
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 4) }),
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }),
    })

    windowData.Sidebar = sidebarContent

    local tabContent = WindUI.New("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -168, 1, 0),
        Position = UDim2.new(0, 168, 0, 0),
        BackgroundTransparency = 1,
        Parent = contentHolder,
    })

    windowData.TabContent = tabContent

    function windowData:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabData = {
            Title = tabOptions.Title or "Tab",
            Icon = tabOptions.Icon,
            Elements = {},
        }

        local tabButton = WindUI.New("TextButton", {
            Name = tabData.Title,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = WindUI.Scheme.Button,
            BackgroundTransparency = 1,
            Parent = sidebarContent,
        }, {
            WindUI.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })

        local tabButtonContent = WindUI.New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = tabButton,
        }, {
            WindUI.New("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }),
            WindUI.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 10),
            }),
        })

        local iconImage
        if tabData.Icon and WindUI.Icons then
            local iconData = WindUI.Icon(tabData.Icon)
            if iconData then
                iconImage = WindUI.New("ImageLabel", {
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Image = iconData[1],
                    ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                    ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                    ImageColor3 = WindUI.Scheme.Icon,
                    Parent = tabButtonContent,
                })
            end
        end

        local tabLabel = WindUI.New("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, iconImage and -28 or 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tabData.Title,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
            TextSize = 14,
            Parent = tabButtonContent,
        })

        tabData.Button = tabButton
        tabData.Label = tabLabel
        tabData.IconImage = iconImage

        local tabPage = WindUI.New("ScrollingFrame", {
            Name = tabData.Title,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = WindUI.Scheme.Button,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = tabContent,
        }, {
            WindUI.New("UIListLayout", { Padding = UDim.new(0, 8) }),
            WindUI.New("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 8),
            }),
        })

        tabData.Page = tabPage

        local function selectTab()
            for _, tab in pairs(windowData.Tabs) do
                if tab.Page then tab.Page.Visible = false end
                if tab.Button then
                    WindUI.Tween(tab.Button, 0.15, { BackgroundTransparency = 1 }):Play()
                end
                if tab.Label and typeof(tab.Label) == "Instance" then
                    WindUI.Tween(tab.Label, 0.15, { TextTransparency = 0.3 }):Play()
                end
                if tab.IconImage and typeof(tab.IconImage) == "Instance" then
                    WindUI.Tween(tab.IconImage, 0.15, { ImageColor3 = WindUI.Scheme.Icon }):Play()
                end
            end
            tabPage.Visible = true
            WindUI.ActiveTab = tabData
            WindUI.Tween(tabButton, 0.15, { BackgroundTransparency = 0.7 }):Play()
            if tabLabel and typeof(tabLabel) == "Instance" then
                WindUI.Tween(tabLabel, 0.15, { TextTransparency = 0 }):Play()
            end
            if iconImage and typeof(iconImage) == "Instance" then
                WindUI.Tween(iconImage, 0.15, { ImageColor3 = WindUI.Scheme.Text }):Play()
            end
        end

        tabButton.MouseButton1Click:Connect(selectTab)

        tabButton.MouseEnter:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { BackgroundTransparency = 0.92 }):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { BackgroundTransparency = 1 }):Play()
            end
        end)

        function tabData:Section(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionData = {
                Title = sectionOptions.Title or "Section",
            }

            local sectionFrame = WindUI.New("Frame", {
                Name = sectionData.Title,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = WindUI.Scheme.Section or WindUI.Scheme.Accent,
                BackgroundTransparency = 0.6,
                Parent = tabPage,
            }, {
                WindUI.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
                WindUI.New("UIStroke", {
                    Color = WindUI.Scheme.Outline,
                    Transparency = 0.92,
                }),
            })

            local sectionHeader = WindUI.New("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = sectionFrame,
            }, {
                WindUI.New("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                }),
            })

            WindUI.New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionData.Title,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
                TextSize = 15,
                Parent = sectionHeader,
            })

            local sectionContent = WindUI.New("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 32),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = sectionFrame,
            }, {
                WindUI.New("UIListLayout", { Padding = UDim.new(0, 6) }),
                WindUI.New("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingBottom = UDim.new(0, 12),
                }),
            })

            sectionData.Frame = sectionFrame
            sectionData.Content = sectionContent

            function sectionData:Toggle(toggleOptions)
                return createToggle(sectionContent, toggleOptions)
            end

            function sectionData:Button(buttonOptions)
                return createButton(sectionContent, buttonOptions)
            end

            function sectionData:Slider(sliderOptions)
                return createSlider(sectionContent, sliderOptions)
            end

            function sectionData:Dropdown(dropdownOptions)
                return createDropdown(sectionContent, dropdownOptions)
            end

            function sectionData:Input(inputOptions)
                return createInput(sectionContent, inputOptions)
            end

            function sectionData:Label(labelOptions)
                return createLabel(sectionContent, labelOptions)
            end

            function sectionData:Paragraph(paragraphOptions)
                return createParagraph(sectionContent, paragraphOptions)
            end

            table.insert(tabData.Elements, sectionData)
            return sectionData
        end

        function tabData:Divider()
            local divider = WindUI.New("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = WindUI.Scheme.Button,
                BackgroundTransparency = 0.5,
                Parent = tabPage,
            })
            return divider
        end

        function tabData:Paragraph(paragraphOptions)
            return createParagraph(tabPage, paragraphOptions)
        end

        function tabData:Toggle(toggleOptions)
            return createToggle(tabPage, toggleOptions)
        end

        function tabData:Button(buttonOptions)
            return createButton(tabPage, buttonOptions)
        end

        function tabData:Slider(sliderOptions)
            return createSlider(tabPage, sliderOptions)
        end

        function tabData:Dropdown(dropdownOptions)
            return createDropdown(tabPage, dropdownOptions)
        end

        function tabData:Input(inputOptions)
            return createInput(tabPage, inputOptions)
        end

        function tabData:Label(labelOptions)
            return createLabel(tabPage, labelOptions)
        end

        table.insert(windowData.Tabs, tabData)
        WindUI.Tabs[tabData.Title] = tabData

        if #windowData.Tabs == 1 then
            selectTab()
        end

        return tabData
    end

    function windowData:SelectTab(tabName)
        local tab = WindUI.Tabs[tabName]
        if tab and tab.Button then
            tab.Button.MouseButton1Click:Fire()
        end
    end

    function windowData:EditOpenButton(options)
        options = options or {}
        WindUI.OpenButtonData = {
            Title = options.Title or "Open",
            Icon = options.Icon,
            CornerRadius = options.CornerRadius or UDim.new(0, 8),
            StrokeThickness = options.StrokeThickness or 1,
            Color = options.Color,
            Draggable = options.Draggable or false,
        }
        
        if WindUI.OpenButton then
            local openBtn = WindUI.OpenButton
            
            if options.CornerRadius then
                local corner = openBtn:FindFirstChildOfClass("UICorner")
                if corner then
                    corner.CornerRadius = options.CornerRadius
                end
            end
            
            if options.StrokeThickness then
                local stroke = openBtn:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Thickness = options.StrokeThickness
                end
            end
            
            if options.Color then
                local gradient = openBtn:FindFirstChildOfClass("UIGradient")
                if not gradient then
                    gradient = Instance.new("UIGradient")
                    gradient.Parent = openBtn
                end
                gradient.Color = options.Color
            end
            
            local textLabel = openBtn:FindFirstChildOfClass("TextLabel")
            if textLabel and options.Title then
                textLabel.Text = options.Title
                local textSize = TextService:GetTextSize(options.Title, 14, Enum.Font.GothamMedium, Vector2.new(300, 32))
                openBtn.Size = UDim2.new(0, math.max(textSize.X + 50, 100), 0, 32)
            end
            
            if options.Draggable then
                WindUI.Drag(openBtn, { openBtn })
            end
        end
    end

    return windowData
end

return WindUI
