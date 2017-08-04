# encoding: utf-8

# noinspection RubyResolve
require 'net/http'
# noinspection RubyResolve
require 'net/https'
# noinspection RubyResolve
require 'uri'
# noinspection RubyResolve
require 'json'

# RetailCRM API Client
# noinspection ALL
class Retailcrm

  def initialize(url, key)
    @version = 5
    @url = "#{url}/api/v#{@version}/"
    @key = key
    @credentials = { :apiKey => @key }
    @filter = nil
    @ids = nil
  end

  ##
  # === Get orders by filter
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders({:email => 'test@example.com', :status => 'new'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def orders(filter = nil, limit = 20, page = 1)
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join('&')
    make_request("orders", { limit: limit, page: page })
  end

  ##
  # === Get orders statuses
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_statuses([26120, 19282])
  #  => {...}
  #
  # Arguments:
  #   ids (Array)
  def orders_statuses(ids = [])
    @ids = ids.map { |x| "ids[]=#{x}" }.join('&')
    make_request("orders/statuses")
  end

  ##
  # ===  Get orders by id (or externalId)
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_get(345, 'id')
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   by (String)
  #   site (String)
  def orders_get(id, by = :externalId, site = nil)
    make_request("orders/#{id}", { by: by, site: site })
  end

  ##
  # ===  Create order
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_create(order)
  #  => {...}
  #
  # Arguments:
  #   order (Array)
  #   site (String)
  def orders_create(order, site = nil)
    make_request("orders/create", { order: order.to_json, site: site }, :post)
  end

  ##
  # ===  Edit order
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_edit(order)
  #  => {...}
  #
  # Arguments:
  #   order (Array)
  #   site (String)
  def orders_edit(order, by = :externalId, site = nil)
    make_request("orders/#{order[by]}/edit", { by: by, order: order.to_json, site: site }, :post)
  end

  ##
  # ===  Upload orders
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_upload(orders)
  #  => {...}
  #
  # Arguments:
  #   orders (Array)
  #   site (String)
  def orders_upload(orders, site = nil)
    make_request("orders/upload", { orders: orders.to_json, site: site }, :post)
  end

  ##
  # ===  Set external ids for orders created into CRM
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_fix_external_ids([{:id => 200, :externalId => 334}, {:id => 201, :externalId => 364}])
  #  => {...}
  #
  # Arguments:
  #   orders (Array)
  def orders_fix_external_ids(orders)
    make_request("orders/fix-external-ids", { orders: orders.to_json }, :post)
  end

  ##
  # ===  Get orders history
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.orders_history('2015-04-10 22:23:12', '2015-04-10 23:33:12')
  #  => {...}
  #
  # Arguments:
  #   start_date (Time) (Time.strftime('%Y-%m-%d %H:%M:%S'))
  #   end_date (Time) (Time.strftime('%Y-%m-%d %H:%M:%S'))
  #   limit (Integer) (20|50|100)
  #   offset (Integer)
  #   skip_my_changes (Boolean)
  def orders_history(start_date = nil, end_date = nil, limit = 100, offset = 0, skip_my_changes = true)
    make_request("orders/history",
    {
       startDate: start_date,
       endDate: end_date,
       limit: limit,
       offset: offset,
       skipMyChanges: skip_my_changes
    })
  end

  ##
  # === Get customers by filter
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customers({:email => 'test@example.com'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def customers(filter = nil, limit = 20, page = 1)
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join('&')
    make_request("customers", { limit: limit, page: page })
  end

  ##
  # ===  Get customers by id (or externalId)
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customers_get(345, 'id')
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   by (String)
  #   site (String)
  def customers_get(id, by = :externalId, site = nil)
    make_request("customers/#{id}", { by: by, site: site })
  end

  ##
  # ===  Create customer
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customer_create(customer)
  #  => {...}
  #
  # Arguments:
  #   customer (Array)
  #   site (String)
  def customers_create(customer, site = nil)
    make_request("customers/create", { customer: customer.to_json, site: site }, :post)
  end

  ##
  # ===  Edit customer
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customers_edit(customer)
  #  => {...}
  #
  # Arguments:
  #   customer (Array)
  #   site (String)
  def customers_edit(customer, by = :externalId, site = nil)
    make_request("customers/#{customer[by]}/edit", { by: by, customer: customer.to_json, site: site }, :post)
  end

  ##
  # ===  Upload customers
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customers_upload(customers)
  #  => {...}
  #
  # Arguments:
  #   customers (Array)
  #   site (String)
  def customers_upload(customers, site = nil)
    make_request("customers/upload", { customers: customers.to_json, site: site }, :post)
  end

  ##
  # ===  Set external ids for customers created into CRM
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.customers_fix_external_ids([{:id => 200, :externalId => 334}, {:id => 201, :externalId => 364}])
  #  => {...}
  #
  # Arguments:
  #   customers (Array)
  def customers_fix_external_ids(customers)
    make_request("customers/fix-external-ids", { customers: customers.to_json }, :post)
  end

  ##
  # === Get purchace prices & stock balance
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.store_inventories({:productExternalId => 26120, :details => 1}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def store_inventories(filter = nil, limit = 20, page = 1)
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join('&')
    make_request("store/inventories", { limit: limit, page: page })
  end

  ##
  # === Set purchace prices & stock balance
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.store_inventories_upload({:offers => [{:externalId => 123, :stores => [{:code => 'store_1', :available => 15, :purchasePrice => 1000}]}]}, :site => 'main_site')
  #  => {...}
  #
  # Arguments:
  #   offers (Array)
  #   site (String)
  def store_inventories_upload(offers = [], site = nil)
    make_request("store/inventories/upload", { offers: offers, site: site }, :post)
  end

  ##
  # === Get packs by filter
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs({:store => 'main'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def packs(filter = nil, limit = 20, page = 1)
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join('&')
    make_request("orders/packs", { limit: limit, page: page })
  end

  ##
  # ===  Create pack
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs_create(pack)
  #  => {...}
  #
  # Arguments:
  #   pack (Array)
  #   site (String)
  def packs_create(pack, site = nil)
    make_request("orders/packs/create", { pack: pack.to_json, site: site }, :post)
  end

  ##
  # === Get orders assembly history
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs_history({:orderId => 26120, :startDate => '2015-04-10 23:33:12'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def packs_history(filter = nil, limit = 20, page = 1)
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join('&')
    make_request("orders/packs/history", { limit: limit, page: page })
  end

  ##
  # ===  Get pack by id
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs_get(345)
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   site (String)
  def packs_get(id, site = nil)
    make_request("orders/packs/#{id}", { site: site })
  end

  ##
  # ===  Edit pack
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs_edit(pack)
  #  => {...}
  #
  # Arguments:
  #   pack (Array)
  #   site (String)
  def packs_edit(pack, site = nil)
    make_request("orders/packs/#{pack[:id]}/edit", { pack: pack.to_json, site: site }, :post)
  end

  ##
  # ===  Delete pack
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  # Example:
  #  >> Retailcrm.packs_delete(14)
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   site (String)
  def packs_delete(id, site = nil)
    make_request("orders/packs/#{id}/delete", { site: site }, :post)
  end

  ##
  # ===  Get delivery services
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def delivery_services
    make_request("reference/delivery-services")
  end

  ##
  # ===  Edit delivery service
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def delivery_services_edit(delivery_service)
    make_request("reference/delivery-services/#{delivery_service[:code]}/edit", { deliveryService: delivery_service.to_json }, :post)
  end

  # Get delivery types
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def delivery_types
    make_request("reference/delivery-types")
  end

  ##
  # ===  Edit delivery type
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def delivery_types_edit(delivery_type)
    make_request("reference/delivery-types/#{delivery_type[:code]}/edit", { deliveryType: delivery_type.to_json }, :post)
  end

  ##
  # ===  Get order methods
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def order_methods
    make_request("reference/order-methods")
  end

  ##
  # ===  Edit order method
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def order_methods_edit(order_method)
    make_request("reference/order-methods/#{order_method[:code]}/edit", { orderMethod: order_method.to_json }, :post)
  end

  ##
  # ===  Get order types
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def order_types
    make_request("reference/order-types")
  end

  ##
  # ===  Edit order type
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def order_types_edit(order_type)
    make_request("reference/order-types/#{order_type[:code]}/edit", { orderType: order_type.to_json }, :post)
  end

  # Get payment statuses
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def payment_statuses
    make_request("reference/payment-statuses")
  end

  ##
  # ===  Edit payment status
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def payment_statuses_edit(payment_status)
    make_request("reference/payment-statuses/#{payment_status[:code]}/edit", { paymentStatus: payment_status.to_json }, :post)
  end

  ##
  # ===  Get payment types
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def payment_types
    make_request("reference/payment-types")
  end

  ##
  # ===  Edit payment type
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def payment_types_edit(payment_type)
    make_request("reference/payment-types/#{payment_type[:code]}/edit", { paymentType: payment_type.to_json }, :post)
  end

  ##
  # ===  Get product statuses
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def product_statuses
    make_request("reference/product-statuses")
  end

  ##
  # ===  Edit product status
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def product_statuses_edit(product_status)
    make_request("reference/product-statuses/#{product_status[:code]}/edit", { productStatus: product_status.to_json }, :post)
  end

  # Get sites list
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def sites
    make_request("reference/sites")
  end

  ##
  # ===  Edit site
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def sites_edit(site)
    make_request("reference/sites/#{site[:code]}/edit", { site: site.to_json }, :post)
  end

  ##
  # ===  Get status groups
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def status_groups
    make_request("reference/status-groups")
  end

  # Get statuses
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def statuses
    make_request("reference/statuses")
  end

  ##
  # ===  Edit status
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def statuses_edit(status)
    make_request("reference/statuses/#{status[:code]}/edit", { status: status.to_json }, :post)
  end

  ##
  # ===  Get stores
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def stores
    make_request("reference/stores")
  end

  ##
  # ===  Edit store
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def stores_edit(store)
    make_request("reference/stores/#{store[:code]}/edit", { store: store.to_json }, :post)
  end

  # Get countries list
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def countries
    make_request("reference/countries")
  end

  ##
  # ===  Statistic update
  # http://www.retailcrm.ru/docs/Developers/ApiVersion3
  #
  def statistic_update
    make_request("statistic/update")
  end

  def payments_create(payment, site = nil)
    make_request("orders/payments/create", { payment: payment.to_json, site: site }, :post)
  end

  def payments_edit(payment, by = :externalId, site = nil)
    make_request("orders/payments/#{payment[by]}/edit", { by: by, payment: payment.except(by).to_json, site: site }, :post)
  end

  protected

  def make_request(url, prms = {}, method = :get)
    uri = URI.parse("#{@url}#{url}")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    prms.merge!(@credentials)

    if method == :post
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(prms)
    elsif method == :get
      request = Net::HTTP::Get.new(uri.path)
      request.set_form_data(prms)
      data = "#{request.body}"

      unless @filter.nil?
        data = data + "&#{@filter}"
      end

      unless @ids.nil?
        data = data + "&#{@ids}"
      end

      request = Net::HTTP::Get.new("#{uri.path}?#{data}")
    end
    response = https.request(request)
    Retailcrm::Response.new(response.code, response.body)
  end
end

class Retailcrm::Response
    attr_reader :status, :response

    def initialize(status, body)
        @status = status
        @response = body.empty? ? [] : JSON.parse(body)
    end

    def is_successfull?
        @status.to_i < 400
    end
end
