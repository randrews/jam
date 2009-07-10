# This is used to run a query expression.
# You call query on a string and it
# returns a list of Jam::Files that match that query.
#
# Queries look like this:
# genre='ambient' or artist='James Horner' and (bitrate=192 or vbr)
module Jam::Matcher
  def query str
    sql_query(str).results
  end

  def file_query str
    sql_query(str).result_files
  end

  def sql_query str
    Jam::require_parser
    Jam::SqlEvaluator.evaluate(str)
  end
end
