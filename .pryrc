# Pry.config.input = Reline

begin
  require 'pry-doc'
rescue LoadError
  nil
end

Pry.config.editor = 'nano'
Pry.config.skip_cruby_source = true

# @ = whereami by default
Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'q', 'exit-program'
Pry.commands.alias_command 'bt', 'pry-backtrace'
# TODO: ideally `main` at the top of the stack is cut off
Pry.commands.alias_command 'ss', 'stack -a'

# Pry.commands.alias_command '?', 'show-source'

# tried using pry-clipboard; wasn't loading for me
# https://gist.github.com/hotchpotch/1978295
def pbcopy(str)
  IO.popen('pbcopy', 'r+') {|io| io.puts str }
  puts "-- Copy to clipboard --\n#{str}"
end

def pbpaste
	IO.popen('pbpaste') {|clipboard| clipboard.read}
end

def locals
  binding.callers[1].local_variables - %i[
    __
    _
    _ex_
    pry_instance
    _out_
    _in_
    _dir_
    _file_
  ]
end

Pry::Commands.block_command 'o', 'Open current line in VS Code' do |n|
  file, line = pry_instance.binding_stack.first.source_location
  # TODO got to be a faster way than shelling out
  `code --goto #{file}:#{line}`
end

Pry::Commands.block_command 'clast', 'History copy to clipboard' do |n|
  pbcopy pry_instance.input_ring[n ? n.to_i : -1]
end

Pry::Commands.block_command 'copy', 'Copy to clipboard' do |str|
  str ||= "#{pry_instance.input_ring[-1]}#=> #{pry_instance.last_result}\n"
  pbcopy str
end

Pry::Commands.block_command 'lastcopy', 'Last result copy to clipboard' do
  pbcopy pry_instance.last_result.chomp
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
# TODO https://github.com/amazing-print/amazing_print

class Object
  # Return a list of methods defined locally for a particular object.  Useful
  # for seeing what it does whilst losing all the guff that's implemented
  # by its parents (eg Object).
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

# fixes `help` output in `less`
# https://github.com/pry/pry/pull/2207
def (Pry::Pager::SystemPager).default_pager
  'less -r -F -X'
end
