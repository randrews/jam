class Jam::QueryGrammar < Dhaka::Grammar
  precedences do
    left ['or']
    left ['and']
  end

  for_symbol(Dhaka::START_SYMBOL_NAME) do
    start               %w| Query |
  end

  for_symbol('Query') do
    intersection        %w| Query and Query |
    union               %w| Query or Query |
    oneclause           %w| Clause |
    parenthesized_query %w| ( Query ) |
  end

  for_symbol('Clause') do
    negated             %w| not Clause |
    presence            %w| symbol |
    comparison          %w| LeftValue Operator Value |
  end

  for_symbol('Operator') do
    eq_comparator          %w| = |
    gt_comparator          %w| > |
    lt_comparator          %w| < |
    ge_comparator          %w| >= |
    le_comparator          %w| <= |
    like_comparator        %w| like |
  end

  for_symbol('LeftValue') do
    symbol_lvalue       %w| symbol |
    field_lvalue        %w| fieldname |
  end

  for_symbol('Value') do
    string              %w| string |
    number              %w| number |
  end
end

Jam::QueryParser = Dhaka::Parser.new(Jam::QueryGrammar, create_fake_logger)
