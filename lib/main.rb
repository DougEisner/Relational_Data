require 'pg'
require_relative 'product'


def get_new_product_info
  product_code = get_product_code
  name = get_user_input('name')
  product_line = get_user_input('product line')
  description = get_user_input('description')
  retail_price = get_user_input("retail price")
end

def get_product_code
  puts "Please enter product code: "
  product_code = gets.chomp
  until valid_input(product_code)
    puts "Please enter a valid product code format (ie. S12_1234):"
    product_code = gets.chomp
  end
  return product_code # Is this explicit return necessary?
end

def valid_input?(product_code)
  !!/^S[0-9]{2}_[0-9]{4}$/i.match(product_code)  # Format:  S12_1234
end

def get_user_input(item)
  puts "Please entere the #{item}: "
  gets.chomp
end

def get_user_action
  print "Would you like to update"
end

def create_new_product(conn, new_product_info)
  new_product = Product.new(new_product_info)
  new_product.save(conn)
end

def check_for_product
  conn = PG.connect(dbname: 'products_database')
  puts "Enter the name of the product you would like to see: "
  name_to_search = gets.chomp.downcase
  find_product = conn.exec('SELECT * FROM products WHERE name.downcase.include? name_to_search')
  if find_product == 0
    puts "No such product exists."
  else
    puts "Here's the product information #{find_product}"
  end
end

def main
  conn = PG.connect(dbname: 'product_data')

  new_product_info = get_new_product_info

  create_new_product(conn, new_product_info)

  check_for_product

  conn.close
end

conn.close
main if __FILE__ == $PROGRAM_NAME

########  UPDATE EXISTING PRODUCT################################


# def which_product?
#   print "Enter the ID\# of the product to update: "
#   id = gets.chomp.to_i
# end
#
# def get_update_product_info
#   print "Enter a value for each product item. If none exists press retrun."
#
# end
#
# def update_existing_product
#
# end
