-- @noindex

describe("getCurrentTimeSelection", function()
  local TLA = require "include.TLA_base"

  before_each(function()
    stub(TLA, "getLoopTimeRange")
  end)

  after_each(function ()
    TLA.getLoopTimeRange:revert()
  end)


  it("should return nil if start/end are 0", function ()
    TLA.getLoopTimeRange.returns({startTime = 0.0, endTime = 0.0})
    local result = TLA.getCurrentTimeSelection()
    assert.are.equal(result, nil)
  end)

  it("should return nil if start/end are equal", function ()
    TLA.getLoopTimeRange.returns({startTime = 0.5, endTime = 0.5})
    local result = TLA.getCurrentTimeSelection()
    assert.are.equal(result, nil)
  end)

  it("should return a selection", function ()
    TLA.getLoopTimeRange.returns({startTime = 0.5, endTime = 0.9})
    local result = TLA.getCurrentTimeSelection()
    assert.are.same(result, {
      startTime = 0.5,
      endTime = 0.9,
      length = 0.4
    })
  end)
end)
