var base = "https://zaim.net/money";

function createURL(params) {
  var url = base + "?";
  Object.keys(params).forEach(function(k) {
    var value = params[k];
    url += k + "=" + value + "&";
  });
  return encodeURI(url);
}

function moveAllDayPaymentsURL(name , value) {
  var keys = {'カテゴリー': 'payment_category_id' , 'ジャンル': 'genre_id' , '支払先': 'place'};
  var params = {
    mode: 'payment',
    start_date: '1980-04-01',
    end_date: '2100-04-01',
  };
  params[keys[name]] = value;
  location.href = createURL(params);
}
