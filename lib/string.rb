class String
  def humanize 
    self.gsub(/[[:punct:]]/, ' ').gsub(/\s+/, ' ')
  end
end
