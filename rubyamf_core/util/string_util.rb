#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

class String
  #"FooBar".snake_case #=> "foo_bar"
  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase
  end
end