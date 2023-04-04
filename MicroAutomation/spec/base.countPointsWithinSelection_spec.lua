-- @noindex

describe("countPointsWithinSelection", function()
  local TLA = require "include.TLA_base"

  it("should return 0 for unselected point outside selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.4, selected = false}
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 0)
  end)

  it("should return 1 for unselected point within selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = false}
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 1)
  end)

  it("should return 0 for selected point outside selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.4, selected = true}
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 0)
  end)

  it("should return 1 for selected point within selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = true}
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 1)
  end)

  it("should return 2 for unselected points in selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = false},
      [1] = {time = 0.7, selected = false},
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 2)
  end)

  it("should return 2 for selected points in selection", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = true},
      [1] = {time = 0.7, selected = true},
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 2)
  end)

  it("should return 3", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = true},
      [1] = {time = 0.7, selected = false},
      [2] = {time = 0.8, selected = true},
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 3)
  end)

  it("should return 4", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = true},
      [1] = {time = 0.7, selected = false},
      [2] = {time = 0.8, selected = true},
      [3] = {time = 0.81, selected = true},
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 4)
  end)

  it("should return only 4", function ()
    local selection = {
      startTime = 0.5,
      endTime = 0.9
    }
    local points = {
      [0] = {time = 0.6, selected = true},
      [1] = {time = 0.7, selected = false},
      [2] = {time = 0.8, selected = true},
      [3] = {time = 0.81, selected = true},
      [4] = {time = 0.91, selected = true},
    }
    local result = TLA.countPointsWithinSelection(points, selection)
    assert.are.equal(result, 4)
  end)

end)
