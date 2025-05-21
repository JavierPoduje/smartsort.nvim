local css_queries = require("treesitter.css.queries")

local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    -- no custom queries defined for sass just yet, so just use the css ones
    return css_queries.query_by_node(node)
end

return M

