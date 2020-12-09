require './multicast_client'
name = ARGV[0] ? ARGV[0] : 'anonymous'
ip_addr = ARGV[1] ? ARGV[1] : '224.0.1.33'
port = ARGV[2] ? ARGV[2] : '3000'

a = MulticastClient.new(ip_addr, port, name)

loop do
  user_input = STDIN.gets.chomp
  a.send_message user_input
end
