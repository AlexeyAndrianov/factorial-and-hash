def get_array
  n = -1
  while n < 1
      print "Enter massive length: "
      n = gets.to_i
  end
  array = Array.new(n)
  i = 0
  while i < n
      print "Enter #{i}-th massive element: "
      array[i] = gets.chomp
      i = i+1
  end

  print("Your array:", array)
  puts
  array
end

filled_array = get_array()

def repeats(filled_array)
  find_repeats = Hash.new

  filled_array.each do |element|
    find_repeats[element] ? find_repeats[element] += 1 : find_repeats[element] = 1
  end

  print(find_repeats)
  puts
  find_repeats
end

repeats(filled_array)

