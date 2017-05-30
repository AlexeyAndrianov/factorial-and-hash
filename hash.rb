def histogram(array)
  array.each_with_object(Hash.new(0)) { |el, hash| hash[el] += 1 }
end
