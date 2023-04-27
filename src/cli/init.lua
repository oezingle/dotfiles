
--[[
shell system within awesome

keyboard prompt
     - running under awesome-client
        - passes commands through awesome.emit_signal("cli::command", <shell_uuid>, args)
        - needs cli::handshake, cli::disconnect, cli::pid, etc etc
        - cli::pid redirects stdout
        - awesome periodically checks to make sure any connected sessions pids are still alive and terminates if not
        - exit command should be passed in some manner to awesome too, to terminate cleanly
     - running under lua
        - at some point consider IPC/shared file/something?
        - for now just redirect to awesome-client, basically use bash

command library
     - provides an easy tool for creating commands
     - is this even necessary? argparse + a good shell might win
]]

return require("src.cli.keyboard").prompt