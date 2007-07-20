require 'ostruct'
class Person < OpenStruct
  def initialize
    super
    self._explicitType = 'tutorials.Person'
    self.firstName = ''
    self.lastName = ''
    self.phone = ''
    self.email = ''
  end
end