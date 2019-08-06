# GraphQL Java Generator

This project generates Java data models, query builders and response classes based on a GraphQL schema. It uses the JSON response of a GraphQL introspection query as input, and generates all the necessary classes to build GraphQL queries and parse GraphQL JSON responses for the input schema.

## Installation

The code generator requires ruby version 2.1 or later. It is recommended to use [bundler](http://bundler.io/) to install the code generators ruby package.

If you only want to locally install the generator, make sure you have `ruby`, `gem` and `bundle(r)` installed on your system, then simply install the generator with:

    bundle exec rake install

(you might have to use `sudo` to get this working).

The generated code depends on the `com.shopify.graphql.support` java package available [here](support/src/main/java). We recommend that you simply copy/include these Java files to your project along with the generated files of your GraphQL schema. You should include these files with their existing Java package structure, because they are referenced like that in the generated Java files of your schema.

An example project built with this generator is https://github.com/adobe/commerce-cif-magento-graphql where you can see the expected output project.

## Usage

To generate separate class files for each schema entity, use the `save_granular` command. In this case, you must provide the path to the target directory where the java files will be generated. This directoy MUST exist prior to generating the files, it is not automatically created.

e.g.
```ruby
require 'graphql_java_gen'
require 'graphql_schema'
require 'json'

introspection_result = File.read("graphql_schema.json")
schema = GraphQLSchema.new(JSON.parse(introspection_result))

GraphQLJavaGen.new(schema,
  package_name: "com.example.myapp", # The Java package of the generated classes
  license_header_file: "./License.erb", # The license header that will be added to all Java files
  nest_under: 'Schema', # Not used, but must be defined
  custom_scalars: [
    GraphQLJavaGen::Scalar.new(
      type_name: 'Decimal',
      java_type: 'BigDecimal',
      deserialize_expr: ->(expr) { "new BigDecimal(jsonAsString(#{expr}, key))" },
      imports: ['java.math.BigDecimal'],
    ),
  ]
).save_granular("#{Dir.pwd}/MyApp/src/main/java/com/example/myapp/")
```

When using the granular option, the `com.example.myapp` package will contain many small class files each containing a single GraphQL schema entity.

You can try this out with the example generator configuration provided in this repository. It uses the Magento GraphQL schema available in the [schemas](schemas) subfolder. Once the generator is install on your system, you can simply generate the Magento classes with

```
mkdir -p src/main/java/com/adobe/cq/commerce/magento/graphql
ruby example-magento-generator.rb
```

*Note: It is possible to also generate one single monolithic java file with all the schema classes, but we do not recommend to do that.*

### Generated code

The generated code includes query builders that can be used to create a GraphQL query in a type-safe manner. One can for example generate a simple query with:

```java
String queryString = Operations.query(query -> query
    .user(user -> user
        .firstName()
        .lastName()
    )
).toString();
```

The generated code also includes response classes that will deserialize the response and provide methods for accessing the field data with it already coerced to the correct type.

We recommend that you check the project at https://github.com/adobe/commerce-cif-magento-graphql where we also have unit tests that show how to parse and deserialise JSON responses.

### Deserialization

The generated code uses the [Gson](https://github.com/google/gson) Java library to deserialize JSON responses. We recommend that you define a custom deserializer for each root type defined in your GraphQL schema, similar to what is done in the https://github.com/adobe/commerce-cif-magento-graphql project with the [QueryDeserializer](https://github.com/adobe/commerce-cif-magento-graphql/blob/master/src/main/java/com/adobe/cq/commerce/magento/graphql/gson/QueryDeserializer.java) class that handles the Magento `Query` root type.

## Lambda Expressions

The generated Java files heavily rely on Java 8 lambda expressions.

## Development

After checking out the repo, run `bundle` to install ruby dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install` or reference it from a Gemfile using the path option (e.g. `gem 'graphql_java_gen', path: '~/src/graphql_java_gen'`).

### Contributing
 
Contributions are welcomed! Read the [Contributing Guide](.github/CONTRIBUTING.md) for more information.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
