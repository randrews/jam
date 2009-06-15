class Jam::QueryGrammar < Dhaka::Grammar
  precedences do
    left ['or']
    left ['and']
  end

  for_symbol(Dhaka::START_SYMBOL_NAME) do
    start               %w| Query |
  end

  for_symbol('Query') do
    intersection        %w| Clause and Query |
    union               %w| Clause or Query |
    oneclause           %w| Clause |
    parenthesized_query %w| ( Query ) |
  end

  for_symbol('Clause') do
    equality            %w| symbol = Value |
    presence            %w| symbol |
  end

  for_symbol('Value') do
    string_value        %w| string |
    number_value        %w| number |
  end
end

Jam::QueryParser = Dhaka::Parser.new(Jam::QueryGrammar)
