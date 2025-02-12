---@meta

---@class eeeBuilder
local Builder = {}

---@generic T
---@param name string
---@param occurence "required"
---@param factory Factory<T>
---@return T
function Builder:from_element(name, occurence, factory) end

---@generic T
---@param name string
---@param occurence "optional"
---@param factory Factory<T>
---@return T?
function Builder:from_element(name, occurence, factory) end

---@generic T
---@param name string
---@param occurence "array"
---@param factory Factory<T>
---@return T[]
function Builder:from_element(name, occurence, factory) end

---@return string
function Builder:from_text() end

---@return (string | { name: string, value: string })[]
function Builder:from_element_mixed() end

---@param name string
---@param occurence "required"
---@return string
function Builder:from_text_only_element(name, occurence) end

---@param name string
---@param occurence "optional"
---@return string?
function Builder:from_text_only_element(name, occurence) end

---@param name string
---@param occurence "array"
---@return string[]
function Builder:from_text_only_element(name, occurence) end

---@param choices { name: string, factory: Factory<any> }[]
---@param occurence "required"
---@return { name: string, value: any }
function Builder:choice(choices, occurence) end

---@param choices { name: string, factory: Factory<any> }[]
---@param occurence "optional"
---@return { name: string, value: any }?
function Builder:choice(choices, occurence) end

---@param choices { name: string, factory: Factory<any> }[]
---@param occurence "array"
---@return { name: string, value: any }[]
function Builder:choice(choices, occurence) end

---@param name string
---@param occurence "required"
---@param type "string"
---@return string
function Builder:from_attr(name, occurence, type) end

---@param name string
---@param occurence "optional"
---@param type "string"
---@return string?
function Builder:from_attr(name, occurence, type) end

---@param name string
---@param occurence "required"
---@param type "number"
---@return number
function Builder:from_attr(name, occurence, type) end

---@param name string
---@param occurence "optional"
---@param type "number"
---@return number?
function Builder:from_attr(name, occurence, type) end

---@param name string
---@param occurence "required"
---@param type "boolean"
---@return boolean
function Builder:from_attr(name, occurence, type) end

---@param name string
---@param occurence "optional"
---@param type "boolean"
---@return boolean?
function Builder:from_attr(name, occurence, type) end
