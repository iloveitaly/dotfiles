Pry.config.editor = 'nano'

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

Pry.config.ls.separator = "\n" # new lines between methods
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black

# TODO https://gist.github.com/devonzuegel/c6e69d1d9981fc740a46
# TODO http://blog.nrowegt.com/ruby-rails-pry-tricks-part-2-3-more-cool-tricks/
# TODO https://wiki.josephhyatt.com/dotfiles/.pryrc
# TODO https://rocket-science.ru/hacking/2018/10/27/pry-with-whistles

class Object
  # Return a list of methods defined locally for a particular object.  Useful
  # for seeing what it does whilst losing all the guff that's implemented
  # by its parents (eg Object).
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end