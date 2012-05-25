class String
  def humanize 
    self.gsub(/[[:punct:]]/, ' ').gsub(/\s+/, ' ')
  end

  def truncate(len = 40, postfix = '...')
    return self if length <= len - postfix.length
    new_len = len - postfix.length - 1
    self[0..new_len] + postfix
  end
end
