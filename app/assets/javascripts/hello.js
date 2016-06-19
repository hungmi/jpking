var page = require('webpage').create();
var testindex = 0; var loadInProgress = false;
page.onLoadStarted = function() {
  loadInProgress = true;
  console.log("Load started");
};
page.onLoadFinished = function(status) {
  loadInProgress = false;
  console.log("Load finished, status: " + status);
};

var steps = [
  function() {
    //Load Login Page
    page.open('https://www.facebook.com');
  },
  function() {
    //Enter Credentials
    console.log("start to log in...")
    page.evaluate(function() {
      document.querySelectorAll("input[name='email']")[0].value = "gn01189424@gmail.com"
      document.querySelectorAll("input[name='pass']")[0].value = "peter012"
      document.querySelectorAll("input#u_0_m")[0].click()
    });
    page.render("example1.png");
  },
  function() {
    // Output content of page to stdout after form has been submitted
    page.open("https://www.facebook.com/groups/BWCATGO/")
  }
];


interval = setInterval(function() {
  if (!loadInProgress && typeof steps[testindex] == "function") {
    console.log("step " + (testindex + 1));
    steps[testindex]();
    testindex++;
  }
  if (typeof steps[testindex] != "function") {
    console.log("test complete!");
    page.render("example" + testindex + ".jpg");
    console.log(page.content);
    phantom.exit();
  }
}, 1000);