function makeDynamicRequest () {
  $.ajax({
    url: "static-dynamic",
    success: function(result) {
      $("#dynamic-req-response").html(JSON.stringify(result, null, '\t'));
    },
    error: function(xhr) {
      $("#dynamic-req-response").html("ERROR");
    }
  });


  // fetch("/dynamic").then(function(response) {
  //   $("dynamic-req-response").html(response.text());
  // }, function(error) {$("dynamic-req-response").html("ERROR");}).catch(function(error) {
  //   $("dynamic-req-response").html("ERROR");
  // });
};
