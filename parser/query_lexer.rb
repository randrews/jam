class QueryLexerSpecification < Dhaka::LexerSpecification
  operators = { 
    '(' => '\(',
    ')' => '\)',
    '=' => '=',
    'and' => 'and',
    'or' => 'or'
  }

  operators.each do |operator, regex|
    for_pattern(regex) do
      create_token(operator)
    end
  end

  for_pattern('-?\d+(\.\d+)?') do
    create_token('number')
  end

  for_pattern(/'([^\\']|\\[\\'])*'/) do
    create_token('string')
  end

  for_pattern(/[a-zA-Z0-9_\-]+/) do
    create_token('symbol')
  end

  for_pattern('\s+') do
    # ignore whitespace
  end
end

QueryLexer = Dhaka::Lexer.new(QueryLexerSpecification)
