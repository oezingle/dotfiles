
local has_luaprompt = pcall(require, "prompt")

if has_luaprompt then
    -- TODO FIXME https://github.com/dpapavas/luaprompt
else
    return require("src.cli.BasicPrompt")
end

-- TODO FIXME move out of awesome/core - maybe src/cli?