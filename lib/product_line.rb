require 'pg'
require 'csv'

class ProductLine
  attr_reader :id, :name, :description

  def initialize(row)
    @id = nil
    @name = row[0]
    @description = row[1]
  end

  def self.create_table
    conn = PG.connect(bdname: 'products_database')
    conn.exec('SET client_min_messages TO WARNING')
    conn.exec('DROP TABLE IF EXISTS product_lines')

    conn.exec('CREATE TABLE IF NOT EXISTS product_lines (id serial primary key not null, name varchar, description text)')

    rows = CSV.readlines('data/product_lines_data', headers: true, skip_blanks: true, quote_char:"'" )

    rows.each do |row|
      product_line = ProductLine.new(row)
      product_line.save(conn)
    end
  end

  def save
    conn.exec('INSERT INTO product_lines (name, description) VALUES ($1, $2)', [@name, @description])
  end

  def self.find_by_name(name)
    conn.PG.connect(dbname: 'products_database')
    results = conn.exec('SELECT * FROM product_lines WHERE name = $1', [name])

    return nil if results.num_tuples.zero?

    row = results[0]
    name = row['name']
    description = row['description']

    ProductLine.new[name, description]
  end

end
