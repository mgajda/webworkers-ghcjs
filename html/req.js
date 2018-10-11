var request = new XMLHttpRequest();
request.open('GET', "/html/test.html");
request.responseType = 'blob';

request.onload = function() {
  if (request.status == 200) {
    console.log("YAY!");
  } else {
    console.log("NAY!");
  }

};

request.onerror = function() {
  console.log("Error");
};
