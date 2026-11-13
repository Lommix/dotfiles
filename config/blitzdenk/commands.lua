blitz.add_command("compact", function()
	blitz.cmd.compact()
end, "manual compact")

blitz.add_command("cd", function(path)
	blitz.cmd.cd(path)
end, "cd to dir")

blitz.add_command("clear", function()
	blitz.cmd.reset_session(true)
end, "clear session")

blitz.bind("<c-x>", function()
	blitz.cmd.reset_session(true)
end, "clear session")
