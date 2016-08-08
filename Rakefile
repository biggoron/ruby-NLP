namespace :test do |args|
  def procdir(dir)
    Dir[ File.join(dir, "**", '*') ].reject do |p|
      File.directory? p
    end
  end

  def exec_test(dir)
    files = procdir(dir)
    files.each do |script_name|
      puts "Executing #{File.basename(script_name)}"
      require script_name
    end
  end

  desc "Triggers the test suite"
  task :all do
    exec_test("./test")
  end

  desc "Triggers the TF test suite"
  task :TF do
    exec_test("./test/test_term_frequency/")
  end

  desc "Triggers the librarian test suite"
  task :librarian do
    exec_test("./test/test_librarian")
  end
  
end
