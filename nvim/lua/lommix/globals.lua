-- util dev function
P = function(v)
	print(vim.inspect(v))
	return v
end

RELOAD = function(mod)
	return require("plenary.reload").reload_module(mod)
end

R = function(name)
	RELOAD(name)
	return require(name)
end
