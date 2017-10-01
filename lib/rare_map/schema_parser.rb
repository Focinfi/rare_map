require 'rare_map/table'
require 'rare_map/column'

module RareMap
  # RareMap::SchemaParser parses schema.rb into Table.
  # @author Wei-Ming Wu
  module SchemaParser
    # Parses schema.rb into an Array of Table.
    #
    # @return [Array] an Array of Table
    def parse_schema(schema)
      tables = []
      
      schema.split(/\n/).each do |line|
        case line.strip!
        when /^create_table/
          name = line.match(/create_table\s+['"]([^'"]+)['"]/)[1]
          id = line.match(/(:id\s*=>|id:)\s*false/) ? false : true
          pk = line.match(/(:primary_key\s*=>|primary_key:)\s*['"](.+)['"]/)
          primary_key = pk[2] if pk
          tables << Table.new(name, :id => id, :primary_key => primary_key)
        when /^t\.index/
          unique_column_math = line.match(/t\.index\s+.*\[\s*['"]([^'"]+)['"]\s*\].*(:unique\s*=>|unique:)\s*true/)
          next if !unique_column_math || unique_column_math.size < 2
          unique_column = unique_column_math[1] 
          column = tables.last.columns.find { |col| col.name == unique_column }
          column.unique = true
        when /^t\./
          name = line.match(/t\.\w+\s+['"]([^'"]+)['"]/)[1]
          type = line.match(/t\.(\w+)\s+/)[1]
          tables.last.columns << Column.new(name, type)
        end
      end
      
      tables
    end
  end
end