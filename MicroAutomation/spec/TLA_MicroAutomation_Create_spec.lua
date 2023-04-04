-- @noindex

describe("TLA_MicroAutomation_Create", function ()

  local TLA = require "TLA_MicroAutomation_Create"

  describe("config", function()
    it("offset default should be 0.01", function ()
      assert.are.equal(TLA.config.offset, 0.01)
    end)
  
    it("maxRange default should be .2", function ()
      assert.are.equal(TLA.config.maxRange, 0.5)
    end)
  end)

  describe("midiInputToPercent", function () 
    it("should return the correct percentage 1", function () 
      local result = TLA.midiInputToPercent(64)
      assert.are.equal(result, 0.50393700787401574104)
    end)
    it("should return the correct percentage 2", function () 
      local result = TLA.midiInputToPercent(127)
      assert.are.equal(result, 1)
    end)
  end)


  describe("calculateFinalPointValue", function () 

    it("should not adjust value for positive range", function () 
      -- no adjustment
      local input = 0.25

      local currentValue = 50
      local min = 0
      local max = 100
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(25, result)
    end)

    it("should not adjust value for positive range", function () 
      -- no adjustment
      local input = 0.5

      local currentValue = 600
      local min = 0
      local max = 852
      local range = 0.2

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(600, result)
    end)

    it("should adjust value percent upward", function () 
      -- no adjustment
      local input = 0.6

      local currentValue = 600
      local min = 0
      local max = 852
      local range = 0.2

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(617.03999999999996362, result)
    end)

    it("should adjust value percent downard", function () 
      -- no adjustment
      local input = 0.4

      local currentValue = 600
      local min = 0
      local max = 852
      local range = 0.2

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(582.96000000000003638, result)
    end)

    it("should adjust value percent downard between 0 and 2", function () 
      -- no adjustment
      local input = 0.4

      local currentValue = 1.5
      local min = 0
      local max = 2
      local range = 0.2

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(1.4599999999999999645, result)
    end)

    it("should adjust value to 0", function () 
      -- no adjustment
      local input = 0

      local currentValue = 1
      local min = 0
      local max = 2
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(0, result)
    end)

    it("should adjust value to 0", function () 
      -- no adjustment
      local input = 0

      local currentValue = 0.5
      local min = 0
      local max = 1
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(0, result)
    end)

    it("should adjust value to 2", function () 
      -- no adjustment
      local input = 1

      local currentValue = 1
      local min = 0
      local max = 2
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(2, result)
    end)

    it("should not adjust value for integer values", function () 
      -- no adjustment
      local input = 0.5

      local currentValue = 0
      local min = -1
      local max = 1
      local range = 0.2

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(0, result)
    end)

    it("should adjust value for integer down", function () 
      -- no adjustment
      local input = 0.25

      local currentValue = 0
      local min = -1
      local max = 1
      local range = .5

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(-0.25, result)
    end)

    it("should adjust value for integer up", function () 
      -- no adjustment
      local input = 0.75

      local currentValue = 0
      local min = -1
      local max = 1
      local range = .5

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(0.25, result)
    end)

    it("should adjust value for integer down", function () 
      -- no adjustment
      local input = 0.25

      local currentValue = 0
      local min = -1
      local max = 1
      local range = .25

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(-0.125, result)
    end)

    it("should adjust value for integer up", function () 
      -- no adjustment
      local input = 0.75

      local currentValue = 0
      local min = -1
      local max = 1
      local range = .25

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(0.125, result)
    end)

    it("should adjust value for integer to -1", function () 
      -- no adjustment
      local input = 0

      local currentValue = 0
      local min = -1
      local max = 1
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(-1, result)
    end)

    it("should adjust value for integer up", function () 
      -- no adjustment
      local input = 1

      local currentValue = 0
      local min = -1
      local max = 1
      local range = 1

      local result = TLA.calculateFinalPointValue(currentValue, input, min, max, range)
      assert.are.equal(1, result)
    end)

  end)

end)  