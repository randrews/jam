class Jam::QueryLexerSpecification < Dhaka::LexerSpecification
  operators = { 
    '(' => '\(',
    ')' => '\)',
    '=' => '=',
    'and' => 'and',
    'or' => 'or',
    'not' => 'not',
    '>' => '>',
    '<' => '<',
    '>=' => '>=',
    '<=' => '<=',
    'like' => 'like',
    'sort' => 'sort',
    ',' => ',',
    'asc' => 'asc',
    'desc' => 'desc',
  }

  operators.each do |operator, regex|
    for_pattern(regex) do
      create_token(operator.downcase)
    end
    for_pattern(regex.upcase) do
      create_token(operator.downcase)
    end
  end

  for_pattern('-?\d+(\.\d+)?') do
    create_token('number')
  end

  for_pattern(/'([^\\']|\\[\\'])*'/) do
    raw=current_lexeme.value
    escaped=raw.gsub('\\\'','\'').gsub('\\\\','\\')
    dequoted=escaped[1..(escaped.length-2)]
    create_token('string',dequoted)
  end

  for_pattern(/[a-zA-Z0-9_\-]+/) do
    create_token('symbol')
  end

  for_pattern('\s+') do
    # ignore whitespace
  end
end

Jam::QueryLexer = Dhaka::Lexer.new(Jam::QueryLexerSpecification)
