local css_definition = require('treesitter/css')
local f = require("funcs")
require('treesitter/types')

--- @type ChadLanguageConfig
return {
    end_chars = f.merge_tables({}, css_definition.end_chars),
    linkable = f.merge_tables({ "single_line_comment" }, css_definition.linkable),
    query_by_node = f.merge_tables({}, css_definition.query_by_node),
    sortable = f.merge_arrays({ "declaration", }, css_definition.sortable)
}
