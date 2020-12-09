require 'socket'

udp_socket = UDPSocket.new
udp_socket.connect(ARGV[0], ARGV[1])

loop do
  user_input = STDIN.gets.chomp
  udp_socket.send user_input, 0
end