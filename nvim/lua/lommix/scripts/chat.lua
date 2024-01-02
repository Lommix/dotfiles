local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Ollama = require("lommix.scripts.ollama")

local default_config = {
	keymap = {
		clear = "<C-n>",
		send = "<CR>",
		quit = "<ESC>",
	},
}

--- @class Message
--- @field role string
--- @field content string

--- @class CurrentChat
--- @field model string
--- @field messages Message[]

--- @class Chat
--- @field layout NuiLayout
--- @field chat_float NuiPopup
--- @field prompt_float NuiPopup
--- @field model string
--- @field toggle function
--- @field private visible boolean
--- @field private running boolean
--- @field private current_chat CurrentChat

local Chat = {}

--- @constructor Chat
--- @param model string
--- @return Chat
function Chat:new(model, opts)
	local chat_float = Popup({
		focusable = true,
		border = {
			highlight = "FloatBorder",
			style = "rounded",
			text = {
				top = " Chat ",
			},
		},
		win_options = {
			wrap = true,
			linebreak = true,
			foldcolumn = "1",
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
		buf_options = {
			filetype = "markdown",
		},
	})

	local prompt_float = Popup({
		focusable = true,
		enter = true,
		border = {
			highlight = "FloatBorder",
			style = "rounded",
			text = {
				top = " Prompt ",
			},
		},
	})

	local layout = Layout(
		{
			position = "50%",
			size = {
				width = "80%",
				height = "80%",
			},
		},
		Layout.Box({
			Layout.Box(chat_float, { size = "80%" }),
			Layout.Box(prompt_float, { size = "20%" }),
		}, { dir = "col" })
	)

	local chat = {
		model = model,
		chat_float = chat_float,
		prompt_float = prompt_float,
		layout = layout,
		visible = false,
		current_chat = {
			model = model,
			messages = {},
		},
	}

	prompt_float:map("n", "<CR>", function()
		chat:send()
	end)

	prompt_float:map("n", "<Esc>", function()
		chat:toggle()
	end)

	prompt_float:map("n", "<C-n>", function()
		chat:clear_chat()
	end)

	chat_float:map("n", "<Tab>", "<C-w>W", { silent = true })
	prompt_float:map("n", "<Tab>", "<C-w>w", { silent = true })

	setmetatable(chat, self)
	self.__index = self
	return chat
end

function Chat:set_model(model)
	self.model = model
	self.current_chat.model = model
end

function Chat:clear_chat()
	vim.api.nvim_buf_set_lines(self.chat_float.bufnr, 0, -1, false, {})

	self.current_chat = {
		model = self.model,
		messages = {},
	}
end

function Chat:send()
	if self.running then
		print("Already running")
		return
	end

	local prompt = table.concat(vim.api.nvim_buf_get_lines(self.prompt_float.bufnr, 0, -1, false), "\n")
	vim.api.nvim_buf_set_lines(self.prompt_float.bufnr, 0, -1, false, {})

	-- insert into chat
	vim.api.nvim_buf_set_lines(self.chat_float.bufnr, -1, -1, false, { "", "# " .. prompt, "" })

	self.running = true

	self.current_chat.messages[#self.current_chat.messages + 1] = {
		role = "user",
		content = prompt,
	}

	Ollama.chat(
		self.current_chat,
		self.chat_float.bufnr,
		self.chat_float.winid,
		self.chat_float.win_config.width,
		function()
			self.running = false
		end
	)
end

--.toggles chat window
function Chat:toggle()
	if self.visible then
		self.layout:hide()
		self.visible = false
	else
		self.layout:show()
		self.visible = true
	end
end

return Chat
