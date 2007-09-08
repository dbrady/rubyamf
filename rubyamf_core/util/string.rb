class String
  #"FooBar".snake_case #=> "foo_bar"
  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase
  end
end