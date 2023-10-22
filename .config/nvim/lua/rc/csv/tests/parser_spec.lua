local p = require "rc.csv.parser"

describe("parser", function()
  describe("_parse_line", function()
    it("line without empty fields", function()
      assert.are.same({ "abc", "de", "f", "g", "h" }, p._parse_line "abc,de,f,g,h")
    end)

    it("should works for line includes empty fields", function()
      assert.are.same({ "abc", "de", "", "g", "h" }, p._parse_line "abc,de,,g,h")
      assert.are.same({ "abc", "de", "f", "g", "" }, p._parse_line "abc,de,f,g,")
      assert.are.same({ "", "abc", "de", "f", "g" }, p._parse_line ",abc,de,f,g")
      assert.are.same({ "abc", "f", "g", "", "" }, p._parse_line "abc,f,g,,")
      assert.are.same(
        { "too looooooooooooooooooooooooooooooooooooooong line", "de", "", "g", "h" },
        p._parse_line "too looooooooooooooooooooooooooooooooooooooong line,de,,g,h"
      )
    end)

    it("empty line", function()
      assert.are.same({}, p._parse_line "")
    end)
  end)

  describe("iter_lines", function()
    it("should parse all lines when no range is specified", function()
      local lines = {
        "a,b,c,d,e,,",
        "f,g,h,i,j,k,l",
        "",
        "m,n",
      }
      local expected = {
        { "a", "b", "c", "d", "e", "", "" },
        { "f", "g", "h", "i", "j", "k", "l" },
        {},
        { "m", "n" },
      }
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      local actual = {}
      for _, line in p.iter_lines(buf) do
        table.insert(actual, line)
      end
      assert.are.same(expected, actual)
    end)
    it("should parse only the specified range", function()
      local lines = {
        "a,b,c,d,e,,",
        "f,g,h,i,j,k,l",
        "",
        "m,n",
      }
      local startlnum = 2
      local endlnum = 3
      local expected = {
        { "f", "g", "h", "i", "j", "k", "l" },
        {},
      }
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      local actual = {}
      for _, line in p.iter_lines(buf, startlnum, endlnum) do
        table.insert(actual, line)
      end
      assert.are.same(expected, actual)
    end)
  end)
end)
