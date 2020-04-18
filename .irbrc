require 'irb/completion'

require 'irb/ext/save-history'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

IRB.conf[:HISTORY_FILE] = File.expand_path('~/.irb_history')
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true

%w[rubygems looksee/shortcuts awesome_print brice/init].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

class Object
  # Return a list of methods defined locally for a particular object.  Useful
  # for seeing what it does whilst losing all the guff that's implemented
  # by its parents (eg Object).
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

# http://stackoverflow.com/questions/4229571/how-do-you-save-irb-inputs-to-a-rb-file
Kernel.at_exit {
  File.open("irb.log", "w") do |f|
    f << Readline::HISTORY.to_a.join("\n")
  end
}
