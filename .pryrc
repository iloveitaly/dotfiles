Pry.config.editor = "/usr/local/bin/subl"

Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'

# tried using pry-clipboard; wasn't loading for me
# https://gist.github.com/hotchpotch/1978295
def pbcopy(str)
  IO.popen('pbcopy', 'r+') {|io| io.puts str }
  output.puts "-- Copy to clipboard --\n#{str}"
end

def pbpaste
	IO.popen('pbpaste') {|clipboard| clipboard.read}
end
 
Pry.config.commands.command "hiscopy", "History copy to clipboard" do |n|
  pbcopy _pry_.input_array[n ? n.to_i : -1]
end
 
Pry.config.commands.command "copy", "Copy to clipboard" do |str|
  unless str
    str = "#{_pry_.input_array[-1]}#=> #{_pry_.last_result}\n"
  end
  pbcopy str
end
 
Pry.config.commands.command "lastcopy", "Last result copy to clipboard" do
  pbcopy _pry_.last_result.chomp
end