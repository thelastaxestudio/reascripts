-- @noindex

describe("getTimeBoundsForPoints", function()
  local TLA = require "include.TLA_base"

  it("should return bounds for unordered points", function ()
    local result = TLA.getTimeBoundsForPoints({
      [0] = {time = 0.1},
      [1] = {time = 0.4},
      [2] = {time = 0.3},
    })

    assert.are.same(result, {
      min = 0.1,
      max = 0.4
    })
  end)

  it("should return bounds", function ()
    local result = TLA.getTimeBoundsForPoints({
      [0] = {time = 0.1},
      [1] = {time = 0.2},
      [2] = {time = 0.5},
    })

    assert.are.same(result, {
      min = 0.1,
      max = 0.5
    })
  end)

end)
