# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :cli => '--color --format doc' do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})                 { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')              { "spec" }

  # rubyquiz.com challenges
  watch(%r{^rubyquiz/(.+)/(.+)\.rb$})        { |m| "spec/quizzes/#{m[1]}_spec.rb" }

end