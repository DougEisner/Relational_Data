require 'pg'
require 'csv'

class Product
  attr_reader :id, :product_code, :name, :product_line, :description, :retail_price

  def initialize(row)
    @id = nil
    @product_code = row[0]
    @name = row[1]
    @product_line = ProductLine.find_by_name(row[2]) ### find_by_name is both a Product class method and Productline class method?  Why is ProductLine used here?  What is row[2]?
    @description = row[5]
    @retail_price = row[8].to_f
  end

  def self.create_table
    conn = PG.connect(dbname: 'products_database')
    conn.exec('SET client_min_messages TO WARNING')
    conn.exec('DROP TABLE IF EXISTS products')

    conn.exec('CREATE TABLE IF NOT EXISTS products (id serial primary key not null, product_code varchar(10) unique, name varchar(100), product_line varchar(40), description text, retail_price varchar(10))')

    rows = CSV.readlines('data/product_data.csv', headers: true, skip_blanks: true, quote_char:"'")
    rows.each do |row|
      product = Product.new(row)
      product.save(conn)
    end
    conn.close
  end

  def save(conn)
    no_id? insert_new : update
  end

  def no_id?
    @id.nil?
  end

  def insert_new(conn)
    # setting var results = new row, does this also insert into table. Is results just the RETURNUNG id value or an array or hash of all values?
    results = conn.exec_params('INSERT INTO products (product_code, name, product_line, description, retail_price) VALUES ($1, $2, $3, $4, $5) RETURNING id', [@product_code, @name, @product_line, @description, @retail_price])

    new_row = results[0] # Is results[0] just the id or all values of row?
    @id = new_row['id'].to_i
  end

  def update(conn)
    conn.exec_params('UPDATE products SET product_code = $1, name = $2, product_line = $3, description = $4, retail_price = $5 WHERE id = $6',[@product_code, @name, @product_line, @description, @retail_price, @id]
  end

  def self.find_by_name(name)
    conn = PG.connect(dbname: products_database)
    results = conn.exec('SELECT * FROM products WHERE name = $1' [name])
    conn.close

    return nil if results.num_tuples.zero?

      # Is results a hash?  What is results[0]?
    row = results[0]
    product_code = row['product_code']
    name = row['name']
    product_line = row['product_line']
    description = row['description']
    retail_price = row['retail_price']

    Product.new[product_code, name, product_line, description, retail_price]
  end
end
