namespace :test do |args|
  # Run rake test:*task*
  desc "Triggers the test suite"
  task :all do
    exec_test("./test")
  end

  desc "Triggers the TF test suite"
  task :TF do
    exec_test("./test/test_term_frequency/")
  end
  
  desc "Triggers the documents/corpuses test suite"
  task :corpus do
    exec_test("./test/corpus")
  end

  def procdir(dir)
    # Takes source files in directory
    Dir[ File.join(dir, "**", '*') ].reject do |p|
      File.directory? p
    end
  end

  def exec_test(dir)
    # Executes all files in directory - used for testing dir
    files = procdir(dir)
    files.each do |script_name|
      puts "Executing #{File.basename(script_name)}"
      require script_name
    end
  end
end
