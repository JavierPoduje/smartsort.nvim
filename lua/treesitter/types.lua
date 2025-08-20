--- @class EmbeddedLanguageQuery
--- @field language string: the language of the query
--- @field query string: the query string

--- @class Gap
--- @field public horizontal_gap number: the vertical gap between the two nodes
--- @field public vertical_gap number: the vertical gap between the two nodes

--- @class EndCharDefinition
--- @field char string: the character
--- @field gap Gap: the Gap between the character and the next node
--- @field is_attached boolean: true if the character is attached to the previous node

--- @class LanguageConfig
--- @field embedded_languages_queries? EmbeddedLanguageQuery[]: a list of embedded language queries
--- @field end_chars EndCharDefinition[]
--- @field linkable string[]: the types of nodes that can be linked
--- @field query_by_node table<string, string>: a mapping of node types to their queries
--- @field handy_sortables string[]: types that should be considered as sortable nodes, but are not sortable by themselfs (e.g. `export_statement` in javascript)
