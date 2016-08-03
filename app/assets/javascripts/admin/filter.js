$(document).on("page:change", function(){
  if (!!$("body.admin.products.index")){
    console.log("載入 filter");

    $("input.filter").on("input change", function(){
      $input = $(this)
      $(".filterable-list-container").each(function(){
        if ( ($(this).data("filterable").indexOf($input.val()) !== -1) ) {
          $(this).removeClass("hidden-by-input")
          if (!$(this).hasClass("hidden-by-btn")) {
            $(this).removeClass("hidden") 
          }
        } else {
          $(this).addClass("hidden").addClass("hidden-by-input")
        }
      })
    })

    $(".btn.filter").on("click", function(){
      $(".btn.filter").removeClass("btn-info")
      $input = $(this)
      $(".filterable-list-container").each(function(){
        if ( ($(this).data("filterable").indexOf($input.html()) !== -1) ) {
          $(this).removeClass("hidden-by-btn")
          if (!$(this).hasClass("hidden-by-input")) {
            $(this).removeClass("hidden") 
          }
        } else {
          $(this).addClass("hidden").addClass("hidden-by-btn")
        }
      })
      $(this).addClass("btn-info")
    })
  };
});