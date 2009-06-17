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
    equality            %w| symbol = Value |
    presence            %w| symbol |
    gt                  %w| symbol > Value |
    lt                  %w| symbol < Value |
    ge                  %w| symbol >= Value |
    le                  %w| symbol <= Value |
  end

  for_symbol('Value') do
    string              %w| string |
    number              %w| number |
  end
end

Jam::QueryParser = Dhaka::Parser.new(Jam::QueryGrammar, create_fake_logger)
