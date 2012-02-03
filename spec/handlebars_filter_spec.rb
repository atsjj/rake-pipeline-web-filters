describe "HandlebarsFilter" do
  HandlebarsFilter = Rake::Pipeline::Web::Filters::HandlebarsFilter

  let(:handlebars_input) {
    '<h1 class="title">{{title}}</h1>'
  }

  let(:expected_output) {
    "Ember.TEMPLATES['test']=Ember.Handlebars.compile(\"<h1 class=\\\"title\\\">{{title}}</h1>\");"
  }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("test.handlebars", handlebars_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter HandlebarsFilter.new

    filter.output_files.should == [output_file("test.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/test.js"]
    file.body.should == expected_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .handlebars extensions to .js by default" do
      filter = setup_filter HandlebarsFilter.new
      filter.output_files.first.path.should == "test.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(HandlebarsFilter.new { |input| "squid" })
      filter.output_files.first.path.should == "squid"
    end
  end
end