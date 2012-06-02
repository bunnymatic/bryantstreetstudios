class String
  def humanize 
    self.gsub(/[[:punct:]]/, ' ').gsub(/\s+/, ' ')
  end

  def truncate(len = 40, postfix = '...')
    return self if length <= len - postfix.length
    new_len = len - postfix.length - 1
    self[0..new_len] + postfix
  end

  def to_bool
    return true   if self == true   || self =~ (/(true|yes|on|1)$/i)
    return false  if self == false  || self.empty? || self =~ (/(false|no|off|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end
