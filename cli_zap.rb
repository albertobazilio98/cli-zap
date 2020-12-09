require './MulticastClient'

a = MulticastClient.new('224.0.1.33', 3000, 'alberto')
loop do
  user_input = gets.chomp
  a.send_message user_input
end
