$(document).on('ajaxSend', ->
  $('input[name="commit"]').hide()
  return
).on('ajaxComplete', ->
  $('input[name="commit"]').show()
  return
).on 'ajaxSuccess', ->
  # 此處是基於 FbBot 抓下來的架構將資料重新整理為按顧客分類
  # 把所有的客戶名跑過一次
  $('td.customer').each (i) ->
    customer_name = $(this).find('a').text()
    customer_id = $(this).data('customer-id')
    order_text = $(this).siblings('td.order').html()
    if $("div.customer_#{customer_id}").length == 0
      $html = $("<div class='col-xs-3'></div>")
      $html.addClass "customer_#{customer_id}"
      $html.html "<a target='_blank' href='https://facebook.com/#{customer_id}'>#{customer_name}</a>"
      $html.appendTo '#customer_orders'
      $("div.customer_#{customer_id}").append '<table><thead><tr><th>商品</th><th>數量</th></tr></thead><tbody></tbody></table>'
      $("div.customer_#{customer_id} table").addClass 'table table-striped'
    $target = $("div.customer_#{customer_id}")
    $(this).closest('div.col-xs-3').find('img').each ->
      $target.find('tbody').append '<tr><td></td><td></td></tr>'
      $target.find('tr:last-child td:first-child').append $(this).clone() # 貼圖片
      $target.find('tr:last-child td:last-child').css 'text-align', 'center' # 將數量文字置中
      $target.find('tr:last-child td:last-child').append order_text # 貼數量
      return
    if $('#customer_orders div.col-xs-3').length % 4 == 0 # 每四個斷行一次
      $('#customer_orders').append "<div class='clearfix' />"
    return
  $('h1.hidden, hr.hidden').removeClass 'hidden'
  alert("終於跑完惹～^_^")
  return