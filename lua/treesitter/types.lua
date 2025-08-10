--- @class EmbeddedLanguageQuery
--- @field language string: the language of the query
--- @field query string: the query string

--- @class GapDefinition
--- @field vertical_gap number
--- @field horizontal_gap number

--- @class EndCharDefinition
--- @field char string: the character
--- @field gap GapDefinition: the Gap between the character and the next node
--- @field is_attached boolean: true if the character is attached to the previous node

--- @class ChadLanguageConfig
--- @field embedded_languages_queries? EmbeddedLanguageQuery[]: a list of embedded language queries
--- @field end_chars EndCharDefinition[]
--- @field linkable string[]: the types of nodes that can be linked
--- @field query_by_node table<string, string>: a mapping of node types to their queries
--- @field sortable string[]: the types of nodes that can be sorted
