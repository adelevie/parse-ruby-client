Parse.Cloud.define('trivial', function(request, response) {
	console.log(request);
  response.success(request.params);
});

Parse.Cloud.job("trivialJob", function(request, status) {
  console.log(request);
  response.success(request.params);
})