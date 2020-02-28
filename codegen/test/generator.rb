require 'graphql_java_gen_adobe'
require 'graphql_schema'
require 'json'

introspection_result = File.read("./resources/superhero.json")
schema = GraphQLSchema.new(JSON.parse(introspection_result))

GraphQLJavaGenAdobe.new(schema,
  package_name: "org.eclipse.microprofile.graphql.client", # The Java package of the generated classes
  license_header_file: "./resources/License.erb", # The license header that will be added to all Java files
  nest_under: 'Schema', # Not used, but must be defined
  custom_scalars: [
    GraphQLJavaGenAdobe::Scalar.new(
      type_name: 'Decimal',
      java_type: 'BigDecimal',
      deserialize_expr: ->(expr) { "new BigDecimal(jsonAsString(#{expr}, key))" },
      imports: ['java.math.BigDecimal'],
    ),
  ]
).save_granular("#{Dir.pwd}/SuperHeroClient/")