---! provider and model configuration
local M = {}

------------------------------------------------------------------
-- Providers
------------------------------------------------------------------
M.provider = {}
M.provider.llama = blitz.add_provider({
	type = "openai",
	url = "http://127.0.0.1:8118/v1",
	key_envar = "",
})

M.provider.novita = blitz.add_provider({
	type = "openai",
	url = "https://api.novita.ai/openai/v1",
	key_envar = "NOVITA_API_KEY",
})

M.provider.opencode = blitz.add_provider({
	type = "openai",
	url = "https://opencode.ai/zen/go/v1",
	key_envar = "OPENCODE_API_KEY",
	session_key_header = "x-opencode-session",
})

M.provider.deepseek = blitz.add_provider({
	type = "openai",
	url = "https://api.deepseek.com",
	key_envar = "DEEPSEEK_API_KEY",
})

M.provider.opencode_pic = blitz.add_provider({
	type = "anthropic",
	url = "https://opencode.ai/zen/go/v1",
	key_envar = "OPENCODE_API_KEY",
	session_key_header = "x-opencode-session",
})

M.provider.opencode_res = blitz.add_provider({
	type = "response",
	url = "https://opencode.ai/zen/go/v1",
	key_envar = "OPENCODE_API_KEY",
	session_key_header = "x-opencode-session",
})

M.provider.requesty = blitz.add_provider({
	type = "openai",
	url = "https://router.requesty.ai/v1",
	key_envar = "REQUESTY_API_KEY",
	session_key_header = "x-session-id",
})

M.provider.orouter = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
	session_key_header = "x-session-id",
})

M.provider.hetzner = blitz.add_provider({
	type = "openai",
	url = "https://inference.hetzner.com/api/v1",
	key_envar = "HETZNER_AI_KEY",
	session_key_header = "x-session-id",
})

M.provider.zai = blitz.add_provider({
	type = "openai",
	url = "https://api.z.ai/api/coding/paas/v4",
	key_envar = "Z_AI_KEY",
})

M.provider.xai = blitz.add_provider({
	type = "response",
	url = "https://api.x.ai/v1",
	key_envar = "XAI_API_KEY",
	session_key_header = "x-grok-conv-id",
})

M.provider.openai = blitz.add_provider({
	type = "response",
	url = "https://api.openai.com/v1",
	key_envar = "OPENAI_API_KEY",
})

------------------------------------------------------------------
-- MODELS
------------------------------------------------------------------
M.glm_flash = blitz.add_model({
	name = "glm-5.3-flash",
	provider = M.provider.zai,
	-- provider = M.provider.opencode,
	vision = true,
})

M.glm = blitz.add_model({
	name = "glm-5.3",
	provider = M.provider.zai,
	vision = false,
})

M.ds_new_flash = blitz.add_model({
	-- name = "deepseek/deepseek-v4.1-flash-1017",
	-- provider = M.provider.orouter,
	name = "deepseek-flash",
	provider = M.provider.deepseek,
	vision = true,
	cost = { input = 0.01625, output = 0.6, cache = 0.002 },
})

M.ds_flash = blitz.add_model({
	-- name = "deepseek/deepseek-v4.1-flash-1017",
	-- provider = M.provider.orouter,
	name = "deepseek-v4.1-flash",
	provider = M.provider.opencode,
	vision = true,
	cost = { input = 0.15, output = 0.6, cache = 0.006 },
})

M.qwen_38 = blitz.add_model({
	-- name = "qwen3.8",
	name = "inkling-2-min",
	provider = M.provider.llama,
	vision = true,
})

M.hy4 = blitz.add_model({
	provider = M.provider.opencode,
	name = "hy4",
	vision = true,
})

M.qwen_38_flash = blitz.add_model({
	-- provider = M.provider.llama,
	-- name = "qwen3.8-flash-next-ud-q2_k_xl",
	name = "qwen3.8-flash",
	provider = M.provider.opencode,
	vision = true,
})

return M
