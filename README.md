## About
### Wanna flex 💪 in front of your friend about how much time you've wasted on your personal project.
### Might i suggest you playtime.nvim
![image](https://github.com/user-attachments/assets/a6c426ca-e681-4faa-92dd-45b190da0c89)

<br/>

**It shows the time you've spent on the current project ever since you first open the current project. The time is presisted between session just so you can flex harder 💪**

## INSTALLATION

NOTE: this requires `nvim-lua/plenary.nvim` so plug users have that installed

**Plug**
```lua
Plug "harshk200/playtime.nvim"
```


**Lazy.nvim:**
```lua
return {
	"harshk200/playtime.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("playtime").setup() -- can provide opts here for window ui configuration listed in the section below
	end,
}
```

## USAGE
**You can call `:PlaytimeToggle` vim command to hide/show the timer window**
**NOTE: even if the window is hidden the timer doesn't stop, it continues to run in the background**

**You can remap the above if you like**
```lua
vim.keymap.set("n", "<leader>pt", ":PlaytimeToggle")
```

## Configuration
Default config options for window
```lua
    -- window config options (they are for the vim.api.nvim_open_win() so you can provide anything you want for your styling)
    local default_opts = {
        relative = "editor",
        width = 8,
        height = 1,
        row = 0,                -- row does defnies where to place on the y axis
        col = vim.o.columns,    -- column does defines where to place on the x axis
        style = "minimal",
        focusable = false,
        noautocmd = true,
        border = "rounded",
        anchor = "NW",
        zindex = 150,
        win_visible_on_startup = true, -- the window is visible on startup by default
    }
```
