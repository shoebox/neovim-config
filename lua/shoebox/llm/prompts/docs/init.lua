local base = "shoebox.llm.prompts.docs."
return {
  CreateArticle = require(base .. "write-article"),
  RewriteArticle = require(base .. "rewritearticle"),
}
