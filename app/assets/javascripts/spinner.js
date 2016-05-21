$(document).on("page:fetch", function(){
  $(".spinner").show();
  $(".loading-content").css("opacity",0.1);
});

$(document).on("page:receive", function(){
  $(".spinner").hide();
  $(".loading-content").css("opacity",1);
});