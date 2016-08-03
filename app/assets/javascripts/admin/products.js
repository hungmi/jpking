$(document).on("page:change", function(){
  if (!!$("body.admin.products.index")){
    console.log("載入 admin/products.js");

    function initialize() {
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      var $table = $form_wrapper.find("table.order-items")
      var $tbody = $table.find("tbody")
      var $btn = $form_wrapper.find("#order-form-submit-btn")
    }

    function refresh_order_items() {
      // initialize()
      console.log("refresh!")
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      var $table = $form_wrapper.find("table.order-items")
      var $tbody = $table.find("tbody")
      var $btn = $form_wrapper.find("#order-form-submit-btn")
      $form_wrapper.find("input.order_item_amount").remove()
      $tbody.html("")
      $("input.order_item_amount").each(function(){
        var amount = $(this).val()
        if (!!amount && amount > 0){
          // $("#order-ids-field").val($("#order-ids-field").val() + $(this).data("product-id") + ",")
          $form.append($(this).siblings(".order_item_product_id").clone())
          $form.append($(this).clone())

          var name = $(this).parents("td").find(".product-zh-name").text()
          $tbody.append("<tr><td class='order-item-name'>" + name + "</td>" + "<td class='order-item-amount'>" + amount + "</td></tr>")
          show_order_form()
        }
      })
    }

    function show_order_form() {
      // initialize()
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      var $table = $form_wrapper.find("table.order-items")
      var $tbody = $table.find("tbody")
      var $btn = $form_wrapper.find("#order-form-submit-btn")
      $("#order-form-wrapper").addClass("opening").show()
      var height = $table.outerHeight() + 20 + $btn.outerHeight() + 2
      if (height < 500) {
        $("#order-form-wrapper").css("height", height)  
      } else {
        $("#order-form-wrapper").css("overflow-y", "scroll")
        $("body").css("overflow", "hidden")
      }
      $("#mask").show()
    }


    $(document).on("click", "#create-orders-btn", function(e){
      // 下單並顯示訂單
      console.log("click!")
      e.preventDefault();
      refresh_order_items();
      show_order_form();
    })


    $(document).on("click", "#order-form-submit-btn", function(e){
      // initialize()
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      e.preventDefault();
      var $btn = $(this)
      $.ajax({
        url: $form.attr("action"),
        data: $form.serialize(),
        dataType: "json",
        method: $form.attr("method"),
        beforeSend: function(){
          $btn.html($btn.data("disable-with")).attr("disabled", true)
        }
      }).done(function(data){
        $btn.html("完成！")
        setTimeout(function(){
          back()
          reset()
        }, 1000)
      })
    })

    function back() {
      // 關閉訂單、關閉選人、關閉遮罩、body可滾動
      // initialize()
      var $form_wrapper = $("#order-form-wrapper")
      $("body").css("overflow", "auto")
      $form_wrapper.hide().removeClass("opening")
      $("#users").removeAttr("style")
      $("#open-users-btn").removeAttr("style").html(">>").removeClass("opening")
      $("#mask").hide()
    }

    function reset() {
      // 清除user的checkboxes, 清除user-id-field的值, 清除所有order_item的值, 清除products裡的order_item的數量
      // 清除table裡的order_item名稱跟數量, 清除table裡的使用者名稱
      // initialize()
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      var $table = $form_wrapper.find("table.order-items")
      var $tbody = $table.find("tbody")
      var $btn = $form_wrapper.find("#order-form-submit-btn")
      $(".order_item_amount").val("")
      $tbody.html("")
      $form_wrapper.find("input.order_item_amount").remove()
      $(".user-set-check").prop("checked", false)
      $("button.ordered-user-names").remove()
      $("#user-id-field").val("")
      $btn.html("確認").data("disabled", false)
    }

    $(document).on("click", "#mask", function(){
      back()
    })

    $(document).on("click", ".number-btn", function(){
      if($(this).hasClass("minus")) {
        $ori_val = parseInt($(this).siblings("input.order_item_amount").val())
        if ($ori_val > 0) {
          $(this).siblings("input.order_item_amount").val( $ori_val - 1 )  
        } else {
          $(this).siblings("input.order_item_amount").val(0)
        }
      } else {
        $ori_val = parseInt($(this).siblings("input.order_item_amount").val())
        if ($ori_val > 0) {
          $(this).siblings("input.order_item_amount").val( $ori_val + 1 )  
        } else {
          $(this).siblings("input.order_item_amount").val(1)
        }
      }
    })


    ///// 選人、記錄人、移除人 開始 ///////
    function remove_user_from_order(user_id) {
      var now_user_ids = $("#user-id-field").val()
      $("input[type='checkbox'][name='user[" + user_id + "][set]']").prop("checked", false)
      $("#user-id-field").val(now_user_ids.replace( user_id + ",", "" ))
      $("button.ordered-user-names.user-" + user_id).remove()
      $("#user-id-field").trigger("change")
    }

    $(document).on("click", "#open-users-btn", function(){
      var $form_wrapper = $("#order-form-wrapper")
      var $form = $form_wrapper.find("form")
      var $table = $form_wrapper.find("table.order-items")
      var $tbody = $table.find("tbody")
      var $btn = $form_wrapper.find("#order-form-submit-btn")
      if ($(this).hasClass("opening")) {
        $(this).removeAttr("style").removeClass("opening")
        $("#users").removeAttr("style")
        $("#open-users-btn").removeAttr("style").html(">>")
        if (!$form_wrapper.hasClass("opening")) {
          $("#mask").hide()
        }
      } else {
        $(this).css("left", "200px").html("<<").addClass("opening");
        $("#users").css("left", "0px");
        $("#users").find("input[type='search']").focus()
        if (!$form_wrapper.hasClass("opening")) {
          refresh_order_items()
        }
        show_order_form()  
      }
    })

    $(document).on("input change", "input[name='search_user']", function(){
      var $input = $(this)
      $(".user-row").each(function(){
        if ( ($(this).data("filterable").indexOf($input.val()) !== -1) ) {
          $(this).removeClass("hidden") 
        } else {
          $(this).addClass("hidden")
        }
      })
    })

    $(document).on("click", ".user-set-check", function(){
      console.log($(this).val())
      var user_id = $(this).val()
      var user_name = $(this).parents(".user-row").find("td.user-name").html()
      var now_user_ids = $("#user-id-field").val()
      if ($(this).is(":checked")) {
        $("#user-id-field").val(now_user_ids + user_id + ",")
        $("table.order-items").append("<button class='btn btn-info btn-sm ordered-user-names user-" + user_id + "' data-user-id='"+ user_id + "'>" + user_name + " <i class='glyphicon glyphicon-remove'></i></button>")
        $("#user-id-field").trigger("change")
      } else {
        remove_user_from_order(user_id)
      }
    })

    $(document).on("change", "#user-id-field", function(){
      if (!$(this).val()) {
        $("table.order-items").append("<span class='no-user-hint text-danger'>未指定任何買家</span>")
        $("#order-form-submit-btn").attr("disabled", true)
      } else {
        $(".no-user-hint").remove()
        $("#order-form-submit-btn").attr("disabled", false)
      }
    })

    $(document).on("click", ".ordered-user-names", function(){
      remove_user_from_order($(this).data("user-id"))
    })
    ////// 選人、記錄人、移除人 結束 /////
  }
})