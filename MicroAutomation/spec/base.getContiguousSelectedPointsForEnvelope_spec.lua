-- @noindex

describe("getContiguousSelectedPointsForEnvelope", function()
  local TLA = require "include.TLA_base"

  before_each(function()
    stub(TLA, "getEnvelopePoints")
  end)

  after_each(function ()
    TLA.getEnvelopePoints:revert()
  end)

  it("should return nil for no points", function ()
    TLA.getEnvelopePoints.returns(nil)
    local result = TLA.getContiguousSelectedPointsForEnvelope(envelope)
    assert.are.equal(result, nil)
  end)

  it("should return 1 for a single point", function ()
    local points = {
      [0] = {time = 0.5, selected = false},
      [1] = {time = 0.6, selected = true},
      [2] = {time = 0.7, selected = false},
    }
    TLA.getEnvelopePoints.returns(points)
    local result = TLA.getContiguousSelectedPointsForEnvelope(envelope)
    assert.are.same(result, {
      [0] = {time = 0.6, selected = true},
    })
  end)

  it("should return two points", function ()
    local points = {
      [0] = {time = 0.5, selected = false},
      [1] = {time = 0.6, selected = true},
      [2] = {time = 0.7, selected = true},
      [3] = {time = 0.8, selected = false},
    }
    TLA.getEnvelopePoints.returns(points)
    local result = TLA.getContiguousSelectedPointsForEnvelope(envelope)
    assert.are.same({
      [0] = {time = 0.6, selected = true},
      [1] = {time = 0.7, selected = true},
    }, result)
  end)

  it("should not return any points", function ()
    local points = {
      [0] = {time = 0.5, selected = false},
      [1] = {time = 0.6, selected = true},
      [2] = {time = 0.7, selected = false},
      [3] = {time = 0.8, selected = true},
    }
    TLA.getEnvelopePoints.returns(points)
    local result = TLA.getContiguousSelectedPointsForEnvelope(envelope)
    assert.are.same({
      [0] = {time = 0.6, selected = true}
    }, result)
  end)

  it("should return four points", function ()
    local points = {
      [0] = {time = 0.5, selected = true},
      [1] = {time = 0.6, selected = true},
      [2] = {time = 0.7, selected = true},
      [3] = {time = 0.8, selected = true},
    }
    TLA.getEnvelopePoints.returns(points)
    local result = TLA.getContiguousSelectedPointsForEnvelope(envelope)

    assert.are.same({
      [0] = {time = 0.5, selected = true},
      [1] = {time = 0.6, selected = true},
      [2] = {time = 0.7, selected = true},
      [3] = {time = 0.8, selected = true},
    }, result)

    -- Lua doesn't guarantee iteration order in tables, so schenanigans are required
    -- local first = TLA.getFirstPointByTime(result)
    -- local inner = TLA.getInnerPoints(result)
    -- local second = TLA.getFirstPointByTime(inner)
    -- local third = TLA.getLastPointByTime(inner)
    -- local last = TLA.getLastPointByTime(result)

    -- assert.are.same(first, {time = 0.5, selected = true})
    -- assert.are.same(second, {time = 0.6, selected = true})
    -- assert.are.same(third, {time = 0.7, selected = true})
    -- assert.are.same(last, {time = 0.8, selected = true})
  end)

end)
