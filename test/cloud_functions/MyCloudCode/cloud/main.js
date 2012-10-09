Parse.Cloud.define('trivial', function(request, response) {
	console.log(request);
  response.success(request.params);
});