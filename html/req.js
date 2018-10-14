var request = new XMLHttpRequest();
request.open('GET', "/html/all.js");
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
