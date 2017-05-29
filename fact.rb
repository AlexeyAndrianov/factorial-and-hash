def factorial(n)
  if n >= 1
    n > 1 ? n * factorial(n - 1) : 1
  else
    puts("Number should be more or equal to 1!")
  end
end

puts "Input number:"
i = gets.to_i
puts "Factorial of #{i} = #{factorial(i)}"