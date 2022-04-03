local util = {}
function util.list_partition(predicate, list)
  local part1 = {}
  local part2 = {}
  for _, value in ipairs(list) do
    if predicate(value) then
      table.insert(part1, value)
    else
      table.insert(part2, value)
    end
  end
  return part1, part2
end

return util
