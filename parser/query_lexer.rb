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
    'like' => 'like'
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
    raw=current_lexeme.value
    escaped=raw.gsub('\\\'','\'').gsub('\\\\','\\')
    dequoted=escaped[1..(escaped.length-2)]
    create_token('string',dequoted)
  end

  for_pattern(/[a-zA-Z0-9_\-]+/) do
    create_token('symbol')
  end

  for_pattern(/\.[a-zA-Z0-9_]+/) do
    raw=current_lexeme.value
    create_token('fieldname',raw[1..raw.size-1])
  end

  for_pattern('\s+') do
    # ignore whitespace
  end
end

Jam::QueryLexer = Dhaka::Lexer.new(Jam::QueryLexerSpecification)
