require "xml"
require "./gl_generator/*"


module GLGenerator
  # TODO Merge code to module
end

p "##START##"

registery = Registery::RootNode.new(XML.parse(File.read "./gl_generator/xml_files/gl.xml"))
registery.map("registry/types/type", Registery::TypeNode)
registery.map("registry/enums/enum", Registery::EnumNode)
registery.map("registry/commands/command", Registery::CommandNode)

file = File.open("./gl_generator/output/gl.cr", "wb") do |file|
  file.truncate(0)
  file << "{% if flag?(:darwin) %}\n"
  file << "  @[Link(framework: \"OpenGL\")]\n"
  file << "{% else %}\n"
  file << "  @[Link(\"GL\")]\n"
  file << "{% end %}\n"

  file << "lib LibGL\n"

  registery.build.each do |registery_entry|
    file << registery_entry
    file << "\n"
  end

  file << "end"
end

p "##END##"
