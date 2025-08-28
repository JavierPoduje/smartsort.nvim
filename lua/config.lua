--- @class Config
--- @field supported_languages string[] List of languages supported by the plugin
--- @field special_separators table<string, string> List of special separators and their corresponding characters

--- @type Config
local Config = {
    special_separators = {
        ["sp"] = " ",
        ["space"] = " ",
        ["tab"] = "\t",
    },
    supported_languages = { "css", "go", "javascript", "lua", "scss", "twig", "typescript", "vue" },
}


return Config
