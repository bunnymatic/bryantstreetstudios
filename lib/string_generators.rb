letters_plus_space ||= []
('a'..'z').each {|ltr| letters_plus_space << ltr}
('A'..'Z').each {|ltr| letters_plus_space << ltr}

def gen_random_string(len=8)
  numchars = letters_plus_space.length
  (0..len).map{ letters_plus_space[rand(numchars)] }.join
end
