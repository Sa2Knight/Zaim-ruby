var base = "https://zaim.net/money";

function createURL(params) {
  var url = base + "?";
  Object.keys(params).forEach(function(k) {
    var value = params[k];
    url += k + "=" + value + "&";
  });
  return url;
}
