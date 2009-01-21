# file_finder.rb
# Amiel Martin
# 2009-01-21
#
# modified by Eric O'Connell to use TextMate::UI.request_item
#
# a proof-of-concept to bring FuzzyFileFinder (http://github.com/jamis/fuzzy_file_finder/tree/master)
# back to textmate. FuzzyFileFinder is a (somewhat improved) implementation of TextMate's "cmd-T"
# functionality written by Jamis Buck. This bundle however isn't quite as useful as TextMate's "cmd-T"
# as it is not integrated enough with TextMate. I'm hoping that somebody will be interested in
# rewriting this to work with Dialog2.

bundle_lib = ENV['TM_BUNDLE_SUPPORT'] + '/lib'
$LOAD_PATH.unshift(bundle_lib) if ENV['TM_BUNDLE_SUPPORT'] and !$LOAD_PATH.include?(bundle_lib)

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/htmloutput'


require 'fuzzy_file_finder'

module FileFinder
  class << self
    def run
      project_path = ENV['TM_PROJECT_DIRECTORY']
      if project_path.nil?
        TextMate::UI.alert(:warning, 'Warning', 'You cannot use the Fuzzy File Finder unless you are in a Project with multiple files.')
        return nil
      end
    
      search_string = TextMate::UI.request_string(:title => 'Fuzzy File Finder', :prompt => "Enter a string as you would normally in TextMate's ⌘T file finder.")
      if search_string.nil?
        puts 'please enter a search string'
        return nil
      end
      
      fff = FuzzyFileFinder.new(project_path, 100_000)
      matches = fff.find(search_string)

      selected = TextMate::UI.request_item(:items => matches.sort{|b,a| a[:score] <=> b[:score] }.map{|m| m[:path].gsub(ENV['TM_PROJECT_DIRECTORY'], '') })
      TextMate.go_to(:file => "#{ENV['TM_PROJECT_DIRECTORY']}#{selected}")
    end

  end
end
