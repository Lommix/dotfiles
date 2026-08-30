local M = {}

------------------------------------------------------------------
-- Providers
------------------------------------------------------------------
M.provider = {}
M.provider.llama = blitz.add_provider({
	type = "openai",
	url = "http://127.0.0.1:8118",
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
})

M.provider.requesty = blitz.add_provider({
	type = "openai",
	url = "https://router.requesty.ai/v1",
	key_envar = "REQUESTY_API_KEY",
})

M.provider.router = blitz.add_provider({
	type = "openai",
	url = "https://openrouter.ai/api/v1",
	key_envar = "OPENROUTER_API_KEY",
})

M.provider.hetzner = blitz.add_provider({
	type = "openai",
	url = "https://inference.hetzner.com/api/v1",
	key_envar = "HETZNER_AI_KEY",
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
	vision = true,
	replay_reasoning = true,
})

M.glm = blitz.add_model({
	name = "glm-5.3",
	provider = M.provider.zai,
	vision = true,
	replay_reasoning = true,
})

M.ds_flash_ex = blitz.add_model({
	name = "deepseek-v4-flash-vision-exp",
	provider = M.provider.opencode,
	vision = true,
	replay_reasoning = true,
})

M.qwen_38_flash = blitz.add_model({
	name = "qwen3.8-flash",
	provider = M.provider.opencode,
	vision = true,
	replay_reasoning = true,
})

M.grok = blitz.add_model({
	name = "grok-4.6",
	provider = M.provider.xai,
	vision = true,
	replay_reasoning = true,
	cost = { input = 2, output = 6, cache = 0.5 },
})

return M
