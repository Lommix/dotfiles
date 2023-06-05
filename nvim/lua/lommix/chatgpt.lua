local ok, gpt = pcall(require, "chatgpt")
if (not ok) then return end

gpt.setup({
})
