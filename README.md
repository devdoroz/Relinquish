# Relinquish

## Example usage:

```lua
local window = relinquish:CreateWindow({
	LoadingTitle = "Relinquish";
	LoadingDescription = "by doroz";
	Title = "Relinquish"
})

local tab1 = window:CreateTab("apple", 13570069248)
local tab2 = window:CreateTab("banan", 13570069248)
tab1:CreateToggle({
	Name = "This is a toggle",
	CurrentValue = false,
	Callback = function(v)
		print("Hey this toggle got changed to "..tostring(v))
	end,
})
tab2:CreateToggle({
	Name = "This is an another toggle",
	CurrentValue = false,
	Callback = function(v)
		print("Hey this toggle 2 got changed to "..tostring(v))
	end,
})
tab1:CreateSlider({
	Name = "Lead Distance",
	Range = {0, 100},
	CurrentValue = 13,
	Callback = function(v)
		
	end,
})
```
