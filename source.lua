local relinquish = {}
local player = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local window = {}; do
	local tab = {}; do
		tab.__index = tab
		function tab:Show()
			for index, child in pairs(self.Children) do
				child.Parent = self.Parent.UI.Main.Core.Tab
			end
		end
		function tab:Hide()
			for index, child in pairs(self.Children) do
				child.Parent = nil
			end
		end
		function tab:CreateToggle(data)
			local toggleClone = self.Parent.Props.Toggle:Clone()
			toggleClone.Title.Text = data.Name
			local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
			local function onTween()
				local textTween = tweenService:Create(toggleClone.Title, tInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)})
				local barTween = tweenService:Create(toggleClone.Bar, tInfo, {BackgroundColor3 = Color3.fromRGB(85, 116, 166)})
				local ballTween = tweenService:Create(toggleClone.Toggle.Ball, tInfo, {Position = UDim2.new(0.5, 0, 0.5, 0)})
				local backgroundTween = tweenService:Create(toggleClone.Toggle, tInfo, {BackgroundColor3 = Color3.fromRGB(57, 78, 109)})
				textTween:Play()
				barTween:Play()
				backgroundTween:Play()
				ballTween:Play()
			end
			local function offTween()
				local textTween = tweenService:Create(toggleClone.Title, tInfo, {TextColor3 = Color3.fromRGB(118, 118, 118)})
				local barTween = tweenService:Create(toggleClone.Bar, tInfo, {BackgroundColor3 = Color3.fromRGB(39, 53, 75)})
				local ballTween = tweenService:Create(toggleClone.Toggle.Ball, tInfo, {Position = UDim2.new(0, 0, 0.5, 0)})
				local backgroundTween = tweenService:Create(toggleClone.Toggle, tInfo, {BackgroundColor3 = Color3.fromRGB(39, 53, 75)})
				textTween:Play()
				barTween:Play()
				backgroundTween:Play()
				ballTween:Play()
			end
			local stateFunc = {
				[true] = onTween;
				[false] = offTween;
			}
			local function onClick(f)
				if not f then
					data.CurrentValue = not data.CurrentValue
				end
				data.Callback(data.CurrentValue)
				stateFunc[data.CurrentValue]()
			end
			stateFunc[data.CurrentValue]()
			toggleClone.Toggle.MouseButton1Click:Connect(onClick)
			toggleClone.Toggle.Ball.MouseButton1Click:Connect(onClick)
			self.Children[#self.Children + 1] = toggleClone
			return {
				Set = function(value)
					data.CurrentValue = value
					onClick(true)
				end,
			}
		end
		function tab:CreateDropdown(data)
			local shown = false
			local dropdownClone = self.Parent.Props.Dropdown:Clone()
			dropdownClone.Title.Text = data.Name
			
			local function refresh()
				dropdownClone.Dropdown.Selected.Text = data.CurrentOption
				data.Callback(data.CurrentOption)
			end
			
			local function showDropdown()
				dropdownClone.Dropdown.List.Visible = true
				dropdownClone.Dropdown.Arrow.Image = "rbxassetid://13582361562"
			end

			local function hideDropdown()
				dropdownClone.Dropdown.List.Visible = false
				dropdownClone.Dropdown.Arrow.Image = "rbxassetid://13582137949"
			end
			
			local function createSelection(option)
				local dropdownText = self.Parent.Props.DropdownText:Clone()
				dropdownClone.Dropdown.List.Size += UDim2.new(0, 0, 0, 22)
				dropdownText.Text = option
				dropdownText.Parent = dropdownClone.Dropdown.List
				dropdownText.MouseButton1Click:Connect(function()
					shown = false
					hideDropdown()
					data.CurrentOption = option
					refresh()
				end)
			end
			
			local stateFunc = {
				[false] = hideDropdown,
				[true] = showDropdown,
			}
			
			for index, option in pairs(data.Options) do
				createSelection(option)
			end
			
			dropdownClone.Dropdown.Arrow.MouseButton1Click:Connect(function()
				shown = not shown
				stateFunc[shown]()
			end)
			
			refresh()
			
			self.Children[#self.Children + 1] = dropdownClone
			
			return {
				Set = function(v)
					data.CurrentOption = v
					refresh()
				end,
			}
		end
		function tab:CreateSlider(data)
			local rangeMin = data.Range[1]
			local rangeMax = data.Range[2]
			local dragging = false
			local dragInput
			local sliderClone = self.Parent.Props.Slider:Clone()
			sliderClone.Title.Text = data.Name
			sliderClone.Number.Text = data.CurrentValue
			local function refresh()
				local percentage = (data.CurrentValue - rangeMin) / (rangeMax - rangeMin)
				sliderClone.Number.Text = math.round(data.CurrentValue * 10) / 10
				sliderClone.Slider.Coverage.Size = UDim2.new(math.clamp(percentage, 0.025, 1), 0, 1, 0)
				sliderClone.Slider.Ball.Position = UDim2.new(percentage, 0, 0.5, 0)
				data.Callback(data.CurrentValue)	
			end
			
			sliderClone.Slider.Ball.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local e; e = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							e:Disconnect()
						end
					end)
				end
			end)
			
			sliderClone.Slider.Ball.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
			
			userInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					local mousePos = userInputService:GetMouseLocation()
					local mouseX, mouseY = mousePos.X, mousePos.Y
					local boundaries0 = sliderClone.Slider.AbsolutePosition.X 
					local boundaries1 = sliderClone.Slider.AbsolutePosition.X + sliderClone.Slider.AbsoluteSize.X
					local at = mouseX - boundaries0
					local goal = boundaries1 - boundaries0
					local percentage = math.clamp(at / goal, 0, 1)
					data.CurrentValue = rangeMin + ((rangeMax - rangeMin) * percentage)
					refresh()	
				end
			end)
			
			sliderClone.Number.FocusLost:Connect(function()
				data.CurrentValue = math.clamp(tonumber(sliderClone.Number.Text) or rangeMin, rangeMin, rangeMax)
				refresh()
			end)
			
			self.Children[#self.Children + 1] = sliderClone
			
			refresh()
			
			return {
				Set = function(value)
					data.CurrentValue = value
					refresh()
				end,
			}
		end
	end
	window.__index = window
	function window:Init()
		local minimized = false
		self.UI.Main.Core.Topbar.MinimizeButton.MouseButton1Click:Connect(function()
			minimized = not minimized
			if minimized then
				self.UI.Main.BackgroundTransparency = 1
				self.UI.Main.DropShadowHolder.Visible = false
				for index, element in pairs(self.UI.Main.Core:GetChildren()) do
					if element.Name ~= "Topbar" then
						element.Visible = false
					end
				end
			else
				self.UI.Main.BackgroundTransparency = 0
				self.UI.Main.DropShadowHolder.Visible = true
				for index, element in pairs(self.UI.Main.Core:GetChildren()) do
					if element.Name ~= "Topbar" then
						element.Visible = true
					end
				end
			end
		end)
		self.UI.Main.Core.Topbar.CloseButton.MouseButton1Click:Connect(function()
			self:Notify({
				Title = "Relinquish UI",
				Content = "Press TAB to re-open ui.",
				Duration = 4
			})
			self.UI.Main.Visible = false
		end)
		userInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Tab then
				self.UI.Main.Visible = true
			end
		end)
		self.UI.Main.Introduction.Title.Text = self.Data.LoadingTitle
		self.UI.Main.Introduction.Description.Text = self.Data.LoadingDescription
		self.UI.Main.Core.Topbar.Title.Text = self.Data.Title
		self.UI.Main.BackgroundTransparency = 1
		for index, element in pairs(self.UI.Main.Core:GetChildren()) do
			element.Visible = false
		end
		self.UI.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
		local loadingInfo = TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
		local sizeTween = tweenService:Create(self.UI.Main.Introduction, loadingInfo, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0})
		local titleTween = tweenService:Create(self.UI.Main.Introduction.Title, loadingInfo, {TextTransparency = 0})
		local descriptionTween = tweenService:Create(self.UI.Main.Introduction.Description, loadingInfo, {TextTransparency = 0, Position = UDim2.new(0.078, 0, 0.512, 0)})
		local creditsTween = tweenService:Create(self.UI.Main.Introduction.Credits, loadingInfo, {TextTransparency = 0})
		local shadowTween = tweenService:Create(self.UI.Main.DropShadowHolder.DropShadow, loadingInfo, {ImageTransparency = 0.5})
		sizeTween:Play()
		sizeTween.Completed:Wait()
		self.UI.Main.BackgroundTransparency = 0
		for index, element in pairs(self.UI.Main.Core:GetChildren()) do
			element.Visible = true
		end
		task.wait(0.5)
		titleTween:Play()
		descriptionTween:Play()
		task.wait(0.5)
		shadowTween:Play()
		creditsTween:Play()
		task.wait(2.5)
		for index, element in pairs(self.UI.Main.Introduction:GetChildren()) do
			if element:IsA("TextLabel") then
				local t = tweenService:Create(element, loadingInfo, {TextTransparency = 1})
				t:Play()
			end
		end
		local introductionFrameTween = tweenService:Create(self.UI.Main.Introduction, loadingInfo, {BackgroundTransparency = 1})
		introductionFrameTween:Play()	
	end
	function window:CreateTab(name, icon)
		local tab = setmetatable({}, tab)
		local tabButton = self.Props.TabButton:Clone()
		tabButton.Image.Image = "rbxassetid://"..tostring(icon)
		tabButton.Title.Text = name
		tabButton.Parent = self.UI.Main.Core.TabsColor.TabsList
		tabButton.MouseButton1Click:Connect(function()
			if self.LastTab and self.LastTab ~= tab then
				self.LastTab.Button.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				self.LastTab.Button.Image.ImageColor3 = Color3.fromRGB(255, 255, 255)
				self.LastTab:Hide()	
			end
			local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
			local tInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
			local imageTween = tweenService:Create(tabButton.Image, tInfo2, {ImageColor3 = Color3.fromRGB(85, 116, 166)})
			local textTween = tweenService:Create(tabButton.Title, tInfo2, {TextColor3 = Color3.fromRGB(85, 116, 166)})
			local circle = Instance.new("Frame")
			local uiCorner = Instance.new("UICorner")
			local pos = userInputService:GetMouseLocation() - tabButton.AbsolutePosition
			uiCorner.Parent = circle
			uiCorner.CornerRadius = UDim.new(1, 0)
			circle.AnchorPoint = Vector2.new(0.5, 0.5)
			circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			circle.Size = UDim2.new(0, 0, 0, 0)
			circle.Parent = tabButton
			circle.BackgroundTransparency = 0.5
			circle.Position = UDim2.new(0, pos.X, 0, pos.Y - 37.5)
			local circleTween = tweenService:Create(circle, tInfo, {BackgroundTransparency = 1, Size = UDim2.new(2, 0, 2, 0)})
			imageTween:Play()
			textTween:Play()
			circleTween:Play()
			debris:AddItem(circle, 0.5)
			tab:Show()
			self.LastTab = tab
		end)
		tab.Button = tabButton
		tab.Children = {}
		tab.Parent = self
		return tab
	end
	function window:Notify(data)
		task.spawn(function()
			local function addTweenToQueue(tween)
				table.insert(self.NotifyTweens, tween)
				task.spawn(function()
					tween.Completed:Wait()
					table.remove(self.NotifyTweens, table.find(self.NotifyTweens, tween))
				end)
			end
			local notificationClone = self.Props.Notification:Clone()
			notificationClone.Frame.NotificationTitle.Text = data.Title
			notificationClone.NotificationText.Text = data.Content
			local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
			local notifShowTween = tweenService:Create(notificationClone, tInfo, {Position = UDim2.new(0, 0, 1, 0)})
			local notifHideTween = tweenService:Create(notificationClone, tInfo, {Position = UDim2.new(1.2, 0, notificationClone.Position.Y.Scale, 0)})
			local function upNotifs()
				repeat task.wait() until #self.NotifyTweens <= 0
				for index, notification in pairs(self.UI.Notifications:GetChildren()) do
					if notification:GetAttribute("Ended") then continue end
					local t = tweenService:Create(notification, tInfo, {Position = notification.Position - UDim2.new(0, 0, 0.17, 0)})
					t:Play()
					addTweenToQueue(t)
				end
			end
			local function downNotifs()
				repeat task.wait() until #self.NotifyTweens <= 0
				for index, notification in pairs(self.UI.Notifications:GetChildren()) do
					if notification:GetAttribute("Ended") then continue end
					if notificationClone.Position.Y.Scale > notification.Position.Y.Scale then continue end
					local t = tweenService:Create(notification, tInfo, {Position = notification.Position + UDim2.new(0, 0, 0.17, 0)})
					t:Play()
					addTweenToQueue(t)
				end
			end
			upNotifs()
			notificationClone.Parent = self.UI.Notifications
			notifShowTween:Play()
			task.wait(data.Duration)
			notificationClone:SetAttribute("Ended", true)
			notifHideTween:Play()
			downNotifs()
			notifHideTween.Completed:Wait()
			notificationClone:Destroy()
		end)
	end
end

function relinquish:CreateWindow(data)
	local items = game:GetObjects("rbxassetid://13584545046")[1]
	local nwWindow = setmetatable({}, window)
	nwWindow.Props = items.Props
	nwWindow.UI = items.RelinquishUI
	nwWindow.Data = data
	nwWindow.NotifyTweens = {}
	nwWindow.LastTab = nil
	do
		local gui = nwWindow.UI.Main

		local dragging
		local dragInput
		local dragStart
		local startPos
		local nwPosition = gui.Position

		local function update(input)
			local delta = input.Position - dragStart
			nwPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.Core.Topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				local e; e = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						e:Disconnect()
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		userInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
		
		task.spawn(function()
			local tInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
			while true do
				task.wait()
				local t = tweenService:Create(gui, tInfo, {Position = nwPosition})
				t:Play()
			end
		end)
	end
	task.spawn(nwWindow.Init, nwWindow)
	return nwWindow
end

return relinquish
