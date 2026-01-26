local base = "shoebox.llm.prompts.refactoring"
return {
  BetterNaming = require(base .. ".betternaming"),
  BetterLogging = require(base .. ".optimizelogging"),
  MatchingPattern = require(base .. ".matchingpattern"),
  MissingDoc = require(base .. ".addmissingdoc"),
  Optimize = require(base .. ".optimize"),
  Solid = require(base .. ".solid"),
}
