#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License
module TokenParser
  def TokenParser.parse_tokens(tokens, source)
    tokens.each do |t|
      source.gsub!("{#{t[0].to_s}}",t[1].to_s)
    end
  end
end