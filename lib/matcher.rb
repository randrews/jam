# This is used to run a query expression.
# You call query on a string and it
# returns a list of Jam::Files that match that query.
#
# Queries look like this:
# genre='ambient' or artist='James Horner' and (bitrate=192 or vbr)
module Jam::Matcher
  def query str
    matches=Jam::QueryEvaluator.evaluate(str).proc
    Jam::File.all.delete_if do |file|
      !matches[file]
    end
  end
end
