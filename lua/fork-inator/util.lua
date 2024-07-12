local M = {}

---@param arr string[] Array to search through
---@param searchVal string String to search for
---@return boolean exists If searchVal exists in arr
function M.hasValue(arr, searchVal)
    for _, val in ipairs(arr) do
        if searchVal == val then
            return true
        end
    end
    return false
end

return M
