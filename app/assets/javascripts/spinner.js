$(document).on("page:fetch ajaxSend", function(){
  $(".spinner").show();
  $(".loading-content").css("opacity",0.1);
});

$(document).on("page:receive ajaxComplete", function(){
  $(".spinner").hide();
  $(".loading-content").css("opacity",1);
});